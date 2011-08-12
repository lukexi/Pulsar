/*
e.g.:
(
    "LFSaw.freq":5,
    "LFSaw=>Saw.freq":0.8,
    "LFPulse.freq":1,
    "LFPulse=>Saw.freq":0.5,
    "LFPulse=>Saw.cutoff":0.3,
    "Saw.freq.modDepth":500,
    "Saw.freq.centerValue":1000,
    "Saw=>Out":0,
    "Saw=>Reverb":1
)
*/

RSPreset {
    var <>snapshot;
    var <parentGraph;
    
    *new {|snapshot, graphNameOrParentGraph|
        ^super.newCopyArgs(snapshot).init(graphNameOrParentGraph);
    }
    
    init {|graphNameOrParentGraph|
        
        if (graphNameOrParentGraph.isNil) {
            graphNameOrParentGraph = "Graph%".format(999999.rand).asSymbol;
        };
        
        if (graphNameOrParentGraph.isKindOf(Symbol) or: {graphNameOrParentGraph.isKindOf(String)}) {
            parentGraph = RoutableSynthGraph(graphNameOrParentGraph.asSymbol); 
        };
        
        if (graphNameOrParentGraph.isKindOf(RoutableSynthGraph)) {
            parentGraph = graphNameOrParentGraph;
        };
        
    }
    
    morphTo {|otherPreset, time=5, steps=100.0|
        fork {
            steps.do { |i|
                this.apply(this.params.blend(otherPreset, i/steps));
                (time/steps).wait;
            };
        };
    }
    
    apply {
        var synths, params;
        synths = snapshot[\synths];
        params = snapshot[\params];
        
        synths.do {|synthNameAndDefName|
            var synthName, defName;
            #synthName, defName = synthNameAndDefName;
            RoutableSynth(synthName, defName, parentGraph:this.parentGraph);
        };
        
        params.keysValuesDo {|routingString, amp|
            var success = this.attemptConnection(routingString, amp);
            if (success.not) {
                this.attemptSetting(routingString, amp);
            };
        };
    }
    
    attemptConnection {|routingString, amp|
        var connection = routingString.find("=>");
        var sourceName, sourceSynth;
        var destinationString, destinationName, destinationSynth;
        var controlLocation, controlName;
        if (connection.notNil) {
            sourceName = routingString.copyRange(0, connection-1);
            'found connection from '.post;sourceName.postln;
            sourceSynth = this.parentGraph.synthsByName[sourceName.asSymbol];
            
            destinationString = routingString.copyRange(
                connection+2, routingString.size);
            
            controlLocation = destinationString.find(".");
            
            if (controlLocation.notNil) {
                destinationName = destinationString.copyRange(0, controlLocation-1);
                destinationSynth = this.parentGraph.synthsByName[destinationName.asSymbol];
                controlName = destinationString.copyRange(controlLocation+1, destinationString.size);
                sourceSynth.connectToControlOf(destinationSynth, controlName.asSymbol, amp);
                "Parsed connecting % to %'s % at amp %".format(
                    sourceName, destinationName, controlName, amp).postln;
            } {
                destinationName = destinationString.asSymbol;
                destinationSynth = this.parentGraph.synthsByName[destinationName];
                sourceSynth.connectTo(destinationSynth, amp);
                "Parsed connecting % to % at amp %".format(sourceName, destinationName, amp);
            };
        };
        ^connection.notNil;
    }
    
    attemptSetting {|routingString, amp|
        var synthName, controlName, metaName;
        var synth;
        var dots = routingString.split($.);
        if (dots.size == 3) {
            #synthName, controlName, metaName = dots;
        } {
            #synthName, controlName = dots;
            metaName = 'centerValue';
        };
        
        "Parsed setting %'s % % to %".format(synthName, controlName, metaName, amp).postln;
        
        synth = this.parentGraph.synthsByName[synthName.asSymbol];
        
        switch (metaName.asSymbol)
            {\centerValue} {
                synth.setCenterValueOfControl(controlName.asSymbol, amp)
            }
            {\modDepth} {
                synth.setModDepthOfControl(controlName.asSymbol, amp)
            };
    }
}