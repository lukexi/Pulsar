(
~durations = [1, 1, 1, 1, 1, 1, 1];
~pitchBuffer = Buffer.loadCollection(s, [440, 880, 220, 1000, 550, 770, 100, 660]);
~durationBuffer = Buffer.loadCollection(s, ~durations);
~envDuration = ~durations.sum;
)
(
s.makeBundle(0.2, {
	~graph = RSGraph(\pitchTestGraph);
	~graph.addSynth(\OutEnvelope, \RSFadeEnvelope, [\i_duration, ~envDuration, \i_fadeTime, 0.3]);
	~graph.addSynth(\Sin1, \RSSinOsc);
	~graph.addSynth(\Saw1, \RSSawOsc);
	~graph.addSynth(\LFO1, \RSSinLFO);
	~graph.addSynth(\PitchEnvGen, \RSDemandEnvGen, [\i_pitchBufferNumber, ~pitchBuffer.bufnum,\i_durationBufferNumber,  ~durationBuffer.bufnum]);
	
	~graph@\OutEnvelope => \Out;
	~graph@\Saw1 => (~graph@\OutEnvelope);
	~graph@\Sin1 => (~graph@\OutEnvelope);
	~graph@\PitchEnvGen => (~graph@\Saw1@\freq);
	~graph@\PitchEnvGen => (~graph@\Sin1@\freq);
	// Vibrato ÑÊwe scale the LFO rather than adjust the Saw1's modDepth so the PitchEnvGen will scale correctly
	(~graph@\LFO1@\freq) <= 10;
	(~graph@\Saw1@\freq) <= (~graph@\LFO1 * 10);
	(~graph@\Sin1@\freq) <= (~graph@\LFO1 * 50);
});
)

~graph.synthMetadataAsJSON;
~graph.snapshot.asJSONString;
(s:1)[\s]

~preset = RSPreset.new(~graph.snapshot, 'boobs')
~preset.apply((
	OutEnvelope:[\i_duration, ~envDuration, \i_fadeTime, 0.3], 
	PitchEnvGen:[\i_pitchBufferNumber, ~pitchBuffer.bufnum,\i_durationBufferNumber,  ~durationBuffer.bufnum])
);