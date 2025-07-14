AtomSpace: module
{
	PATH:	con "/dis/lib/cognitive-synergy/atomspace.dis";

	# Core AtomSpace types for hypergraph representation
	Atom: adt {
		id: big;
		type: string;
		name: string;
		value: ref Sexp;
		tv: ref TruthValue;

		new: fn(type: string, name: string): ref Atom;
		setvalue: fn(a: self ref Atom, value: ref Sexp);
		settruthvalue: fn(a: self ref Atom, tv: ref TruthValue);
		tostring: fn(a: self ref Atom): string;
		tosexp: fn(a: self ref Atom): ref Sexp;
		fromstring: fn(s: string): ref Atom;
		fromsexp: fn(e: ref Sexp): ref Atom;
	};

	# Truth value representation for uncertain reasoning
	TruthValue: adt {
		strength: real;
		confidence: real;

		new: fn(strength, confidence: real): ref TruthValue;
		combine: fn(tv1, tv2: self ref TruthValue): ref TruthValue;
		tostring: fn(tv: self ref TruthValue): string;
		tosexp: fn(tv: self ref TruthValue): ref Sexp;
	};

	# Link atoms for hypergraph connections
	Link: adt {
		atom: ref Atom;
		outgoing: list of ref Atom;

		new: fn(type: string, outgoing: list of ref Atom): ref Link;
		arity: fn(l: self ref Link): int;
		getoutgoing: fn(l: self ref Link): list of ref Atom;
		tosexp: fn(l: self ref Link): ref Sexp;
		fromsexp: fn(e: ref Sexp): ref Link;
	};

	# AtomSpace container and operations
	AtomSpace: adt {
		atoms: ref Hash->HashTable[big, ref Atom];
		links: ref Hash->HashTable[big, ref Link];
		index: ref Hash->HashTable[string, list of ref Atom];

		new: fn(): ref AtomSpace;
		add: fn(as: self ref AtomSpace, atom: ref Atom): ref Atom;
		addlink: fn(as: self ref AtomSpace, link: ref Link): ref Link;
		find: fn(as: self ref AtomSpace, type, name: string): ref Atom;
		findall: fn(as: self ref AtomSpace, type: string): list of ref Atom;
		remove: fn(as: self ref AtomSpace, atom: ref Atom): int;
		clear: fn(as: self ref AtomSpace);
		size: fn(as: self ref AtomSpace): int;
		export: fn(as: self ref AtomSpace): ref Sexp;
		import: fn(as: self ref AtomSpace, e: ref Sexp): string;
	};

	init: fn();
};