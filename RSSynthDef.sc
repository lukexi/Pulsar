
RSSynthDef {
    var <name;
    var <outputRate;
    var <controls;
    
    *new {|name, graphFunc|
        ^super.new.init(name, graphFunc);
    }
    
    init {|aName, ugenGraphFunc|
        var synthDesc;
        controls = Dictionary();
        
        name = aName.asSymbol;
        
        if (ugenGraphFunc.notNil) {
            ugenGraphFunc.asSynthDef(name:name).add.writeDefFile;
        };
        synthDesc = SynthDescLib.global[name];
        
        outputRate = synthDesc.outputs[0].rate;
        
        synthDesc.controls.do { |control|
            var controlName = control.name.asSymbol;
            var controlRate = (control.rate == "?".asSymbol).if {\audio} {control.rate}; // Workaround a seeming bug in SynthDescLib(?) wherein a_ prefixed input names are given a rate of "?"
            
            controls[controlName] = RSSynthDefControl(controlName, control.defaultValue, controlRate);
        };
    }
    
    description {
        ^ (
            'defName':this.name,
            'controlNames':controls.keys.asArray,
            'controlDefaults':controls.values.collect(_.default),
            'outputRate':this.outputRate
        );
    }
}

RSSynthDefControl {
    var <name;
    var <default;
    var <rate;
    
    *new {|name, default, rate|
        ^super.newCopyArgs(name, default, rate);
    }
}