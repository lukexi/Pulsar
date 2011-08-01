// if => but no ., use .in
// if two .s, set modDepth or centerValue of control (also, warp?)
// if one ., use as shortcut to setting the centerValue?

// Insert Ramp into all MulAdd units to slew from what to butt

~preset1 = (
	"LFSaw.freq":5,
	"LFSaw=>Saw.freq":0.8,
	"LFPulse.freq":1,
	"LFPulse=>Saw.freq":0.5,
	"LFPulse=>Saw.cutoff":0.3,
	"Saw.freq.modDepth":500,
	"Saw.freq.centerValue":1000,
	"Saw=>Out":0,
	"Saw=>Reverb":1
).as(Dictionary); // so blend will work (IdentityDictionaries can't match string keys)

~preset2 = (
	"LFSaw.freq":0.2,
	"LFSaw=>Saw.freq":0.5,
	"LFPulse.freq":0.1,
	"LFPulse=>Saw.freq":0.1,
	"LFPulse=>Saw.cutoff":0.9,
	"Saw.freq.modDepth":200,
	"Saw.freq.centerValue":300,
	"Saw=>Out":1,
	"Saw=>Reverb":0
).as(Dictionary);

~morph.(~preset1, ~preset2, time:10);
~morph.(~preset2, ~preset1, time:5);

~applyPreset.(~preset1);
~applyPreset.(~preset2);

(

~morph = {|preset1, preset2, time=5|
	var steps = 100.0;
	fork {
		steps.do { |i|
			~applyPreset.(preset1.blend(preset2, i/steps));
			(time/steps).wait;
		};
	};
};

~applyPreset = {|aPreset|
	aPreset.associationsDo {|association|
		var routingString = association.key;
		var amp = association.value;
		var success = ~attemptConnection.(routingString, amp);
		if (success.not) {
			~attemptSetting.(routingString, amp);
		};
	};
};

~attemptConnection = {|routingString, amp|
	var connection = routingString.find("=>");
	var sourceName, sourceSynth;
	var destinationString, destinationName, destinationSynth;
	var controlLocation, controlName;
	if (connection.notNil) {
		sourceName = routingString.copyRange(0, connection-1);
		'found connection from '.post;sourceName.postln;
		sourceSynth = RoutableSynth.allSynthsByName[sourceName.asSymbol];
		
		destinationString = routingString.copyRange(connection+2, routingString.size);
		
		controlLocation = destinationString.find(".");
		
		if (controlLocation.notNil) {
			destinationName = destinationString.copyRange(0, controlLocation-1);
			destinationSynth = RoutableSynth.allSynthsByName[destinationName.asSymbol];
			controlName = destinationString.copyRange(controlLocation+1, destinationString.size);
			sourceSynth.connectToControlOf(destinationSynth, controlName.asSymbol, amp);
			"Parsed connecting % to %'s % at amp %".format(
				sourceName, destinationName, controlName, amp).postln;
		} {
			destinationName = destinationString.asSymbol;
			destinationSynth = RoutableSynth.allSynthsByName[destinationName];
			sourceSynth.connectTo(destinationSynth, amp);
			"Parsed connecting % to % at amp %".format(sourceName, destinationName, amp);
		};
	};
	connection.notNil;
};

~attemptSetting = {|routingString, amp|
	var synthName, controlName, metaName;
	var synth;
	var dots = routingString.split($.);
	if (dots.size == 3) {
		#synthName, controlName, metaName = dots;
	} {
		#synthName, controlName = dots;
		metaName = 'centerValue';
	};
	
	"Parsed setting %'s % % to %".format(synthName, controlName, metaName, amp).postln;
	
	synth = RoutableSynth.allSynthsByName[synthName.asSymbol];
	
	switch (metaName)
		{'centerValue'} {synth.setCenterValueOfControl(controlName.asSymbol, amp)}
		{'modDepth'} {synth.setModDepthOfControl(controlName.asSymbol, amp)};
};
)