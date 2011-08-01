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

RoutableSynth {
    classvar allSynths, <allSynthsByName, <out;
    var <name, <ugenGraphFunc, <superGroup, <controlSpecs, <transient;
    var <synthDef, <group, <inputConnectorGroup, <node;
    var <outBus;
    // Each control has a controlBus that other routable synths can feed into,
    // and at the end of each controlBus is a controlScaler that multiplies the
    // summed controlBus signal by a modDepth and then adds it to a centerValue
    var <controls;
    // controlConnections are incoming connection nodes from other RoutableSynth modulators
    var <numChannels;
    // superGroup is optional, to keep multiple RS systems separated
    // ^^ todo - move groups around when connecting something from one group
    // into another.
    
    var <outputRate;
    
    *initClass {
        allSynths = List[];
        allSynthsByName = Dictionary();

        CmdPeriod.add({
            {
                "Restoring Synth Node Tree".postln;
                this.restoreNodeTree();
            }.defer(0.01);
            //
        });
    }

    *restoreNodeTree {
        "RESTORING SERVER OBJECTS".postln;
        allSynths.do { |aSynth|
            aSynth.prAddServerObjects;
        };

        "RESTORING SYNTH CONNECTIONS".postln;
        allSynths.do { |aSynth|

            "Restore control connections...".postln;
            // Restore control connections...
            aSynth.prSetUpControls;
            aSynth.controls.values.do { |control|
                control.connectedNodes.keys.do { |fromSynth|
                    var amp = control.connectedNodeAmps[fromSynth];
                    control.prAcceptConnectionFrom(fromSynth, aSynth, amp);
                };
            };
        };
        
        RoutableSynthOut().connectOut();
    }
    
    *new {|name, ugenGraphFunc, superGroup, controlSpecs, transient=false|
        ^super.newCopyArgs(name, ugenGraphFunc, superGroup, controlSpecs, transient).init;
    }
    
    init {
        var controlNames = this.ugenGraphFunc.def.argNames;
        controls = Dictionary();
        numChannels = 1;
        
        // This must be evaluated outside of prAddSynthDef or else the SynthDef's graph builder function will complain:
        outputRate = ugenGraphFunc.value.rate ?? \audio;
        
        controlNames.do { |controlName, index|
            var rate;
            var defaultValue = this.ugenGraphFunc.def.prototypeFrame[index];
            if (controlName.asString.find("a_") == 0) {
                rate = \audio;
            } {
                rate = \control;
            };
            
            controls[controlName] = RSInput(
                owningSynth:this, 
                name:controlName, 
                rate:rate,
                initialCenterValue:defaultValue
            );
        };
        
        Server.default.waitForBoot { 
            'creating synthdef'.postln;
            this.prAddSynthDef;
            Server.default.sync;
            this.prAddServerObjects;
        };
        
        allSynths.add(this);
        allSynthsByName[this.name] = this;
    }
    
    add { |args|
        node = Synth.tail(this.group, this.name, 
            [\outBus, this.outBus] ++ args);
        "Spawned % node! %".format(this.name, this.node).postln;
    }
    
    disconnect { |toSynth|
        this.disconnectFromControlOf(toSynth, \a_in);
    }
    
    =< {|toSynth|
        this.disconnect(toSynth);
    }
    
    => {|toSynth|
        this.connectTo(toSynth);
        ^toSynth;
    }
    
    <= {|fromSynth|
        fromSynth => this;
        ^fromSynth;
    }
    
    connectTo {|toSynth, amp=1|
        this.connectToControlOf(toSynth, \a_in, amp);
    }
    
    connectToControlOf {|toSynth, controlName, amp=1|
        toSynth.controls[controlName].acceptConnectionFrom(this, amp);
        "Connected % to %'s %".format(
            this.name, toSynth.name, controlName).postln;
    }
    
    disconnectFromControlOf {|toSynth, controlName|
        toSynth.controls[controlName].removeConnectionFrom(this);
    }
    
    setAmpOfConnectionFrom {|fromSynth, controlName, amp|
        controls[controlName].setAmpOfConnectionFrom(fromSynth, amp);
    }
    
    setAmpOfConnectionTo {|toSynth, controlName, amp|
        toSynth.setAmpOfConnectionFrom(this, controlName, amp);
    }
    
    setModDepthOfControl {|controlName, modDepth|
        controls[controlName].modDepth = modDepth;
    }
    
    setCenterValueOfControl {|controlName, centerValue|
        controls[controlName].centerValue = centerValue;
    }
    
    // private
    
    prAddServerObjects {
        this.prSetUpSynths;
        this.prSetUpControls;
    }
    
    prAddSynthDef {
        
        synthDef = SynthDef(this.name, {|outBus|
            
            var result = SynthDef.wrap(ugenGraphFunc);
            
            "rate of % is %".format(this.name, outputRate).postln;
            
            // From GraphBuilder
            if (outputRate == \audio) {
                result = Out.replaceZeroesWithSilence(result.asArray);
            };
            
            Out.multiNewList([outputRate, outBus] ++ result);
        }).add;
    }
    
    prSetUpSynths {
        // TODO reuse buses if they're already assigned, or free them before reassigning
        switch (outputRate) 
            {\audio} {
                outBus = Bus.audio(Server.default, this.numChannels);
            }
            {\control} {
                outBus = Bus.control(Server.default, this.numChannels);
            };
        
        group = Group.tail(this.superGroup);
        inputConnectorGroup = Group.head(this.group);
        if (this.transient.not, {this.add});

        "routableSynth % created its group % in supergroup %".format(
            this.name, this.group, this.superGroup).postln;
    }
    
    prSetUpControls {
        // TODO reuse buses if they're already assigned, or free them before reassigning
        controls.values.do { |control|
            control.setUpServerObjects();
        };
    }
    
    prOrderBefore { |toSynth|
        var needsToBeMoved, index;
        // Ensure proper order-of-operations
        'before: '.post;
        allSynths.postln;

        needsToBeMoved = allSynths.indexOf(toSynth) < allSynths.indexOf(this);
        if (needsToBeMoved) {
            index = allSynths.indexOf(toSynth);
            allSynths.insert(index, allSynths.remove(this));
            this.group.moveBefore(toSynth.group);
        };
        
        if (needsToBeMoved) {
            "'% is before us (%), moving ourselves before it!'".format(toSynth, this).postln;
        } {
            "'% is already after us (%), not moving'".format(toSynth, this).postln;
        };
        'after: '.post;
        allSynths.postln;
    }
}

RoutableSynthOut : RoutableSynth {
    classvar outInstance;
    var outConnector;

    *new {
        if (outInstance.isNil) {
            outInstance = super.new(\Out, {|a_in|
                a_in;
            });

            outInstance.connectOut;
        }
        ^outInstance;
    }

    connectOut {
        Server.default.waitForBoot { 
            Server.default.sync;
            outConnector = Synth.tail(
                this.group,  \RSAudioConnector,
                [\fromBus, this.outBus, 
                \toBus, 0,
                \amp, 1]);
        };
    }
}