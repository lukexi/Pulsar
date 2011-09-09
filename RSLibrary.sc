RSLibrary {
    
    var <synthUGenGraphsByName;
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
        synthUGenGraphsByName = this.defaultSynthDefs;
        synthDefsByName = Dictionary();
        this.addAll;
    }
    
    addAll {
        this.synthUGenGraphsByName.keysValuesDo{|name, graphFunc|
            graphFunc.asSynthDef(name:name).add.writeDefFile;
        };
    }
    
    at {|name|
        ^this.synthDefsByName[name];
    }
    
    addSynthDef {|name, ugenGraphFunc|
        var synthDef = RSSynthDef(name, ugenGraphFunc);
        this.synthDefsByName[name] = synthDef;
        ^synthDef;
    }
    
    synthMetadataAsJSON {
        ^synthDefsByName.values.collect(_.description).asJSONString;
    }
    
    // Adding raw ugens
    addUGenDef { |uGenClass|
        var rate;
        var rates = this.uGenRates(uGenClass);
        
        if (rates.isEmpty) {
            "Couldn't find valid rate for uGen %".format(uGenClass).postln;
            ^nil;
        };
        rate = rates[0];
        
        this.addSynthDef(uGenClass.asSymbol, this.uGenGraphFunc(uGenClass, rate));
    }
    
    uGenGraphFunc {|uGenClass, method|
        // Creates a uGenGraphFunc from a class/method, e.g. LFNoise0, kr into {|freq| LFNoise0.kr(freq)}
        var args = this.uGenUsefulArgNames(uGenClass, method);
        var argsString = args.join(',');
        ^"{|%| %.%(%)}".format(argsString, uGenClass, method, argsString).interpret;
    }
    
    uGenUsefulArgNames {|uGenClass, methodName|
        ^this.uGenMethodFor(uGenClass, methodName).argNames.asList.removeAll([\this, \mul, \add]);
    }
    
    uGenMethodFor {|uGenClass, methodName|
        ^uGenClass.class.findRespondingMethodFor(methodName);
    }
    
    uGenRates {|uGenClass|
        var possibleRates = [\ar, \kr, \ir];
        
        ^possibleRates.select({|rate| this.uGenMethodFor(uGenClass, rate).notNil});
    }
    
    *uGenClasses {
        ^this.subclassesOf(UGen);
    }
    
    *subclassesOf {|aClass|
        // via dumpSublassList
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
    
    // Defaults
    defaultSynthDefs {
        ^(
            \ConstantValue:{|value=440|
                var lagTime = 0.1;
                LPF.kr(value, freq:1/lagTime);
            },
            \DemandEnvGen:{|i_pitchBufferNumber, i_durationBufferNumber|
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
            },
            \FadeOutEnvelope:{|a_in, i_duration, i_fadeTime|
                a_in * EnvGen.ar(
                    envelope:Env.linen(
                        sustainTime:i_duration,
                        releaseTime:i_fadeTime
                    ),
                    doneAction:2
                );
            },
            \GateEnvelope:{|a_in, i_fadeTime=0.3, gate=0|
                a_in * EnvGen.ar(
                    envelope:Env.asr(
                        attackTime:i_fadeTime,
                        sustainLevel:1,
                        releaseTime:i_fadeTime
                    ),
                    gate:gate
                );
            },
            \SinOsc:{|freq|SinOsc.ar(freq)},
            \SawOsc:{|freq|Saw.ar(freq)},
            \SinLFO:{|freq=4|SinOsc.kr(freq)},
            \TanH:{|a_in, preamp=10| (a_in * preamp).tanh / preamp},
            \MoogFF:{|a_in, freq, gain| MoogFF.ar(a_in, freq, gain)}
        );
    }
}