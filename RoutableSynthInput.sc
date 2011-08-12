/* 





*/

RoutableSynthInput {
    var owningSynth;
    var <name;
    var <rate;
    var <initialCenterValue;
    var <spec; // TODO not used yet
    var <inputSummingBus;
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
    
    setupServerObjects {
        var numChannels = 1;
        var scalerNodeName;
        modDepth = 1; // TODO get this from the spec
        centerValue = this.initialCenterValue;
        
        switch (this.rate) 
            {\audio} {
                inputSummingBus = Bus.audio(Server.default, numChannels);
                scalerNodeName = \RSAudioMulAdd;
            }
            {\control} {
                inputSummingBus = Bus.control(Server.default, numChannels);
                scalerNodeName = \RSControlMulAdd;
            };
        
        Server.default.schedSync {
            scalerNode = Synth.tail(
                owningSynth.inputConnectorGroup, scalerNodeName, 
                [\inputSummingBus, inputSummingBus, 
                \centerValue, centerValue,
                \modDepth, modDepth]);
            Server.default.sync;
        };
    }
    
    <= { |anObject|
        var synth, amp;
        if (anObject.isKindOf(RoutableSynth)) {
            this.acceptConnectionFrom(anObject);
            ^this;
        };
        
        if (anObject.isKindOf(Array)) {
            synth = anObject[0];
            amp = anObject[1];
            ^this.acceptConnectionFrom(synth, amp);
        };
        
        this.centerValue = anObject;        
    }
    
    centerValue_ { |aCenterValue|
        centerValue = aCenterValue;
        Server.default.schedSync {
            this.scalerNode.set(\centerValue, centerValue);
        };
        this.prSetCenterDirectlyIfNoConnectedNodes();
    }
    
    +- { |aModDepth|
        this.modDepth = aModDepth;
    }
    
    modDepth_ { |aModDepth|
        modDepth = aModDepth;
        Server.default.schedSync {
            this.scalerNode.set(\modDepth, modDepth);
        };
    }
    
    setAmpOfConnectionFrom {|fromSynth, amp|
        this.connectedNodeAmps[fromSynth] = amp;
        Server.default.schedSync {
            this.connectedNodes[fromSynth].set(\amp, amp);
        };
    }
    
    setupMap {
        Server.default.schedSync {
            owningSynth.synthNode.map(this.name, inputSummingBus);
            Server.default.sync;
            "Owning synth % mapped input of node: % control: % bus: %".format(
                owningSynth.name, owningSynth.synthNode, this.name, inputSummingBus).postln;
        }
    }
    
    removeMap {
        Server.default.schedSync {
            owningSynth.synthNode.map(this.name, -1);
            Server.default.sync;
        };
    }
    
    acceptConnectionFrom {|fromSynth, amp=1|
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
        
        Server.default.schedSync {
            this.connectedNodes[fromSynth].free;
        };
        
        this.connectedNodeAmps.removeAt(fromSynth);
        this.connectedNodes.removeAt(fromSynth);
        
        this.prSetCenterDirectlyIfNoConnectedNodes();
    }
    
    prSetCenterDirectlyIfNoConnectedNodes {
        if (this.connectedNodes.isEmpty) {
            "%.% NO MORE CONNECTED NODES, REMOVING MAP".format(
                owningSynth.name, this.name).postln;
            this.removeMap();
            
            Server.default.schedSync {
                owningSynth.synthNode.set(this.name, this.centerValue);
            }
        }
    }
    
    prHasConnectionFrom {|fromSynth|
        ^this.connectedNodes[fromSynth].notNil;
    }
    
    prAcceptConnectionFrom {|fromSynth, amp=1|
        // Skips check for existing connection. Useful for restoring connections.
        Server.default.schedSync {
            var connectionNode;
            this.setupMap();
            "%.% accepting connection from %".format(
                owningSynth.name, this.name, fromSynth.name).postln;
            
            connectionNode = this.prConnectorFromSynthAtAmp(fromSynth, amp);
            Server.default.sync;
            
            this.connectedNodeAmps[fromSynth] = amp;
            this.connectedNodes[fromSynth] = connectionNode;
            
            fromSynth.prOrderBefore(owningSynth, originatingSynth:owningSynth);
        };
    }
    
    prConnectorFromSynthAtAmp { |fromSynth, amp|
        var connectorName;
        switch (this.rate) 
            {\audio} {connectorName = \RSAudioConnector}
            {\control} {connectorName = \RSControlConnector};
        ^Synth.head(owningSynth.inputConnectorGroup, connectorName,
                [\fromBus, fromSynth.outputBus,
                \toBus, inputSummingBus],
                \amp, amp);
    }
    
    // RSInput Class Methods
    *initClass {
        
        {
            this.addSynthDefs;
        }.defer(1);
        
        /*
        Server.default.waitForBoot {
            "Initializing RoutableSynth Architecture 2".postln;
            //synthDefs.do(_.writeDefFile);
            //synthDefs.do(_.add);
        };
        */
    }
    
    *addSynthDefs {
        var synthDefs = [
            SynthDef(\RSControlConnector, { |fromBus, toBus, amp=1|
                Out.kr(toBus, In.kr(fromBus) * amp);
            }),
            
            SynthDef(\RSAudioConnector, { |fromBus, toBus, amp=1|
                Out.ar(toBus, In.ar(fromBus) * amp);
            }),
            
            SynthDef(\RSControlDC, { |toBus|
                Out.kr(toBus, DC.kr(0.0));
            }),
            
            SynthDef(\RSAudioDC, { |toBus|
                Out.ar(toBus, DC.ar(0.0));
            }),
            
            SynthDef(\RSControlMulAdd, {|inputSummingBus, centerValue, modDepth, t_lagTime|
                var lagModDepth = Ramp.kr(modDepth, t_lagTime);
                var lagCenterValue = Ramp.kr(centerValue, t_lagTime);
                var mod = In.kr(inputSummingBus);
                var scaledMod = mod * modDepth;
                ReplaceOut.kr(inputSummingBus, scaledMod + centerValue);
            }),
            
            SynthDef(\RSAudioMulAdd, {|inputSummingBus, centerValue, modDepth, t_lagTime|
                var lagModDepth = Ramp.ar(modDepth, t_lagTime);
                var lagCenterValue = Ramp.ar(centerValue, t_lagTime); 
                var mod = In.ar(inputSummingBus);
                var scaledMod = mod * modDepth;
                ReplaceOut.ar(inputSummingBus, scaledMod + centerValue);
            })
        ];
        
        synthDefs.do(_.writeDefFile);
        Server.default.schedSync {
            synthDefs.do(_.add);
            Server.default.sync;
        }
    }
}
