/*
    _Notes on implementing feedback_
*Each time a source is connected to a destination, step backwards through the incoming tree of the source and see if any of the paths lead back to the destination.

*If so, use an "InFeedback" connector and add to a special incoming tree.

_Notes on unifying connections_

*Separate out the amp-setting call so we can use operators (e.g. => to connect, =>* to change amp) for everything?

_Notes on RSNodeDef_
*Fold the SynthDef creation part of RSNode into RSNodeDef and use that to store off named synths for RSNodes ÑÊthen only use RSNode's ugenGraphFunc if it's passed in, otherwise looking up the synthdef.

*Replace all "waitForBoot" and Server.default.syncs with a condition that signals when it's ready for connections to occur

*modDepth should be the MIN(abs(centerValue-spec.max), abs(centerValue-spec.min)) so it can never exceed the bounds Ñ or, automatically shift the centerValue towards the center ((spec.max-spec.min)/2 + spec.min) so modulation can still occur? final option: clip final mod value in the scaler. double-final: don't do any of this and see if it creates nice glitches, leaving it to the user.

*K2A and A2K can give us RSAudio2ControlConnector and RSControl2AudioConnectors

_RSGraph_

*synthsByName isn't great because it uses the same name as the synthDef name, which means we can't use multiple instances of the same synth. Fix this so names are unique or auto-append a number like LFO1, LFO2 etc., or figure out a different scheme. Do this when we deal with the RSNodeDef thing above.

*/

RSNode {
    var <name, <ugenGraphFuncOrName, <controlSpecs, <transient, <parentGraph, initialSynthArgs;
    var <synthDef;
    var <containerGroup, <inputConnectorGroup, <synthNode;
    var <outputBus;
    // Each control has a controlBus that other routable synths can feed into,
    // and at the end of each controlBus is a controlScaler that multiplies the
    // summed controlBus signal by a modDepth and then adds it to a centerValue
    var <controls;
    var <numChannels;
    
    *new {|name, ugenGraphFuncOrName, synthDef, controlSpecs, transient=false, parentGraph=nil, initialSynthArgs=nil|
        ^super.newCopyArgs(name, ugenGraphFuncOrName, synthDef, controlSpecs, transient, parentGraph, initialSynthArgs).init;
    }
    
    init {
        
        controls = Dictionary();
        numChannels = 1;
        
        parentGraph = parentGraph ?? {RSGraph.defaultGraph};
        
        if (ugenGraphFuncOrName.isKindOf(Symbol) or: {ugenGraphFuncOrName.isKindOf(String)}) {
            synthDef = RSLibrary.sharedLibrary[name];
            if (synthDef.isNil) {
                "Couldn't find SynthDesc named %".format(name).warn;
                ^nil;
            }
        } {
            synthDef = RSLibrary.sharedLibrary.addSynthDef(this.name, ugenGraphFuncOrName);
        };
        
        synthDef.controls.do { |control|
            var controlName = control.name.asSymbol;
            
            // we ignore 'initial rate' (i_-prefixed) controls as they can't be modulated
            if (controlName.asString.beginsWith("i_").not) {
                "% creating control % rate %".format(this.name, control, control.rate).postln;
                controls[controlName] = RSInput(
                    owningSynth:this, 
                    name:controlName, 
                    rate:control.rate,
                    initialCenterValue:control.default
                );
            };
        };
        
        this.prSetupServerObjects;
        
        this.parentGraph.prAddSynth(this);
    }
    
    spawn { |args|
        Server.default.schedSync {
            synthNode = Synth.tail(this.containerGroup, this.synthDefName, 
            [\i_out, this.outputBus] ++ args);
            Server.default.sync;
            "Spawned % node! % with args: %".format(
                this.name, this.synthNode, [\i_out, this.outputBus] ++ args).postln;
        };
    }
    
    disconnectFrom { |toSynth|
        this.disconnectFromControlOf(toSynth, \a_in);
    }
    
    =< { |toObject|
        
        if (toObject.isKindOf(Symbol) and: {toObject == \Out}) {
            this.disconnectFrom(this.parentGraph.out);
        };
        
        if (toObject.isKindOf(RSNode)) {
            this.disconnectFrom(toObject);
            ^toObject;
        };
        
        if (toObject.isKindOf(RSInput)) {
            toObject.removeConnectionFrom(this);
            ^this;
        };
    }
    
    => { |toObject|
        
        if (toObject.isKindOf(Symbol) and: {toObject == \Out}) {
            this.connectTo(this.parentGraph.out);
        };
        
        if (toObject.isKindOf(RSNode)) {
            this.connectTo(toObject);
            ^toObject;
        };
        
        if (toObject.isKindOf(RSInput)) {
            toObject.acceptConnectionFrom(this, amp:1);
            ^this;
        };
    }
    
    @ { |controlName|
        ^this.at(controlName);
    }
    
    at { |controlName|
        ^this.controls[controlName];
    }
    
    * { |value|
        ^[this, value];
    }
    
    <= { |fromSynth|
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
    
    outputRate {
        ^this.synthDef.outputRate;
    }
    
    synthDefName {
        ^this.synthDef.name;
    }
    
    
    // private
    
    prSetupServerObjects {
        this.prSetupSynths;
        this.prSetupControls;
    }
    
    prSetupSynths {
        // TODO reuse buses if they're already assigned, or free them before reassigning
        switch (this.outputRate) 
            {\audio} {
                outputBus = Bus.audio(Server.default, this.numChannels);
            }
            {\control} {
                outputBus = Bus.control(Server.default, this.numChannels);
            };
        
        Server.default.schedSync {
            containerGroup = Group.head(this.parentGraph.graphGroup);
            inputConnectorGroup = Group.head(this.containerGroup);
            Server.default.sync;
        };
        if (this.transient.not, {this.spawn(initialSynthArgs)});
        
        "RSNode % created its group % in graph %".format(
            this.name, this.containerGroup, this.parentGraph).postln;
    }
    
    prSetupControls {
        // TODO reuse buses if they're already assigned, or free them before reassigning
        controls.values.do { |control|
            control.setupServerObjects();
        };
    }
    
    prOrderBefore { |toSynth, originatingSynth|
        
        Server.default.schedSync {
            this.containerGroup.moveBefore(toSynth.containerGroup);
            Server.default.sync;
        };
        
        this.controls.values.do {|aControl|
            aControl.connectedNodes.keys.do { |connectedSynth|
                if (connectedSynth == originatingSynth) {
                    "Infinite loop detected — implement InFeedback to handle!".postln;
                    ^this;
                };
                
                connectedSynth.prOrderBefore(this, originatingSynth);
            }
        }
    }
}

RSNodeOut : RSNode {
    var <outConnector;
    
    *new { |parentGraph|
        ^super.new(\Out, {|a_in|
            a_in;
        }, parentGraph:parentGraph).connectOut;
    }
    
    connectOut {
        Server.default.schedSync {
            outConnector = Synth.tail(
                this.containerGroup,  \RSAudioConnector,
                [\fromBus, this.outputBus, 
                \toBus, 0,
                \amp, 1]);
            Server.default.sync;
        };
    }
}