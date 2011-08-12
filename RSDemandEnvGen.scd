(
(
	\RSDemandEnvGen:{|i_pitchBufferNumber, i_durationBufferNumber, gate=0, reset=1|
		DemandEnvGen.kr(
	        level:Dbufrd(
                i_pitchBufferNumber,
                Dseries(0, 1, BufFrames.kr(i_pitchBufferNumber))
            ),
            dur:Dbufrd(
                i_durationBufferNumber,
                Dseries(0, 1, BufFrames.kr(i_durationBufferNumber))
            ),
            gate:gate,
            reset:reset
        );
	},
	\RSFadeEnvelope:{|a_in, i_duration, i_fadeTime, gate=0|
		a_in * EnvGen.ar(
            envelope:Env.linen(
                sustainTime:i_duration,
                releaseTime:i_fadeTime
            ),
            gate:gate
        );
    },
	\RSSinOsc:{|freq|SinOsc.ar(freq)},
	\RSSawOsc:{|freq|Saw.ar(freq)},
	\RSSinLFO:{|freq=4|SinOsc.kr(freq)}
).keysValuesDo{|name, graphFunc|graphFunc.asSynthDef(name:name).add.writeDefFile}
)

(
~durations = [1, 1, 1, 1, 1, 1, 1, 1];
~pitchBuffer = Buffer.loadCollection(s, [440, 880, 220, 1000, 550, 770, 100, 660]);
~durationBuffer = Buffer.loadCollection(s, ~durations);
~envDuration = ~durations.sum;
)
(
~graph = RoutableSynthGraph(\pitchTestGraph);
~graph.addSynth(\OutEnvelope, \RSFadeEnvelope, [\i_duration, ~envDuration, \i_fadeTime, 0.3]);
~graph.addSynth(\Sin1, \RSSinOsc);
~graph.addSynth(\Saw1, \RSSawOsc);
~graph.addSynth(\LFO1, \RSSinLFO);
~graph.addSynth(\PitchEnvGen, \RSDemandEnvGen, [\i_pitchBufferNumber, ~pitchBuffer.bufnum,\i_durationBufferNumber,  ~durationBuffer.bufnum]);
)
~graph@\OutEnvelope => \Out;
~graph@\Saw1 => (~graph@\OutEnvelope);
~graph@\Sin1 => (~graph@\OutEnvelope);

// Vibrato
(~graph@\Saw1@\freq) <= (~graph@\LFO1 * 10);



~graph@\PitchEnvGen => (~graph@\Saw1@\freq);
~graph@\PitchEnvGen => (~graph@\Sin1@\freq);

(
~graph@\PitchEnvGen@\gate <= 1;
~graph@\OutEnvelope@\gate <= 1;
)

(
~graph@\PitchEnvGen@\reset <= 0;
~graph@\PitchEnvGen@\reset <= 1;
~graph@\OutEnvelope@\gate <= -1;
~graph@\OutEnvelope@\gate <= 1;
)