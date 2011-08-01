// First create our LFO oscillator
~lfoOutBus = Bus.control(s, 1);

{Out.kr(~lfoOutBus, LFSaw.kr(freq:2))}.play;

// Now create a scaler input to map the range to the range an Oscillator freq might need
~sinFreqBus = Bus.control(s, 1);

{ |amp=1|
	Out.kr(~sinFreqBus, In.kr(~lfoOutBus) * amp);
}.play;

~finalMulAdd = { |centerValue=440, modDepth=200|
	var sig = In.kr(~sinFreqBus);
	sig = sig * modDepth;
	ReplaceOut.kr(~sinFreqBus, sig + centerValue);
}

n = {|freq = 440| SinOsc.ar(freq)}.play;
n.map(\freq, ~sinFreqScalerBus);