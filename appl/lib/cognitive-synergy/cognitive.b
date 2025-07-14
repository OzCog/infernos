implement Cognitive;

#
# Cognitive: Agentic grammar primitives for cognitive reasoning
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

include "../../module/cognitive-synergy/cognitive.m";
include "../../module/cognitive-synergy/atomspace.m";
	atomspace: AtomSpace;
	Atom, TruthValue, Link, AtomSpace: import atomspace;

init()
{
	sys = load Sys Sys->PATH;
	sexprs = load Sexprs Sexprs->PATH;
	hash = load Hash Hash->PATH;
	lists = load Lists Lists->PATH;
	atomspace = load AtomSpace AtomSpace->PATH;
	
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
	
	sexprs->init();
	hash->init();
	atomspace->init();
}

# Generate unique cognitive primitive IDs
primid_counter := big 1;

nextprimid(): big
{
	return primid_counter++;
}

# CognitivePrimitive implementation
CognitivePrimitive.new(primtype: int, symbol: string, arity: int): ref CognitivePrimitive
{
	cp := ref CognitivePrimitive;
	cp.id = nextprimid();
	cp.primtype = primtype;
	cp.symbol = symbol;
	cp.arity = arity;
	cp.semantics = nil;
	return cp;
}

CognitivePrimitive.setsemantics(cp: self ref CognitivePrimitive, sem: ref Sexp)
{
	cp.semantics = sem;
}

CognitivePrimitive.toatom(cp: self ref CognitivePrimitive): ref Atom
{
	typename := "CognitivePrimitive";
	case cp.primtype {
	AgentType =>
		typename = "Agent";
	ActionType =>
		typename = "Action";
	PredicateType =>
		typename = "Predicate";
	ConceptType =>
		typename = "Concept";
	RelationType =>
		typename = "Relation";
	}
	
	atom := Atom.new(typename, cp.symbol);
	if (cp.semantics != nil)
		atom.setvalue(cp.semantics);
	return atom;
}

CognitivePrimitive.froматom(atom: ref Atom): ref CognitivePrimitive
{
	primtype := ConceptType;  # default
	case atom.type {
	"Agent" =>
		primtype = AgentType;
	"Action" =>
		primtype = ActionType;
	"Predicate" =>
		primtype = PredicateType;
	"Concept" =>
		primtype = ConceptType;
	"Relation" =>
		primtype = RelationType;
	}
	
	cp := CognitivePrimitive.new(primtype, atom.name, 0);
	if (atom.value != nil)
		cp.setsemantics(atom.value);
	return cp;
}

CognitivePrimitive.tosexp(cp: self ref CognitivePrimitive): ref Sexp
{
	typename := "concept";
	case cp.primtype {
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
	
	elements: list of ref Sexp;
	elements = ref Sexp.String("primitive") :: elements;
	elements = ref Sexp.String(typename) :: elements;
	elements = ref Sexp.String(cp.symbol) :: elements;
	elements = ref Sexp.String(sys->sprint("%d", cp.arity)) :: elements;
	
	if (cp.semantics != nil)
		elements = cp.semantics :: elements;
	
	return ref Sexp.List(lists->reverse(elements));
}

CognitivePrimitive.fromsexp(e: ref Sexp): ref CognitivePrimitive
{
	if (!e.islist() || len e.els() < 4)
		return nil;
		
	elems := e.els();
	if (hd elems == nil || !tagof(hd elems) == tagof(Sexp.String("")) ||
	    (hd elems).s != "primitive")
		return nil;
	
	elems = tl elems;
	typename := (hd elems).s;
	elems = tl elems;
	symbol := (hd elems).s;
	elems = tl elems;
	arity := int (hd elems).s;
	
	primtype := ConceptType;  # default
	case typename {
	"agent" =>
		primtype = AgentType;
	"action" =>
		primtype = ActionType;
	"predicate" =>
		primtype = PredicateType;
	"concept" =>
		primtype = ConceptType;
	"relation" =>
		primtype = RelationType;
	}
	
	cp := CognitivePrimitive.new(primtype, symbol, arity);
	
	elems = tl elems;
	if (elems != nil)
		cp.setsemantics(hd elems);
	
	return cp;
}

# Generate unique rule IDs
ruleid_counter := big 1;

nextruleid(): big
{
	return ruleid_counter++;
}

# AgenticRule implementation
AgenticRule.new(name: string): ref AgenticRule
{
	ar := ref AgenticRule;
	ar.id = nextruleid();
	ar.name = name;
	ar.preconditions = nil;
	ar.postconditions = nil;
	ar.weight = 1.0;
	return ar;
}

AgenticRule.addprecondition(ar: self ref AgenticRule, prim: ref CognitivePrimitive)
{
	ar.preconditions = prim :: ar.preconditions;
}

AgenticRule.addpostcondition(ar: self ref AgenticRule, prim: ref CognitivePrimitive)
{
	ar.postconditions = prim :: ar.postconditions;
}

AgenticRule.setweight(ar: self ref AgenticRule, w: real)
{
	ar.weight = w;
}

AgenticRule.matches(ar: self ref AgenticRule, context: list of ref CognitivePrimitive): int
{
	# Simple matching - check if all preconditions are in context
	for (preconds := ar.preconditions; preconds != nil; preconds = tl preconds) {
		precond := hd preconds;
		found := 0;
		for (ctx := context; ctx != nil; ctx = tl ctx) {
			if ((hd ctx).symbol == precond.symbol) {
				found = 1;
				break;
			}
		}
		if (!found)
			return 0;
	}
	return 1;
}

AgenticRule.apply(ar: self ref AgenticRule, context: list of ref CognitivePrimitive): list of ref CognitivePrimitive
{
	if (!ar.matches(context))
		return context;
		
	# Add postconditions to context
	newcontext := context;
	for (postconds := ar.postconditions; postconds != nil; postconds = tl postconds) {
		postcond := hd postconds;
		# Check if postcondition already exists
		found := 0;
		for (ctx := newcontext; ctx != nil; ctx = tl ctx) {
			if ((hd ctx).symbol == postcond.symbol) {
				found = 1;
				break;
			}
		}
		if (!found)
			newcontext = postcond :: newcontext;
	}
	
	return newcontext;
}

AgenticRule.tosexp(ar: self ref AgenticRule): ref Sexp
{
	elements: list of ref Sexp;
	elements = ref Sexp.String("rule") :: elements;
	elements = ref Sexp.String(ar.name) :: elements;
	elements = ref Sexp.String(sys->sprint("%.3f", ar.weight)) :: elements;
	
	# Preconditions
	pre_list: list of ref Sexp;
	for (preconds := ar.preconditions; preconds != nil; preconds = tl preconds)
		pre_list = (hd preconds).tosexp() :: pre_list;
	elements = ref Sexp.List(lists->reverse(pre_list)) :: elements;
	
	# Postconditions
	post_list: list of ref Sexp;
	for (postconds := ar.postconditions; postconds != nil; postconds = tl postconds)
		post_list = (hd postconds).tosexp() :: post_list;
	elements = ref Sexp.List(lists->reverse(post_list)) :: elements;
	
	return ref Sexp.List(lists->reverse(elements));
}

AgenticRule.fromsexp(e: ref Sexp): ref AgenticRule
{
	if (!e.islist() || len e.els() < 5)
		return nil;
		
	elems := e.els();
	if (hd elems == nil || !tagof(hd elems) == tagof(Sexp.String("")) ||
	    (hd elems).s != "rule")
		return nil;
	
	elems = tl elems;
	name := (hd elems).s;
	elems = tl elems;
	weight := real (hd elems).s;
	
	ar := AgenticRule.new(name);
	ar.setweight(weight);
	
	elems = tl elems;
	pre_sexp := hd elems;
	if (pre_sexp.islist()) {
		for (psexp := pre_sexp.els(); psexp != nil; psexp = tl psexp) {
			prim := CognitivePrimitive.fromsexp(hd psexp);
			if (prim != nil)
				ar.addprecondition(prim);
		}
	}
	
	elems = tl elems;
	post_sexp := hd elems;
	if (post_sexp.islist()) {
		for (psexp := post_sexp.els(); psexp != nil; psexp = tl psexp) {
			prim := CognitivePrimitive.fromsexp(hd psexp);
			if (prim != nil)
				ar.addpostcondition(prim);
		}
	}
	
	return ar;
}

# CognitiveGrammar implementation
CognitiveGrammar.new(): ref CognitiveGrammar
{
	cg := ref CognitiveGrammar;
	cg.primitives = hash->new(1009, nil);
	cg.rules = nil;
	cg.atomspace = AtomSpace.new();
	return cg;
}

CognitiveGrammar.addprimitive(cg: self ref CognitiveGrammar, prim: ref CognitivePrimitive)
{
	cg.primitives.add(prim.symbol, prim);
	# Also add to atomspace
	atom := prim.toatom();
	cg.atomspace.add(atom);
}

CognitiveGrammar.addrule(cg: self ref CognitiveGrammar, rule: ref AgenticRule)
{
	cg.rules = rule :: cg.rules;
}

CognitiveGrammar.findprimitive(cg: self ref CognitiveGrammar, symbol: string): ref CognitivePrimitive
{
	found := cg.primitives.find(symbol);
	if (found == nil)
		return nil;
	return cast[ref CognitivePrimitive] found;
}

CognitiveGrammar.parse(cg: self ref CognitiveGrammar, input: ref Sexp): list of ref CognitivePrimitive
{
	# Simple parsing - convert S-expression to cognitive primitives
	result: list of ref CognitivePrimitive;
	
	if (input.islist()) {
		for (elems := input.els(); elems != nil; elems = tl elems) {
			elem := hd elems;
			if (tagof(elem) == tagof(Sexp.String(""))) {
				prim := cg.findprimitive(elem.s);
				if (prim != nil)
					result = prim :: result;
			} else if (elem.islist()) {
				subprims := cg.parse(elem);
				result = lists->append(result, subprims);
			}
		}
	} else if (tagof(input) == tagof(Sexp.String(""))) {
		prim := cg.findprimitive(input.s);
		if (prim != nil)
			result = prim :: nil;
	}
	
	return lists->reverse(result);
}

CognitiveGrammar.generate(cg: self ref CognitiveGrammar, prims: list of ref CognitivePrimitive): ref Sexp
{
	# Convert cognitive primitives back to S-expression
	elements: list of ref Sexp;
	
	for (ps := prims; ps != nil; ps = tl ps) {
		prim := hd ps;
		elements = ref Sexp.String(prim.symbol) :: elements;
	}
	
	return ref Sexp.List(lists->reverse(elements));
}

CognitiveGrammar.reason(cg: self ref CognitiveGrammar, query: list of ref CognitivePrimitive): list of ref CognitivePrimitive
{
	# Simple forward chaining reasoning
	context := query;
	changed := 1;
	
	while (changed) {
		changed = 0;
		for (rules := cg.rules; rules != nil; rules = tl rules) {
			rule := hd rules;
			if (rule.matches(context)) {
				newcontext := rule.apply(context);
				if (len newcontext > len context) {
					context = newcontext;
					changed = 1;
				}
			}
		}
	}
	
	return context;
}

CognitiveGrammar.export(cg: self ref CognitiveGrammar): ref Sexp
{
	elements: list of ref Sexp;
	elements = ref Sexp.String("grammar") :: elements;
	
	# Export primitives
	prim_list: list of ref Sexp;
	for (i := 0; i < cg.primitives.len(); i++) {
		(symbol, prim) := cg.primitives.itemno(i);
		if (prim != nil) {
			p := cast[ref CognitivePrimitive] prim;
			prim_list = p.tosexp() :: prim_list;
		}
	}
	elements = ref Sexp.List(lists->reverse(prim_list)) :: elements;
	
	# Export rules
	rule_list: list of ref Sexp;
	for (rules := cg.rules; rules != nil; rules = tl rules)
		rule_list = (hd rules).tosexp() :: rule_list;
	elements = ref Sexp.List(lists->reverse(rule_list)) :: elements;
	
	# Export atomspace
	elements = cg.atomspace.export() :: elements;
	
	return ref Sexp.List(lists->reverse(elements));
}

CognitiveGrammar.import(cg: self ref CognitiveGrammar, e: ref Sexp): string
{
	if (!e.islist() || len e.els() < 4)
		return "Invalid grammar format";
		
	elems := e.els();
	if (hd elems == nil || !tagof(hd elems) == tagof(Sexp.String("")) ||
	    (hd elems).s != "grammar")
		return "Not a grammar";
	
	# Clear existing content
	cg.primitives = hash->new(1009, nil);
	cg.rules = nil;
	cg.atomspace.clear();
	
	elems = tl elems;
	
	# Import primitives
	prims_sexp := hd elems;
	if (prims_sexp.islist()) {
		for (psexp := prims_sexp.els(); psexp != nil; psexp = tl psexp) {
			prim := CognitivePrimitive.fromsexp(hd psexp);
			if (prim != nil)
				cg.addprimitive(prim);
		}
	}
	
	elems = tl elems;
	
	# Import rules
	rules_sexp := hd elems;
	if (rules_sexp.islist()) {
		for (rsexp := rules_sexp.els(); rsexp != nil; rsexp = tl rsexp) {
			rule := AgenticRule.fromsexp(hd rsexp);
			if (rule != nil)
				cg.addrule(rule);
		}
	}
	
	elems = tl elems;
	
	# Import atomspace
	if (elems != nil) {
		as_sexp := hd elems;
		err := cg.atomspace.import(as_sexp);
		if (err != nil)
			return "Failed to import atomspace: " + err;
	}
	
	return nil;
}