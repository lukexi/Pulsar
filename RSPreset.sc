RSPreset {
	<>params;

	*new {|params|
		super.newCopyArgs(params).init;
	}

	morphTo {|otherPreset, time=5, steps=100.0|
		fork {
			steps.do { |i|
				this.apply(this.params.blend(otherPreset, i/steps));
				(time/steps).wait;
			};
		};
	}
		
	apply {
		this.params.associationsDo {|association|
			var routingString = association.key;
			var amp = association.value;
			var success = this.attemptConnection(routingString, amp);
			if (success.not) {
				this.attemptSetting(routingString, amp);
			};
		};
	};

	attemptConnection {|routingString, amp|
		var connection = routingString.find("=>");
		var sourceName, sourceSynth;
		var destinationString, destinationName, destinationSynth;
		var controlLocation, controlName;
		if (connection.notNil) {
			sourceName = routingString.copyRange(0, connection-1);
			'found connection from '.post;sourceName.postln;
			sourceSynth = RoutableSynth.allSynthsByName[sourceName.asSymbol];
			
			destinationString = routingString.copyRange(
				connection+2, routingString.size);
			
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
		^connection.notNil;
	}

	attemptSetting {|routingString, amp|
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
			{'centerValue'} {
				synth.setCenterValueOfControl(controlName.asSymbol, amp)
			}
			{'modDepth'} {
				synth.setModDepthOfControl(controlName.asSymbol, amp)
			};
	}
}