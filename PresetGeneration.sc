RoutableSynth.allSynthsByName.do {|aSynth|
	"***** % *****".format(aSynth.name).postln;
	"->Control connections for %".format(aSynth.name).postln;
	aSynth.controls.values.do { |control|
		"    ".post; "% @ % +/- %".format(control.name, control.centerValue, control.modDepth).postln;
		control.connectedNodes.keysValuesDo { |aSynth, aConnector|
			var amp = control.connectedNodeAmps[aSynth];
			"    ".post.post; "^- % * %".format(aSynth.name, amp).postln;
		}
	};
	"".postln;
	
	"<-Audio out connections for %".format(aSynth.name).postln;
	aSynth.outConnections.keysValuesDo { |aSynth, outConnection|
		
		"    ".post; if (aSynth.isKindOf(Symbol)) 
				{aSynth.post;} {aSynth.name.post;};
		"@ %".format(aSynth.outConnectionAmps[aSynth]).postln;
		"    ".post; outConnection.postln;
	};
	"".postln.postln;
};