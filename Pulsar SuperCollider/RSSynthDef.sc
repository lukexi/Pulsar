
RSSynthDef {
    var <name;
    var <outputRate;
    var <controls;
    
    *new {|name, graphFunc, specs|
        ^super.new.init(name, graphFunc, specs);
    }
    
    init {|aName, ugenGraphFunc, specs|
        var synthDesc;
        controls = List();
        
        name = aName.asSymbol;
        
        if (ugenGraphFunc.notNil) {
            this.wrapOut(name, ugenGraphFunc, specs).store;
        };
        synthDesc = SynthDescLib.global[name];
        
        outputRate = synthDesc.outputs[0].rate;
        
        synthDesc.controls.do { |control|
            var controlName = control.name.asSymbol;
            var controlRate = (control.rate == "?".asSymbol).if {\audio} {control.rate}; // Workaround a seeming bug in SynthDescLib(?) wherein a_ prefixed input names are given a rate of "?"
            var spec = synthDesc.metadata !? {synthDesc.metadata[\specs] !? {synthDesc.metadata[\specs][controlName]}};
            "% explicit metadata for % is %".format(aName, controlName, spec).postln;
            controls.add(RSSynthDefControl(controlName, control.defaultValue, controlRate, spec));
        };
    }
    
    wrapOut { |name, func, specs, rates, prependArgs, outClass=\Out|
        // A modification of wrapOut (from GraphBuilder) that supports specs (but omits fadeTime)
        ^SynthDef.new(name, { arg i_out=0;
            var result, rate, env;
            result = SynthDef.wrap(func, rates, prependArgs).asUGenInput;
            rate = result.rate;
            if(rate === \scalar,{
                // Out, SendTrig etc. probably a 0.0
                result
            },{
                outClass = outClass.asClass;
                outClass.replaceZeroesWithSilence(result.asArray);
                outClass.multiNewList([rate, i_out]++result)
            })
        }, metadata:(specs:specs));
    }
    
    description {
        ^ (
            'defName':this.name,
            'controlNames':this.modulatableControls.collect(_.name),
            'controlDefaults':this.modulatableControls.collect(_.default),
            'controlRanges':this.modulatableControls.collect(_.specAsArray),
            'outputRate':this.outputRate
        );
    }
    
    modulatableControls {
	    // Filter out controls that don't make sense for modulation, such as initial-rate or doneActions
        ^this.controls.select({|control| 
	        var controlName = control.name.asString;
	        controlName.beginsWith("i_").not and: {controlName != "doneAction"};
	    });
    }
}

RSSynthDefControl {
    var <name;
    var <default;
    var <rate;
    var <spec;
    
    *new {|name, default, rate, spec|
        ^super.newCopyArgs(name, default, rate, spec).init;
    }
    
    init {
	    // If we've been passed a spec, use it ÑÊotherwise try to infer it from the name of the control
        spec = spec.notNil.if {spec.asSpec} {this.findSpec};
        spec.default = default;
        "spec for % is %".format(name, spec).postln;
    }
    
    specAsArray {
        ^[spec.minval, spec.maxval, spec.warp.asSpecifier, spec.units];
    }
    
    findSpec {
        ^Spec.specs[this.specNameForName].asSpec; // nil will become default spec
    }
    
    // Map common arguments to specs, e.g. 'cutoff' should always use the 'freq' spec
    specNameForName {
        var mappings = (\cutoff:\freq);
        var result = mappings[this.name];
        result = result.notNil.if {result} {this.name};
        ^result;
    }
}