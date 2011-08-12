~subclassesOf = {|aClass|
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
};

~subclassesOf.(UGen).do({|aClass|aClass.name.postln;aClass.class.dumpInterface})
~subclassesOf.(UGen).do({|aClass|
	var arMethod = aClass.class.findRespondingMethodFor('ar');
	var krMethod = aClass.class.findRespondingMethodFor('kr');
	if (arMethod.notNil && krMethod.notNil) { aClass.categories.postln; };
	if (arMethod.notNil) { aClass.name.post; " ".post; arMethod.argNames[1..].postln; };
	if (krMethod.notNil) { aClass.name.post; " ".post; krMethod.argNames[1..].postln; };
});
UGen.dumpSubclassList

Wrap.class.findRespondingMethodFor('ar')