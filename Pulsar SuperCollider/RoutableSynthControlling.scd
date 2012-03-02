// TODO use .exprange in the RSControlMulAdd (or make a specialized) 
// synthDef when appropriate to scale modulation to an exponential range
(
~sinLFO = RSNode(\LFSin, {|in, freq=0.5| 
	SinOsc.kr(freq);
});

~sawLFO = RSNode(\LFSaw, {|in, freq=3| 
	LFSaw.kr(freq);
});

~squareLFO = RSNode(\LFPulse, {|in, freq=7| 
	LFPulse.kr(freq);
});

~saw = RSNode(\Saw, {|in, freq=440, cutoff=1000| 
	var sig = Saw.ar(freq);
	MoogFF.ar(sig, freq:cutoff, gain:3);
});

~noise = RSNode(\Noise, {|in, cutoff=1000|
	var sig = WhiteNoise.ar();
	MoogFF.ar(sig, freq:cutoff, gain:3);
});

~reverb = RSNode(\Reverb, {|in, room=0.7|
	"In is:".post; in.postln;
	FreeVerb.ar(in, mix:0.7, room:room);
});

// Wait a sec before running (dunno why yet)
~out.connectOut;
~reverb.connectOut;
)
~saw.connectTo(~out, amp:0.1);
~saw.connectTo(~reverb, amp:0.1);
~saw => ~reverb.connectOut;
~sawLFO.connectToControlOf(~saw, \freq, 0.2);
~sawLFO.connectToControlOf(~saw, \freq, 0.7);
~squareLFO.connectToControlOf(~saw, \cutoff, 0.5);
~squareLFO.connectToControlOf(~saw, \freq, 0.5);
~squareLFO.connectToControlOf(~reverb, \room, 0.5);


~saw=>~reverb;
~saw=<~reverb;
~saw.connectOut;
~saw.disconnectOut;