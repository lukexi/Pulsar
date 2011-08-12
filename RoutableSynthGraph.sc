RoutableSynthGraph {
    var <name;
    var <graphGroup;
    var <synthsByName;
    var <out;
    var <>lagTime; // Controls lags of the entire graph(!)
    
    classvar defaultGraph;
    
    *defaultGraph {
        if (defaultGraph.isNil) {
            defaultGraph = RoutableSynthGraph("Default");
        }
        ^defaultGraph;
    }
    
    *new {|name|
        ^super.newCopyArgs(name).init;
    }
    
    init {
        
        synthsByName = Dictionary();
        
        
        Server.default.schedSync {
            graphGroup = Group();
            Server.default.sync;
        };
        
        out = RoutableSynthOut(this);
        /*
        CmdPeriod.add({
            {
                "Restoring Synth Node Tree".postln;
                this.restoreNodeTree();
            }.defer(0.01);
        });
        */
    }
    
    publish {
        API(this.name).exposeMethods(this, [\addSynth, \removeSynth]);
    }
    
    mount {
        API(this.name).mountOSC;
    }
    
    addSynth {|synthName, defName, initialSynthArgs=nil|
        RoutableSynth(synthName, defName, parentGraph:this, initialSynthArgs:initialSynthArgs);
    }
    
    removeSynth {|synthName|
        var synthToRemove = synthsByName[synthName];
        
        synthsByName.values.do {|aSynth|
            aSynth.controls.do {|aControl|
                aControl.removeConnectionFrom(synthToRemove);
            }
        };
        
        synthToRemove.containerGroup.free;
        synthsByName.removeAt(synthName);
    }
    
    @ { |synthName|
        ^this.at(synthName);
    }
    
    at { |synthName|
        ^this.synthsByName[synthName];
    }
    
    // Called by RoutableSynth
    prAdd {|synthName, synth|
        synthsByName[synthName] = synth;
    }
    
    synthDescriptionsAsJSON {
        ^synthsByName.values.collect(_.description).asJSONString;
    }
    
    restoreNodeTree {
        "RESTORING SERVER OBJECTS".postln;
        synthsByName.values.do { |aSynth|
            aSynth.prSetupSynths;
        };
        
        "RESTORING SYNTH CONNECTIONS".postln;
        synthsByName.values.do { |aSynth|
            
            "Restore control connections...".postln;
            // Restore control connections...
            aSynth.prSetupControls;
            aSynth.controls.values.do { |control|
                control.connectedNodes.keys.do { |fromSynth|
                    var amp = control.connectedNodeAmps[fromSynth];
                    control.prAcceptConnectionFrom(fromSynth, aSynth, amp);
                };
            };
        };
        
        this.out.connectOut();
    }
    
    snapshot {
        var snapshot = Dictionary();
        snapshot[\synths] = List();
        snapshot[\params] = Dictionary();
        
        synthsByName.values.reject{|synth|synth == this.out}.do {|synth|
            snapshot[\synths].add([synth.name, synth.synthDefName]);
        };
        
        synthsByName.values.do {|synth|
            synth.controls.values.do {|control|
                var controlIdentifier = "%.%".format(synth.name, control.name);
                var modKey = "%.modDepth".format(controlIdentifier);
                var centerKey = "%.centerValue".format(controlIdentifier);
                snapshot[\params][modKey] = control.modDepth;
                snapshot[\params][centerKey] = control.centerValue;
                
                control.connectedNodes.keys.do { |connectedSynth|
                    var amp = control.connectedNodeAmps[connectedSynth];
                    var connectionKey = "%=>%".format(connectedSynth.name, controlIdentifier);
                    snapshot[\params][connectionKey] = amp;
                };
            };
        };
        
        ^snapshot;
    }
}