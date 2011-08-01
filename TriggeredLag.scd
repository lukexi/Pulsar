// Triggered lag — automatically disables lag when lag duration ends
// Use Lag instead of Ramp for exponential version…

// figure out how to cancel a lag — seems to not be possible with this setup
// but haven't looked if it's the Trig or the Ramp's fault

~synth = {|freq=440, lagTime=1, t_env=0|
	var lagTrig = Trig.kr(t_env * lagTime, dur:lagTime);
	var lagFreq = Ramp.kr(freq, lagTrig);
	t_env.poll;
	lagTrig.poll;
	SinOsc.ar(lagFreq);
}.play;

// UPDATE: MUCH SIMPLER (still no cancel but oh well, shouldn't actually need that
~synth = {|freq=440, t_lagTime=0|
	var lagFreq = Ramp.kr(freq, t_lagTime);
	SinOsc.ar(lagFreq);
}.play;

~synth.set(\freq, 880)
~synth.set(\freq, 4440, \t_lagTime, 3)

~synth.set(\t_env, 1, \lagTime, 3, \freq, 440);
~synth.set(\t_env, 1, \lagTime, 10, \freq, 1000);
~synth.set(\t_env, 1, \lagTime, 10, \freq, 1000);
~synth.set(\t_env, 0, \lagTime, 0, \freq, 200);
~synth.set(\freq, 600);

