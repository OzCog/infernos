SchemeAdapter: module
{
	PATH:	con "/dis/lib/cognitive-synergy/scheme-adapter.dis";

	# Scheme adapter for agentic grammar AtomSpace integration
	
	# Translation context for maintaining conversion state
	TranslationContext: adt {
		atomspace: ref AtomSpace;
		grammar: ref CognitiveGrammar;
		symbols: ref Hash->HashTable[string, ref Atom];
		reverse_symbols: ref Hash->HashTable[big, string];
		
		new: fn(as: ref AtomSpace, cg: ref CognitiveGrammar): ref TranslationContext;
		clear: fn(tc: self ref TranslationContext);
		addmapping: fn(tc: self ref TranslationContext, symbol: string, atom: ref Atom);
		findatom: fn(tc: self ref TranslationContext, symbol: string): ref Atom;
		findsymbol: fn(tc: self ref TranslationContext, atomid: big): string;
	};

	# Forward translation: Scheme S-expressions to AtomSpace hypergraph
	SexpToHypergraph: adt {
		context: ref TranslationContext;
		
		new: fn(context: ref TranslationContext): ref SexpToHypergraph;
		translate: fn(sth: self ref SexpToHypergraph, sexp: ref Sexp): ref Atom;
		translatelist: fn(sth: self ref SexpToHypergraph, sexps: list of ref Sexp): list of ref Atom;
		createlink: fn(sth: self ref SexpToHypergraph, linktype: string, outgoing: list of ref Atom): ref Link;
		createnode: fn(sth: self ref SexpToHypergraph, nodetype: string, name: string): ref Atom;
	};

	# Reverse translation: AtomSpace hypergraph to Scheme S-expressions  
	HypergraphToSexp: adt {
		context: ref TranslationContext;
		
		new: fn(context: ref TranslationContext): ref HypergraphToSexp;
		translate: fn(hts: self ref HypergraphToSexp, atom: ref Atom): ref Sexp;
		translatelist: fn(hts: self ref HypergraphToSexp, atoms: list of ref Atom): list of ref Sexp;
		atomtosexp: fn(hts: self ref HypergraphToSexp, atom: ref Atom): ref Sexp;
		linktosexp: fn(hts: self ref HypergraphToSexp, link: ref Link): ref Sexp;
	};

	# Bidirectional translation interface
	Translator: adt {
		forward: ref SexpToHypergraph;
		reverse: ref HypergraphToSexp;
		context: ref TranslationContext;
		
		new: fn(as: ref AtomSpace, cg: ref CognitiveGrammar): ref Translator;
		schemetohypergraph: fn(t: self ref Translator, sexp: ref Sexp): ref Atom;
		hypergraphtoscheme: fn(t: self ref Translator, atom: ref Atom): ref Sexp;
		roundtrip: fn(t: self ref Translator, sexp: ref Sexp): (ref Sexp, string);
		verify: fn(t: self ref Translator, original: ref Sexp, roundtrip: ref Sexp): int;
	};

	# Standard agentic primitive translations
	AgenticPrimitiveMapper: adt {
		# Agent primitives
		translateagent: fn(symbol: string, args: list of ref Sexp): ref CognitivePrimitive;
		translateaction: fn(symbol: string, args: list of ref Sexp): ref CognitivePrimitive;
		translatepredicate: fn(symbol: string, args: list of ref Sexp): ref CognitivePrimitive;
		translateconcept: fn(symbol: string, args: list of ref Sexp): ref CognitivePrimitive;
		translaterelation: fn(symbol: string, args: list of ref Sexp): ref CognitivePrimitive;
		
		# Reverse mappings
		primitivetoscheme: fn(prim: ref CognitivePrimitive): ref Sexp;
		ruletoscheme: fn(rule: ref AgenticRule): ref Sexp;
		grammartoscheme: fn(grammar: ref CognitiveGrammar): ref Sexp;
	};

	init: fn();
};