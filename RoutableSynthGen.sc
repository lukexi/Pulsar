UGenRoutableSynth : RoutableSynth {
	
	*new { |uGenClass, rate=\kr|
		
		var possibleRates = [rate] ++ [\ar, \kr, \ir];
		var validRate = nil;
		
		possibleRates.do {|rate|
			if (this.uGenHasMethodFor(rate) && validRate.isNil) {
				validRate = rate;
			};
		};
		
		if (validRate.isNil) {
			"Couldn't find valid rate for uGen %".format(uGenClass).postln;
			^nil;
		}
		
		^super.new(uGenClass.name);
	}
	
	*uGenHasMethodFor {|uGenClass, methodName|
		^uGenClass.class.findRespondingMethodFor(methodName);
	}
	
	*uGenClasses {
		^this.subclassesOf(UGen);
	}
	
	*subclassesOf {|aClass|
		// via dumpSublassList
		var list, listCollector;
		// recursive function to collect class objects
		listCollector = { arg node, l;
			l.add(node);
			node.subclasses.do({ arg n; listCollector.value(n, l) });
		};
		list = List.new;
		listCollector.value(aClass, list);	// do the recursion
		list.sort({ arg a, b; a.name < b.name });
		list;
	}
}