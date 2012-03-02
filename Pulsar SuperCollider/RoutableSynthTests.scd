~saw = RoutableSynth(\Saw, {|freq=440, cutoff=1000| 
	var sig = Saw.ar(freq);
	MoogFF.ar(sig, freq:cutoff, gain:3);
});



~saw => RoutableSynthOut();

~saw.setCenterValueOfControl(\freq, 1000)
~saw.setModDepthOfControl(\freq, 100)

~sawLFO = RoutableSynth(\SawLFO, {|freq=2| 
	LFSaw.kr(freq);
});



~sawLFO.connectToControlOf(~saw, \freq);
~sawLFO.disconnectFromControlOf(~saw, \freq);
~sawLFO.setCenterValueOfControl(\freq, 1.0);
~sawLFO.node.set(\freq, 10)
~saw.setModDepthOfControl(\freq, 50)


~sawLFO2 = RoutableSynth(\SawLFO, {|freq=3| 
	LFSaw.kr(freq);
});

~sineLFO = RoutableSynth(\SineLFO, {|freq=0.5|
	SinOsc.kr(freq);
});

~sawLFO2.connectToControlOf(~sawLFO, \freq)

~sawLFO2.setModDepthOfControl(\freq, 200);
~sawLFO2.setCenterValueOfControl(\freq, 100.0);



~sineLFO.connectToControlOf(~sawLFO, \freq)
~sineLFO.setAmpOfConnectionTo(~sawLFO, \freq, 5.0)
~sineLFO.setCenterValueOfControl(\freq, 1000);


~sawLFO.connectToControlOf(~saw, \freq);



Pulse.ar