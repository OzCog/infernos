implement SchemeAdapter;

#
# SchemeAdapter: Bidirectional translation between Scheme and AtomSpace hypergraph
# Phase 1.1: Scheme Cognitive Grammar Microservices Implementation
#

include "sys.m";
	sys: Sys;

include "sexprs.m";
	sexprs: Sexprs;
	Sexp: import sexprs;

include "hash.m";
	hash: Hash;

include "lists.m";
	lists: Lists;

include "../../module/cognitive-synergy/scheme-adapter.m";
include "../../module/cognitive-synergy/atomspace.m";
	atomspace: AtomSpace;
	Atom, TruthValue, Link, AtomSpace: import atomspace;

include "../../module/cognitive-synergy/cognitive.m";
	cognitive: Cognitive;
	CognitivePrimitive, AgenticRule, CognitiveGrammar: import cognitive;
	AgentType, ActionType, PredicateType, ConceptType, RelationType: import cognitive;

init()
{
	sys = load Sys Sys->PATH;
	sexprs = load Sexprs Sexprs->PATH;
	hash = load Hash Hash->PATH;
	lists = load Lists Lists->PATH;
	atomspace = load AtomSpace AtomSpace->PATH;
	cognitive = load Cognitive Cognitive->PATH;
	
	if (sexprs == nil) {
		sys->print("cannot load %s: %r\n", Sexprs->PATH);
		exit;
	}
	if (hash == nil) {
		sys->print("cannot load %s: %r\n", Hash->PATH);
		exit;
	}
	if (lists == nil) {
		sys->print("cannot load %s: %r\n", Lists->PATH);
		exit;
	}
	if (atomspace == nil) {
		sys->print("cannot load %s: %r\n", AtomSpace->PATH);
		exit;
	}
	if (cognitive == nil) {
		sys->print("cannot load %s: %r\n", Cognitive->PATH);
		exit;
	}
	
	sexprs->init();
	hash->init();
	atomspace->init();
	cognitive->init();
}

# TranslationContext implementation
TranslationContext.new(as: ref AtomSpace, cg: ref CognitiveGrammar): ref TranslationContext
{
	tc := ref TranslationContext;
	tc.atomspace = as;
	tc.grammar = cg;
	tc.symbols = hash->new(1009, nil);
	tc.reverse_symbols = hash->new(1009, nil);
	return tc;
}

TranslationContext.clear(tc: self ref TranslationContext)
{
	tc.symbols = hash->new(1009, nil);
	tc.reverse_symbols = hash->new(1009, nil);
}

TranslationContext.addmapping(tc: self ref TranslationContext, symbol: string, atom: ref Atom)
{
	tc.symbols.add(symbol, atom);
	tc.reverse_symbols.add(atom.id, symbol);
}

TranslationContext.findatom(tc: self ref TranslationContext, symbol: string): ref Atom
{
	found := tc.symbols.find(symbol);
	if (found == nil)
		return nil;
	return cast[ref Atom] found;
}

TranslationContext.findsymbol(tc: self ref TranslationContext, atomid: big): string
{
	found := tc.reverse_symbols.find(atomid);
	if (found == nil)
		return nil;
	return cast[string] found;
}

# SexpToHypergraph implementation
SexpToHypergraph.new(context: ref TranslationContext): ref SexpToHypergraph
{
	sth := ref SexpToHypergraph;
	sth.context = context;
	return sth;
}

SexpToHypergraph.translate(sth: self ref SexpToHypergraph, sexp: ref Sexp): ref Atom
{
	if (sexp == nil)
		return nil;
		
	case tagof(sexp) {
	tagof(Sexp.String("")) =>
		# Simple string to atom conversion
		symbol := sexp.s;
		
		# Check if already mapped
		existing := sth.context.findatom(symbol);
		if (existing != nil)
			return existing;
		
		# Create new atom
		atom := sth.createnode("Concept", symbol);
		sth.context.addmapping(symbol, atom);
		return atom;
		
	tagof(Sexp.List(nil)) =>
		# List to link conversion
		elems := sexp.els();
		if (elems == nil)
			return nil;
			
		# First element is the link type/operator
		head := hd elems;
		if (tagof(head) != tagof(Sexp.String("")))
			return nil;
			
		linktype := head.s;
		rest := tl elems;
		
		# Translate the arguments
		outgoing := sth.translatelist(rest);
		if (outgoing == nil && rest != nil)
			return nil;
		
		# Create link
		link := sth.createlink(linktype, outgoing);
		return link.atom;
		
	* =>
		return nil;
	}
}

SexpToHypergraph.translatelist(sth: self ref SexpToHypergraph, sexps: list of ref Sexp): list of ref Atom
{
	result: list of ref Atom;
	
	for (ss := sexps; ss != nil; ss = tl ss) {
		atom := sth.translate(hd ss);
		if (atom != nil)
			result = atom :: result;
	}
	
	return lists->reverse(result);
}

SexpToHypergraph.createlink(sth: self ref SexpToHypergraph, linktype: string, outgoing: list of ref Atom): ref Link
{
	# Map common Scheme forms to AtomSpace link types
	mappedtype := linktype;
	case linktype {
	"and" =>
		mappedtype = "AndLink";
	"or" =>
		mappedtype = "OrLink";
	"not" =>
		mappedtype = "NotLink";
	"implies" =>
		mappedtype = "ImplicationLink";
	"if" =>
		mappedtype = "ConditionalLink";
	"lambda" =>
		mappedtype = "LambdaLink";
	"apply" =>
		mappedtype = "EvaluationLink";
	"list" =>
		mappedtype = "ListLink";
	* =>
		mappedtype = linktype + "Link";
	}
	
	link := Link.new(mappedtype, outgoing);
	sth.context.atomspace.addlink(link);
	return link;
}

SexpToHypergraph.createnode(sth: self ref SexpToHypergraph, nodetype: string, name: string): ref Atom
{
	atom := Atom.new(nodetype, name);
	sth.context.atomspace.add(atom);
	return atom;
}

# HypergraphToSexp implementation
HypergraphToSexp.new(context: ref TranslationContext): ref HypergraphToSexp
{
	hts := ref HypergraphToSexp;
	hts.context = context;
	return hts;
}

HypergraphToSexp.translate(hts: self ref HypergraphToSexp, atom: ref Atom): ref Sexp
{
	if (atom == nil)
		return nil;
	
	# Check if this atom is part of a link
	linkfound := hts.context.atomspace.links.find(atom.id);
	if (linkfound != nil) {
		link := cast[ref Link] linkfound;
		return hts.linktosexp(link);
	}
	
	# Regular atom to s-expression
	return hts.atomtosexp(atom);
}

HypergraphToSexp.translatelist(hts: self ref HypergraphToSexp, atoms: list of ref Atom): list of ref Sexp
{
	result: list of ref Sexp;
	
	for (as := atoms; as != nil; as = tl as) {
		sexp := hts.translate(hd as);
		if (sexp != nil)
			result = sexp :: result;
	}
	
	return lists->reverse(result);
}

HypergraphToSexp.atomtosexp(hts: self ref HypergraphToSexp, atom: ref Atom): ref Sexp
{
	# Check for mapped symbol first
	symbol := hts.context.findsymbol(atom.id);
	if (symbol != nil)
		return ref Sexp.String(symbol);
	
	# Use atom name
	return ref Sexp.String(atom.name);
}

HypergraphToSexp.linktosexp(hts: self ref HypergraphToSexp, link: ref Link): ref Sexp
{
	# Map AtomSpace link types back to Scheme forms
	linktype := link.atom.type;
	schemetype := linktype;
	
	case linktype {
	"AndLink" =>
		schemetype = "and";
	"OrLink" =>
		schemetype = "or";
	"NotLink" =>
		schemetype = "not";
	"ImplicationLink" =>
		schemetype = "implies";
	"ConditionalLink" =>
		schemetype = "if";
	"LambdaLink" =>
		schemetype = "lambda";
	"EvaluationLink" =>
		schemetype = "apply";
	"ListLink" =>
		schemetype = "list";
	* =>
		if (len linktype > 4 && linktype[len linktype-4:] == "Link")
			schemetype = linktype[:len linktype-4];
		else
			schemetype = linktype;
	}
	
	elements: list of ref Sexp;
	elements = ref Sexp.String(schemetype) :: elements;
	
	# Add outgoing atoms
	outgoing_sexps := hts.translatelist(link.outgoing);
	elements = lists->append(elements, outgoing_sexps);
	
	return ref Sexp.List(elements);
}

# Translator implementation
Translator.new(as: ref AtomSpace, cg: ref CognitiveGrammar): ref Translator
{
	t := ref Translator;
	t.context = TranslationContext.new(as, cg);
	t.forward = SexpToHypergraph.new(t.context);
	t.reverse = HypergraphToSexp.new(t.context);
	return t;
}

Translator.schemetohypergraph(t: self ref Translator, sexp: ref Sexp): ref Atom
{
	return t.forward.translate(sexp);
}

Translator.hypergraphtoscheme(t: self ref Translator, atom: ref Atom): ref Sexp
{
	return t.reverse.translate(atom);
}

Translator.roundtrip(t: self ref Translator, sexp: ref Sexp): (ref Sexp, string)
{
	# Forward translation
	atom := t.schemetohypergraph(sexp);
	if (atom == nil)
		return (nil, "Forward translation failed");
	
	# Reverse translation
	result := t.hypergraphtoscheme(atom);
	if (result == nil)
		return (nil, "Reverse translation failed");
	
	return (result, nil);
}

Translator.verify(t: self ref Translator, original: ref Sexp, roundtrip: ref Sexp): int
{
	# Simple structural equality check
	if (original == nil && roundtrip == nil)
		return 1;
	if (original == nil || roundtrip == nil)
		return 0;
	
	case tagof(original) {
	tagof(Sexp.String("")) =>
		if (tagof(roundtrip) != tagof(Sexp.String("")))
			return 0;
		return original.s == roundtrip.s;
		
	tagof(Sexp.List(nil)) =>
		if (tagof(roundtrip) != tagof(Sexp.List(nil)))
			return 0;
		
		orig_elems := original.els();
		rt_elems := roundtrip.els();
		
		if (len orig_elems != len rt_elems)
			return 0;
		
		while (orig_elems != nil && rt_elems != nil) {
			if (!t.verify(hd orig_elems, hd rt_elems))
				return 0;
			orig_elems = tl orig_elems;
			rt_elems = tl rt_elems;
		}
		
		return 1;
		
	* =>
		return 0;
	}
}

# AgenticPrimitiveMapper implementation
AgenticPrimitiveMapper.translateagent(symbol: string, args: list of ref Sexp): ref CognitivePrimitive
{
	cp := CognitivePrimitive.new(AgentType, symbol, len args);
	if (args != nil) {
		# Create semantics from arguments
		semantics := ref Sexp.List(args);
		cp.setsemantics(semantics);
	}
	return cp;
}

AgenticPrimitiveMapper.translateaction(symbol: string, args: list of ref Sexp): ref CognitivePrimitive
{
	cp := CognitivePrimitive.new(ActionType, symbol, len args);
	if (args != nil) {
		semantics := ref Sexp.List(args);
		cp.setsemantics(semantics);
	}
	return cp;
}

AgenticPrimitiveMapper.translatepredicate(symbol: string, args: list of ref Sexp): ref CognitivePrimitive
{
	cp := CognitivePrimitive.new(PredicateType, symbol, len args);
	if (args != nil) {
		semantics := ref Sexp.List(args);
		cp.setsemantics(semantics);
	}
	return cp;
}

AgenticPrimitiveMapper.translateconcept(symbol: string, args: list of ref Sexp): ref CognitivePrimitive
{
	cp := CognitivePrimitive.new(ConceptType, symbol, len args);
	if (args != nil) {
		semantics := ref Sexp.List(args);
		cp.setsemantics(semantics);
	}
	return cp;
}

AgenticPrimitiveMapper.translaterelation(symbol: string, args: list of ref Sexp): ref CognitivePrimitive
{
	cp := CognitivePrimitive.new(RelationType, symbol, len args);
	if (args != nil) {
		semantics := ref Sexp.List(args);
		cp.setsemantics(semantics);
	}
	return cp;
}

AgenticPrimitiveMapper.primitivetoscheme(prim: ref CognitivePrimitive): ref Sexp
{
	elements: list of ref Sexp;
	
	# Add primitive type prefix
	typename := "concept";
	case prim.primtype {
	AgentType =>
		typename = "agent";
	ActionType =>
		typename = "action";
	PredicateType =>
		typename = "predicate";
	ConceptType =>
		typename = "concept";
	RelationType =>
		typename = "relation";
	}
	
	elements = ref Sexp.String(typename) :: elements;
	elements = ref Sexp.String(prim.symbol) :: elements;
	
	# Add semantics if present
	if (prim.semantics != nil) {
		if (prim.semantics.islist()) {
			elements = lists->append(elements, prim.semantics.els());
		} else {
			elements = prim.semantics :: elements;
		}
	}
	
	return ref Sexp.List(elements);
}

AgenticPrimitiveMapper.ruletoscheme(rule: ref AgenticRule): ref Sexp
{
	elements: list of ref Sexp;
	elements = ref Sexp.String("rule") :: elements;
	elements = ref Sexp.String(rule.name) :: elements;
	
	# Preconditions
	pre_list: list of ref Sexp;
	for (preconds := rule.preconditions; preconds != nil; preconds = tl preconds)
		pre_list = AgenticPrimitiveMapper.primitivetoscheme(hd preconds) :: pre_list;
	elements = ref Sexp.List(lists->reverse(pre_list)) :: elements;
	
	# Postconditions
	post_list: list of ref Sexp;
	for (postconds := rule.postconditions; postconds != nil; postconds = tl postconds)
		post_list = AgenticPrimitiveMapper.primitivetoscheme(hd postconds) :: post_list;
	elements = ref Sexp.List(lists->reverse(post_list)) :: elements;
	
	return ref Sexp.List(elements);
}

AgenticPrimitiveMapper.grammartoscheme(grammar: ref CognitiveGrammar): ref Sexp
{
	elements: list of ref Sexp;
	elements = ref Sexp.String("grammar") :: elements;
	
	# Primitives
	prim_list: list of ref Sexp;
	for (i := 0; i < grammar.primitives.len(); i++) {
		(symbol, prim) := grammar.primitives.itemno(i);
		if (prim != nil) {
			p := cast[ref CognitivePrimitive] prim;
			prim_list = AgenticPrimitiveMapper.primitivetoscheme(p) :: prim_list;
		}
	}
	elements = ref Sexp.List(lists->reverse(prim_list)) :: elements;
	
	# Rules
	rule_list: list of ref Sexp;
	for (rules := grammar.rules; rules != nil; rules = tl rules)
		rule_list = AgenticPrimitiveMapper.ruletoscheme(hd rules) :: rule_list;
	elements = ref Sexp.List(lists->reverse(rule_list)) :: elements;
	
	return ref Sexp.List(elements);
}