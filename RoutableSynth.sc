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