~osc = RoutableSynth(\osc, {|freq=440|SinOsc.ar(freq)});
~osc => \Out;

~lfo = RoutableSynth(\lfo, {|freq=4|SinOsc.kr(freq)});
~osc@\freq <= ~lfo;
~osc@\freq +- 200;

RoutableSynthGraph.defaultGraph.snapshot.asCompileString;


{|freq=440|SinOsc.ar(freq)}.asSynthDef(name:\RSosc).add;
{|freq=4|SinOsc.kr(freq)}.asSynthDef(name:\RSlfo).add;

~snapshot = "Dictionary[ ('synths' -> List[ [ 'osc', 'RSosc' ], [ 'lfo', 'RSlfo' ] ]), ('params' -> Dictionary[ (\"Out.a_in.centerValue\" -> 0.0), (\"lfo=>osc.freq\" -> 1), (\"osc=>Out.a_in\" -> 1), (\"osc.freq.modDepth\" -> 200), (\"osc.freq.centerValue\" -> 440.0), (\"lfo.freq.modDepth\" -> 1), (\"lfo.freq.centerValue\" -> 4.0), (\"Out.a_in.modDepth\" -> 1) ]) ]".interpret;

~george = RSPreset(~snapshot, \George).apply;
~steve = RSPreset(~snapshot, \Steve).apply;
~larry = RSPreset(~snapshot, \Larry).apply;
~harry = RSPreset(~snapshot, \Harry).apply;

~p.parentGraph.synthsByName[\osc]@\freq +- 400
~p.parentGraph.synthsByName[\osc]@\freq <= 1000

RoutableSynthGraph.defaultGraph.graphGroup.free