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
    var <dcNode;
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
        var scalerNodeName, dcNodeName;
        modDepth = 1; // TODO get this from the spec
        centerValue = this.initialCenterValue;
        
        switch (this.rate) 
            {\audio} {
                inputSummingBus = Bus.audio(Server.default, numChannels);
                scalerNodeName = \RSAudioMulAdd;
                dcNodeName = \RSAudioDC;
            }
            {\control} {
                inputSummingBus = Bus.control(Server.default, numChannels);
                scalerNodeName = \RSControlMulAdd;
                dcNodeName = \RSControlDC;
            };
        
        Server.default.schedSync {
            scalerNode = Synth.tail(
                owningSynth.inputConnectorGroup, scalerNodeName, 
                [\inputSummingBus, inputSummingBus, 
                \centerValue, centerValue,
                \modDepth, modDepth]);
            /* 
            We use a DC node at the head of the chain
            to reset the inputSummingBus to 0. Otherwise,
            if nothing is connected and streaming in signal, 
            it will hold the last value output
            by the MulAdd unit and continually apply MulAdd to it
            until it explodz. 
            */
            dcNode = Synth.head(
                owningSynth.inputConnectorGroup, dcNodeName,
                [\inputSummingBus, inputSummingBus]
            );
            owningSynth.synthNode.map(this.name, inputSummingBus);
            Server.default.sync;
        };
    }
    
    lagTime {
        ^owningSynth.parentGraph.lagTime;
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
            this.scalerNode.set(
                \centerValue, centerValue, 
                \t_lagTime, this.lagTime
            );
        };
    }
    
    +- { |aModDepth|
        this.modDepth = aModDepth;
    }
    
    modDepth_ { |aModDepth|
        modDepth = aModDepth;
        Server.default.schedSync {
            this.scalerNode.set(
                \modDepth, modDepth, 
                \t_lagTime, this.lagTime
            );
        };
    }
    
    setAmpOfConnectionFrom {|fromSynth, amp|
        this.connectedNodeAmps[fromSynth] = amp;
        Server.default.schedSync {
            this.connectedNodes[fromSynth].set(
                \amp, amp, 
                \t_lagTime, this.lagTime
            );
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
            "%.% removing connection from %".format(
                owningSynth.name, this.name, fromSynth.name).postln;
            this.connectedNodes[fromSynth].free;
            this.connectedNodes.removeAt(fromSynth);
            this.connectedNodeAmps.removeAt(fromSynth);
        };
    }
    
    prHasConnectionFrom {|fromSynth|
        ^this.connectedNodes[fromSynth].notNil;
    }
    
    prAcceptConnectionFrom {|fromSynth, amp=1|
        // Skips check for existing connection. Useful for restoring connections.
        Server.default.schedSync {
            var connectionNode;
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
        ^Synth.after(this.dcNode, connectorName,
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
            SynthDef(\RSControlConnector, { |fromBus, toBus, amp=1, t_lagTime|
                var lagAmp = Ramp.kr(amp);
                Out.kr(toBus, In.kr(fromBus) * lagAmp);
            }),
            
            SynthDef(\RSAudioConnector, { |fromBus, toBus, amp=1, t_lagTime|
                var lagAmp = Ramp.ar(K2A.ar(amp));
                Out.ar(toBus, In.ar(fromBus) * lagAmp);
            }),
            
            SynthDef(\RSControlDC, { |inputSummingBus|
                Out.kr(inputSummingBus, DC.kr(0.0));
            }),
            
            SynthDef(\RSAudioDC, { |inputSummingBus|
                Out.ar(inputSummingBus, DC.ar(0.0));
            }),
            
            SynthDef(\RSControlMulAdd, {|inputSummingBus, centerValue, modDepth, t_lagTime|
                var lagModDepth = Ramp.kr(modDepth, t_lagTime);
                var lagCenterValue = Ramp.kr(centerValue, t_lagTime);
                var mod = In.kr(inputSummingBus);
                var scaledMod = mod * lagModDepth;
                ReplaceOut.kr(inputSummingBus, scaledMod + lagCenterValue);
            }),
            
            // Haven't gotten centerValue and modDepth lag working for this yet (getting distortion...)
            SynthDef(\RSAudioMulAdd, {|inputSummingBus, centerValue, modDepth, t_lagTime|
                var lagModDepth = Ramp.ar(modDepth, t_lagTime);
                var lagCenterValue = Lag.ar(centerValue, t_lagTime);
                var mod = In.ar(inputSummingBus);
                var scaledMod = mod * /*lagModDepth*/modDepth;
                ReplaceOut.ar(inputSummingBus, scaledMod + /*lagCenterValue*/centerValue);
            }, rates:[nil, \ar, \ar, \tr])
        ];
        
        synthDefs.do(_.writeDefFile);
        Server.default.schedSync {
            synthDefs.do(_.add);
            Server.default.sync;
        }
    }
}
