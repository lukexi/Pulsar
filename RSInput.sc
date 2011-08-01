/* 

_Notes on implementing feedback_
*Each time a source is connected to a destination, step forwards through the outgoing tree of the  destination and see if any of the paths lead back to the source.

(*or, step backwards through the incoming tree of the source and see if any paths lead back to the destination)

*If so, use an "InFeedback" connector and don't reorder the allSynths array.

_Notes on unifying connections_

*Separate out the amp-setting call so we can use operators (e.g. => to connect, =>* to change amp) for everything?

_Notes on RoutableSynthDef_
*Fold the SynthDef creation part of RoutableSynth into RoutableSynthDef and use that to store off named synths for RoutableSynths — then only use RoutableSynth's ugenGraphFunc if it's passed in, otherwise looking up the synthdef.

*Replace all "waitForBoot" and Server.default.syncs with a condition that signals when it's ready for connections to occur

*modDepth should be the MIN(abs(centerValue-spec.max), abs(centerValue-spec.min)) so it can never exceed the bounds — or, automatically shift the centerValue towards the center ((spec.max-spec.min)/2 + spec.min) so modulation can still occur? final option: clip final mod value in the scaler. double-final: don't do any of this and see if it creates nice glitches, leaving it to the user.

*K2A and A2K can give us RSAudio2ControlConnector and RSControl2AudioConnectors

*/

RSInput {
    var owningSynth;
    var <name;
    var <rate;
    var <initialCenterValue;
    var <spec; // TODO not used yet
    var <bus;
    var <scalerNode;
    var <connectedNodes; // These are incoming connected nodes from other RoutableSynths
    var <connectedNodeAmps;
    var <centerValue;
    var <modDepth;
    
    *new {|owningSynth, name, rate, initialCenterValue=0|
        ^super.newCopyArgs(owningSynth, name, rate, initialCenterValue).init;
    }
    
    init {
        // Using IdentityDictionaries lets us key by the RoutableSynth instances that are connecting to us
        connectedNodes = IdentityDictionary();
        connectedNodeAmps = IdentityDictionary();
    }
    
    setUpServerObjects {
        var numChannels = 1;
        var scalerNodeName;
        modDepth = 1; // TODO get this from the spec
        centerValue = this.initialCenterValue;

        switch (this.rate) 
            {\audio} {
                bus = Bus.audio(Server.default, numChannels);
                scalerNodeName = \RSAudioMulAdd;
            }
            {\control} {
                bus = Bus.control(Server.default, numChannels);
                scalerNodeName = \RSControlMulAdd;
            };
        
        scalerNode = Synth.tail(
            owningSynth.inputConnectorGroup, scalerNodeName, 
            [\bus, bus, 
            \centerValue, centerValue,
            \modDepth, modDepth]);
    }
    
    centerValue_ { |aCenterValue|
        centerValue = aCenterValue;
        this.scalerNode.set(\centerValue, centerValue);

        this.prSetCenterDirectlyIfNoConnectedNodes();
    }
    
    modDepth_ { |aModDepth|
        modDepth = aModDepth;
        this.scalerNode.set(\modDepth, modDepth);
    }
    
    setAmpOfConnectionFrom {|fromSynth, amp|
        this.connectedNodeAmps[fromSynth] = amp;
        this.connectedNodes[fromSynth].set(\amp, amp);
    }

    setUpMap {
        "Owning synth: % node: % control: % bus: %".format(
            owningSynth.name, owningSynth.node, this.name, bus).postln;
        owningSynth.node.map(this.name, bus);
    }

    // Not currently using this
    removeMap {
        owningSynth.node.map(this.name, -1);
    }
    
    acceptConnectionFrom {|fromSynth, amp=1|
        var control, controlBus, synth;
        
        if (this.prHasConnectionFrom(fromSynth)) {
            this.setAmpOfConnectionFrom(fromSynth, amp);
            ^this;
        };

        this.prAcceptConnectionFrom(fromSynth, amp);
    }
    
    removeConnectionFrom {|fromSynth|
        if (this.prHasConnectionFrom(fromSynth).not) {
            ^this;
        };
        this.connectedNodes[fromSynth].free;
        this.connectedNodeAmps.removeAt(fromSynth);
        this.connectedNodes.removeAt(fromSynth);

        this.prSetCenterDirectlyIfNoConnectedNodes();
    }
    
    prSetCenterDirectlyIfNoConnectedNodes {
        if (this.connectedNodes.isEmpty) {
            "%.% NO MORE CONNECTED NODES, REMOVING MAP".format(
                owningSynth.name, this.name).postln;
            this.removeMap();
            owningSynth.node.set(this.name, this.centerValue);
        }
    }
    
    prHasConnectionFrom {|fromSynth|
        ^this.connectedNodes[fromSynth].notNil;
    }
    
    prAcceptConnectionFrom {|fromSynth, amp=1|
        // Skips check for existing connection. Useful for restoring connections.
        var connectionNode;
        Server.default.waitForBoot {
            Server.default.sync;
            
            this.setUpMap();
            "%.% accepting connection from %".format(
                owningSynth.name, this.name, fromSynth.name).postln;
            
            connectionNode = this.prConnectorFromSynthAtAmp(fromSynth, amp);
            
            this.connectedNodeAmps[fromSynth] = amp;
            this.connectedNodes[fromSynth] = connectionNode;
            
            fromSynth.prOrderBefore(owningSynth);
        };
    }
    
    prConnectorFromSynthAtAmp { |fromSynth, amp|
        var connectorName;
        switch (this.rate) 
            {\audio} {connectorName = \RSAudioConnector}
            {\control} {connectorName = \RSControlConnector};
        ^Synth.head(owningSynth.inputConnectorGroup, connectorName,
                [\fromBus, fromSynth.outBus,
                \toBus, bus],
                \amp, amp);
    }

    // RSInput Class Methods
    *initClass {
        Server.default.waitForBoot {
            "Initializing RoutableSynth Architecture 2".postln;

            SynthDef(\RSControlConnector, { |fromBus, toBus, amp=1|
                Out.kr(toBus, In.kr(fromBus) * amp);
            }).add;

            SynthDef(\RSAudioConnector, { |fromBus, toBus, amp=1|
                Out.ar(toBus, In.ar(fromBus) * amp);
            }).add;

            SynthDef(\RSControlMulAdd, {|bus, centerValue, modDepth|
                var mod = In.kr(bus);
                var scaledMod = mod * modDepth;
                ReplaceOut.kr(bus, scaledMod + centerValue);
            }).add;

            SynthDef(\RSAudioMulAdd, {|bus, centerValue, modDepth|
                var mod = In.ar(bus);
                var scaledMod = mod * modDepth;
                ReplaceOut.ar(bus, scaledMod + centerValue);
            }).add;
        };
    }
}
