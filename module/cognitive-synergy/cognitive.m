Cognitive: module
{
	PATH:	con "/dis/lib/cognitive-synergy/cognitive.dis";

	# Cognitive grammar primitives for agentic reasoning
	
	# Basic cognitive primitive types
	AgentType: con iota;
	ActionType: con iota;
	PredicateType: con iota;
	ConceptType: con iota;
	RelationType: con iota;

	# Cognitive primitive representation
	CognitivePrimitive: adt {
		id: big;
		primtype: int;
		symbol: string;
		arity: int;
		semantics: ref Sexp;
		
		new: fn(primtype: int, symbol: string, arity: int): ref CognitivePrimitive;
		setsemantics: fn(cp: self ref CognitivePrimitive, sem: ref Sexp);
		toatom: fn(cp: self ref CognitivePrimitive): ref Atom;
		froматom: fn(atom: ref Atom): ref CognitivePrimitive;
		tosexp: fn(cp: self ref CognitivePrimitive): ref Sexp;
		fromsexp: fn(e: ref Sexp): ref CognitivePrimitive;
	};

	# Agentic grammar rules for cognitive reasoning
	AgenticRule: adt {
		id: big;
		name: string;
		preconditions: list of ref CognitivePrimitive;
		postconditions: list of ref CognitivePrimitive;
		weight: real;
		
		new: fn(name: string): ref AgenticRule;
		addprecondition: fn(ar: self ref AgenticRule, prim: ref CognitivePrimitive);
		addpostcondition: fn(ar: self ref AgenticRule, prim: ref CognitivePrimitive);
		setweight: fn(ar: self ref AgenticRule, w: real);
		matches: fn(ar: self ref AgenticRule, context: list of ref CognitivePrimitive): int;
		apply: fn(ar: self ref AgenticRule, context: list of ref CognitivePrimitive): list of ref CognitivePrimitive;
		tosexp: fn(ar: self ref AgenticRule): ref Sexp;
		fromsexp: fn(e: ref Sexp): ref AgenticRule;
	};

	# Cognitive grammar for agentic composition
	CognitiveGrammar: adt {
		primitives: ref Hash->HashTable[string, ref CognitivePrimitive];
		rules: list of ref AgenticRule;
		atomspace: ref AtomSpace;
		
		new: fn(): ref CognitiveGrammar;
		addprimitive: fn(cg: self ref CognitiveGrammar, prim: ref CognitivePrimitive);
		addrule: fn(cg: self ref CognitiveGrammar, rule: ref AgenticRule);
		findprimitive: fn(cg: self ref CognitiveGrammar, symbol: string): ref CognitivePrimitive;
		parse: fn(cg: self ref CognitiveGrammar, input: ref Sexp): list of ref CognitivePrimitive;
		generate: fn(cg: self ref CognitiveGrammar, prims: list of ref CognitivePrimitive): ref Sexp;
		reason: fn(cg: self ref CognitiveGrammar, query: list of ref CognitivePrimitive): list of ref CognitivePrimitive;
		export: fn(cg: self ref CognitiveGrammar): ref Sexp;
		import: fn(cg: self ref CognitiveGrammar, e: ref Sexp): string;
	};

	init: fn();
};