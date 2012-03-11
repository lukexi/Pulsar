RSLibrary {
    
    var <synthDefsByName;
    classvar sharedLibrary;
    
    *sharedLibrary {
        sharedLibrary = sharedLibrary ?? {RSLibrary()};
        ^sharedLibrary;
    }
    
    *new {
        ^super.new.init;
    }
    
    init {
        "Initializing RSLibrary".postln;
        synthDefsByName = Dictionary();
        this.addDefaultLibrary;
    }
    
    addDefaultLibrary {
        this.defaultSynthDefs.do{|description|
            "Adding %".format(description).postln;
            this.addSynthDef(description[\name], description[\ugenGraphFunc], description[\metadata]);
        };
        this.defaultUGens.keysValuesDo {|className, specs|
            this.addUGenDef(className.asClass, specs);
        };
    }
    
    at {|name|
        ^this.synthDefsByName[name];
    }
    
    addSynthDef {|name, ugenGraphFunc, specs|
        var synthDef = RSSynthDef(name, ugenGraphFunc, specs);
        this.synthDefsByName[name] = synthDef;
        ^synthDef;
    }
    
    synthMetadataAsJSON {
        ^synthDefsByName.values.collect(_.description).asJSONString;
    }
    
    // Adding raw UGens as RSSynthDefs Ñ 
    // uniqueSpecs can be passed in for things like the 'numharm' argument of Blip that won't be in Spec.specs
    addUGenDef { |uGenClass, uniqueSpecs|
        var rate;
        var ratesSupporedByUGen = this.uGenRates(uGenClass);
        
        if (ratesSupporedByUGen.isEmpty) {
            "Couldn't find valid rate for uGen %".format(uGenClass).postln;
            ^this;
        };
        
        ratesSupporedByUGen.do {|uGenRateName|
            // E.g. SinOsc's kr method becomes SinOsc-KR
            var defName = uGenClass.asString ++ "-" ++ uGenRateName.asString.toUpper;
            var graphFunc = this.uGenGraphFunc(uGenClass, uGenRateName);
            var uGenArgNames = graphFunc.def.argNames;
            var uniqueSpecsCopy = uniqueSpecs.copy;
            
            // We implement special handling of 'freq'
            // We assume kr units will be used as LFOs, 
            // so we use a low freq spec instead of the full 20hz-20khz range.
            // And for RoutableSynth/Artikulator it's better if the default frequency is 0 for audio rate freqs.
            
            if (uGenArgNames.includes(\freq)) {
                if (uGenRateName.asSymbol == \kr) {
                    uniqueSpecsCopy[\freq] = \lofreq;
                } {
	            	uniqueSpecsCopy[\freq] = [0, 20000, 'exp', 0, 0.0, " Hz"];
	            };
            };
            uniqueSpecsCopy.postln;
            this.addSynthDef(defName.asSymbol, graphFunc, uniqueSpecsCopy);
        }
    }
    
    // Creates a uGenGraphFunc from a class/method, e.g. LFNoise0, kr into {|freq| LFNoise0.kr(freq)}
    uGenGraphFunc {|uGenClass, method|
        var joinedArgNames, joinedArgNamesWithDefaults;
        var argPairs = this.usefulArgsAndDefaultsForUGen(uGenClass, method); // Gives back e.g. [freq,440,phase,0.5]
        var argumentNames = List[];
        var argumentNamesWithDefaults = List[];
        argPairs.pairsDo {|argName, default|
            argumentNames.add(argName);
            argumentNamesWithDefaults.add("%=%".format(argName, default));
        };
        joinedArgNames = argumentNames.join(',');
        joinedArgNamesWithDefaults = argumentNamesWithDefaults.join(',');
        "{|%| %.%(%)}".format(joinedArgNamesWithDefaults, uGenClass, method, joinedArgNames).postln;
        ^"{|%| %.%(%)}".format(joinedArgNamesWithDefaults, uGenClass, method, joinedArgNames).interpret;
    }
    
    usefulArgsAndDefaultsForUGen {|uGenClass, methodName|
        var argPairs = List[];
        var indexOfIn, defaultForArg;
        var method = this.uGenMethodNamed(uGenClass, methodName);
        var filterArgs = [\this, \mul, \add, \i_out];
        var argIndex = 0;
        method.argNames.do {|argName|
            if (filterArgs.includes(argName).not) {
	            
	            defaultForArg = method.prototypeFrame[argIndex];
	            
	            // Override freq defaults to always be zero because it makes more sense for RSNodes, which are going to be modulated
	            if (argName == 'freq') {
		            defaultForArg = 0.0;
		        };
                
                argPairs.add(argName).add(defaultForArg);
            };
            argIndex = argIndex + 1;
        };
        indexOfIn = argPairs.indexOf(\in);
        // Most audio processing UGens title their input control "in", so we adapt them to a_in here
        if (indexOfIn.notNil && methodName == \ar) {
            "Replacing 'in' with 'a_in' for ugen %".format(uGenClass).postln;
            argPairs.put(indexOfIn, \a_in);
        };
        ^argPairs;
    }
    
    uGenMethodNamed {|uGenClass, methodName|
        ^uGenClass.class.findRespondingMethodFor(methodName);
    }
    
    uGenRates {|uGenClass|
        var possibleRates = [\ar, \kr];
        
        ^possibleRates.select({|rate| this.uGenMethodNamed(uGenClass, rate).notNil});
    }
    
    *uGenClasses {
        ^this.subclassesOf(UGen);
    }
    
    // via dumpSublassList
    *subclassesOf {|aClass|
        var list, listCollector;
        // recursive function to collect class objects
        listCollector = { arg node, l;
            l.add(node);
            node.subclasses.do({ arg n; listCollector.value(n, l) });
        };
        list = List.new;
        listCollector.value(aClass, list);  // do the recursion
        list.sort({ arg a, b; a.name < b.name });
        list;
    }
    
    // Built-in synths
    // These are specified as (name:\Name, ugenGraphFunc:{aFunc}, metadata:(inputName:\aSpec))
    // (metadata specs may be anything that responds to .asSpec, such as an array like [0,4] or a symbol like \freq)
    defaultSynthDefs {
        ^[
            (name:\Out, ugenGraphFunc:{|a_in|
                a_in;
            }),
            (name:'*-AR', ugenGraphFunc:{|a_in, value=0|
	            a_in * value;
	        }),
	        (name:'+-AR', ugenGraphFunc:{|a_in, value=0|
	            a_in + value;
	        }),
            (name:\ConstantValue, ugenGraphFunc:{|value=440|
                var lagTime = 0.1;
                LPF.kr(value, freq:1/lagTime);
            }),
            (name:\DemandEnvGen, ugenGraphFunc:{|i_pitchBufferNumber, i_durationBufferNumber|
                DemandEnvGen.kr(
                    level:Dbufrd(
                        i_pitchBufferNumber,
                        Dseries(0, 1, BufFrames.kr(i_pitchBufferNumber))
                    ),
                    dur:Dbufrd(
                        i_durationBufferNumber,
                        Dseries(0, 1, BufFrames.kr(i_durationBufferNumber))
                    )
                );
            }),
            (name:\TimedEnvelope, ugenGraphFunc:{|a_in, i_duration, i_fadeTime|
                var envelope = EnvGen.kr(
                    envelope:Env.linen(
                        sustainTime:i_duration,
                        releaseTime:i_fadeTime
                    ),
                    doneAction:2 // We watch for the FadeOutEnvelope to release and free the graph when it does
                );
                a_in * envelope;
            }),
            (name:\GatedEnvelope, ugenGraphFunc:{|a_in, i_fadeTime=0.3, i_doneAction=0, gate=0|
                var envelope = EnvGen.kr(
                    envelope:Env.asr(
                        attackTime:i_fadeTime,
                        sustainLevel:1,
                        releaseTime:i_fadeTime
                    ),
                    gate:gate,
                    doneAction:i_doneAction
                );
                a_in * envelope;
            }),
            (name:\TanH, ugenGraphFunc:{|a_in, preamp=10| 
                (a_in * preamp).tanh / preamp
            }, metadata:(preamp:[0,25])),
            (name:\ADSREnvelope, ugenGraphFunc:{
	            var envelopeControl = \envelope.kr;
	            EnvGen.kr()
	        })
        ];
    }
    
    defaultUGens {
        ^(
            SinOsc:(),
            Saw:(),
            Pulse:(),
            LFTri:(),
            LFDNoise0:(),
            LFDNoise1:(),
            LFDNoise3:(),
            Blip:(numharm:[1,100]),
            LPF:(),
            BPF:(),
            HPF:(),
            RLPF:(),
            RHPF:(),
            MoogFF:(gain:[0,4]),
            Linen:(),
            FreeVerb:()
        )
    }
}