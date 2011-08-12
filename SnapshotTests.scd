~osc = RoutableSynth(\osc, {|freq=440|SinOsc.ar(freq)});
~osc => \Out;

~lfo = RoutableSynth(\lfo, {|freq=4|SinOsc.kr(freq)});
~osc@\freq <= ~lfo;
~osc@\freq +- 200;

~dist = RoutableSynth(\dist, );

RoutableSynthGraph.defaultGraph.snapshot.asCompileString;

(
(
	\RSSinOsc:{|freq=440|SinOsc.ar(freq)},
	\RSSawOsc:{|freq=440|Saw.ar(freq)},
	\RSSinLFO:{|freq=4|SinOsc.kr(freq)},
	\RSTanH:{|a_in, preamp=10| (a_in * preamp).tanh / preamp},
	\RSMoogFF:{|a_in, freq, gain| MoogFF.ar(a_in, freq, gain)}
).keysValuesDo{|name, graphFunc|graphFunc.asSynthDef(name:name).add.writeDefFile}
)

~graph = RoutableSynthGraph(\testGraph);
~graph.addSynth(\Sin1, \RSSinOsc);
~graph.addSynth(\Saw1, \RSSawOsc);
~graph.addSynth(\Saw2, \RSSawOsc);
~graph.addSynth(\MoogFF1, \RSMoogFF);
~graph.addSynth(\SinLFO1, \RSSinLFO);
~graph.addSynth(\TanH1, \RSTanH);

(~graph@\Saw1) => (~graph@\MoogFF1)
(~graph@\Saw2) => (~graph@\MoogFF1)
~graph@\MoogFF1 =< \Out

~graph@\Saw1@\freq <= (~graph@\SinLFO1)
~graph@\Saw1@\freq +- -200

~graph@\Saw2@\freq <= (~graph@\SinLFO1)
~graph@\Saw2@\freq +- -300

~graph@\SinLFO1@\freq <= 2

(~graph@\MoogFF1@\freq) <= (~graph@\SinLFO1)
(~graph@\MoogFF1@\freq) +- 1500
~graph@\MoogFF1@\gain <= 1

(~graph@\MoogFF1) => (~graph@\TanH1)
(~graph@\TanH1) => \Out
(~graph@\TanH1@\preamp) <= 10

~graph.snapshot.asCompileString

~snapshot = "Dictionary[ ('synths' -> List[ [ 'osc', 'RSosc' ], [ 'lfo', 'RSlfo' ] ]), ('params' -> Dictionary[ (\"Out.a_in.centerValue\" -> 0.0), (\"lfo=>osc.freq\" -> 1), (\"osc=>Out.a_in\" -> 1), (\"osc.freq.modDepth\" -> 200), (\"osc.freq.centerValue\" -> 440.0), (\"lfo.freq.modDepth\" -> 1), (\"lfo.freq.centerValue\" -> 4.0), (\"Out.a_in.modDepth\" -> 1) ]) ]".interpret;
)
~george = RSPreset(~snapshot, \George).apply;
~steve = RSPreset(~snapshot, \Steve).apply;
~larry = RSPreset(~snapshot, \Larry).apply;
~harry = RSPreset(~snapshot, \Harry).apply;

~george.parentGraph.synthsByName[\osc]@\freq +- 8
~george.parentGraph.synthsByName[\osc]@\freq <= 440
~george.parentGraph.synthsByName[\osc]@\freq <= 8800
~george.parentGraph.synthsByName[\osc]@\freq <= 770
~george.parentGraph.synthsByName[\lfo]@\freq <= 15
~george.parentGraph.synthsByName[\dist]@\preamp <= 2
~george.parentGraph.lagTime = 3

~george.parentGraph.addSynth(\dist, \RSdist);

~george.parentGraph.synthsByName[\osc].disconnect(~george.parentGraph.out)

~george.parentGraph.synthsByName[\dist] <= ~george.parentGraph.synthsByName[\osc]
~george.parentGraph.synthsByName[\dist] => \Out;



~george.parentGraph.snapshot

RoutableSynthGraph.defaultGraph.graphGroup.free