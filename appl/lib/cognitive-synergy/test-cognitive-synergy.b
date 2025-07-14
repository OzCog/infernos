implement CognitiveSynergyTest;

#
# Cognitive Synergy Test: Round-trip translation tests for Scheme-AtomSpace integration
# Phase 1.1: Scheme Cognitive Grammar Microservices Implementation
#

include "sys.m";
	sys: Sys;

include "draw.m";

include "sexprs.m";
	sexprs: Sexprs;
	Sexp: import sexprs;

include "../../module/cognitive-synergy/atomspace.m";
	atomspace: AtomSpace;
	Atom, TruthValue, Link, AtomSpace: import atomspace;

include "../../module/cognitive-synergy/cognitive.m";
	cognitive: Cognitive;
	CognitivePrimitive, AgenticRule, CognitiveGrammar: import cognitive;
	AgentType, ActionType, PredicateType, ConceptType, RelationType: import cognitive;

include "../../module/cognitive-synergy/scheme-adapter.m";
	schemeadapter: SchemeAdapter;
	Translator, AgenticPrimitiveMapper: import schemeadapter;

CognitiveSynergyTest: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

init(ctxt: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	sexprs = load Sexprs Sexprs->PATH;
	atomspace = load AtomSpace AtomSpace->PATH;
	cognitive = load Cognitive Cognitive->PATH;
	schemeadapter = load SchemeAdapter SchemeAdapter->PATH;
	
	if (sexprs == nil) {
		sys->print("cannot load %s: %r\n", Sexprs->PATH);
		return;
	}
	if (atomspace == nil) {
		sys->print("cannot load %s: %r\n", AtomSpace->PATH);
		return;
	}
	if (cognitive == nil) {
		sys->print("cannot load %s: %r\n", Cognitive->PATH);
		return;
	}
	if (schemeadapter == nil) {
		sys->print("cannot load %s: %r\n", SchemeAdapter->PATH);
		return;
	}
	
	sexprs->init();
	atomspace->init();
	cognitive->init();
	schemeadapter->init();
	
	sys->print("Starting Cognitive Synergy Round-Trip Translation Tests\n");
	sys->print("=" x 60 + "\n");
	
	# Run test suite
	runtests();
	
	sys->print("\nAll tests completed.\n");
}

runtests()
{
	testcount := 0;
	passcount := 0;
	
	# Test 1: Basic atom translation
	sys->print("\nTest 1: Basic Atom Translation\n");
	testcount++;
	if (test_basic_atom_translation())
		passcount++;
	
	# Test 2: Simple list translation  
	sys->print("\nTest 2: Simple List Translation\n");
	testcount++;
	if (test_simple_list_translation())
		passcount++;
		
	# Test 3: Nested structure translation
	sys->print("\nTest 3: Nested Structure Translation\n");
	testcount++;
	if (test_nested_structure_translation())
		passcount++;
		
	# Test 4: Cognitive primitive translation
	sys->print("\nTest 4: Cognitive Primitive Translation\n");
	testcount++;
	if (test_cognitive_primitive_translation())
		passcount++;
		
	# Test 5: Agentic rule translation
	sys->print("\nTest 5: Agentic Rule Translation\n");
	testcount++;
	if (test_agentic_rule_translation())
		passcount++;
		
	# Test 6: Complex grammar translation
	sys->print("\nTest 6: Complex Grammar Translation\n");
	testcount++;
	if (test_complex_grammar_translation())
		passcount++;
	
	sys->print("\n" + "=" x 60 + "\n");
	sys->print("Test Results: %d/%d passed\n", passcount, testcount);
	if (passcount == testcount)
		sys->print("SUCCESS: All tests passed!\n");
	else
		sys->print("FAILURE: %d tests failed\n", testcount - passcount);
}

test_basic_atom_translation(): int
{
	# Create test atomspace and grammar
	as := AtomSpace.new();
	cg := CognitiveGrammar.new();
	translator := Translator.new(as, cg);
	
	# Test simple symbol
	(original_sexp, err) := Sexp.parse("hello");
	if (err != nil) {
		sys->print("  FAIL: Cannot parse test S-expression: %s\n", err);
		return 0;
	}
	
	sys->print("  Original: %s\n", original_sexp.text());
	
	# Round-trip translation
	(result_sexp, error) := translator.roundtrip(original_sexp);
	if (error != nil) {
		sys->print("  FAIL: Round-trip error: %s\n", error);
		return 0;
	}
	
	sys->print("  Round-trip: %s\n", result_sexp.text());
	
	# Verify
	if (translator.verify(original_sexp, result_sexp)) {
		sys->print("  PASS: Basic atom translation successful\n");
		return 1;
	} else {
		sys->print("  FAIL: Round-trip verification failed\n");
		return 0;
	}
}

test_simple_list_translation(): int
{
	as := AtomSpace.new();
	cg := CognitiveGrammar.new();
	translator := Translator.new(as, cg);
	
	# Test simple list
	(original_sexp, err) := Sexp.parse("(and hello world)");
	if (err != nil) {
		sys->print("  FAIL: Cannot parse test S-expression: %s\n", err);
		return 0;
	}
	
	sys->print("  Original: %s\n", original_sexp.text());
	
	(result_sexp, error) := translator.roundtrip(original_sexp);
	if (error != nil) {
		sys->print("  FAIL: Round-trip error: %s\n", error);
		return 0;
	}
	
	sys->print("  Round-trip: %s\n", result_sexp.text());
	
	if (translator.verify(original_sexp, result_sexp)) {
		sys->print("  PASS: Simple list translation successful\n");
		return 1;
	} else {
		sys->print("  FAIL: Round-trip verification failed\n");
		return 0;
	}
}

test_nested_structure_translation(): int
{
	as := AtomSpace.new();
	cg := CognitiveGrammar.new();
	translator := Translator.new(as, cg);
	
	# Test nested structure
	(original_sexp, err) := Sexp.parse("(implies (and premise1 premise2) conclusion)");
	if (err != nil) {
		sys->print("  FAIL: Cannot parse test S-expression: %s\n", err);
		return 0;
	}
	
	sys->print("  Original: %s\n", original_sexp.text());
	
	(result_sexp, error) := translator.roundtrip(original_sexp);
	if (error != nil) {
		sys->print("  FAIL: Round-trip error: %s\n", error);
		return 0;
	}
	
	sys->print("  Round-trip: %s\n", result_sexp.text());
	
	if (translator.verify(original_sexp, result_sexp)) {
		sys->print("  PASS: Nested structure translation successful\n");
		return 1;
	} else {
		sys->print("  FAIL: Round-trip verification failed\n");
		return 0;
	}
}

test_cognitive_primitive_translation(): int
{
	as := AtomSpace.new();
	cg := CognitiveGrammar.new();
	
	# Create test cognitive primitives
	agent_prim := CognitivePrimitive.new(AgentType, "robot", 0);
	action_prim := CognitivePrimitive.new(ActionType, "move", 2);
	concept_prim := CognitivePrimitive.new(ConceptType, "location", 1);
	
	cg.addprimitive(agent_prim);
	cg.addprimitive(action_prim);
	cg.addprimitive(concept_prim);
	
	# Test primitive to S-expression conversion
	agent_sexp := AgenticPrimitiveMapper.primitivetoscheme(agent_prim);
	action_sexp := AgenticPrimitiveMapper.primitivetoscheme(action_prim);
	concept_sexp := AgenticPrimitiveMapper.primitivetoscheme(concept_prim);
	
	sys->print("  Agent primitive: %s\n", agent_sexp.text());
	sys->print("  Action primitive: %s\n", action_sexp.text());
	sys->print("  Concept primitive: %s\n", concept_sexp.text());
	
	# Verify conversion
	if (agent_sexp != nil && action_sexp != nil && concept_sexp != nil) {
		sys->print("  PASS: Cognitive primitive translation successful\n");
		return 1;
	} else {
		sys->print("  FAIL: Cognitive primitive translation failed\n");
		return 0;
	}
}

test_agentic_rule_translation(): int
{
	as := AtomSpace.new();
	cg := CognitiveGrammar.new();
	
	# Create test rule
	rule := AgenticRule.new("movement_rule");
	
	# Add preconditions
	agent_prim := CognitivePrimitive.new(AgentType, "robot", 0);
	location_prim := CognitivePrimitive.new(ConceptType, "location", 1);
	rule.addprecondition(agent_prim);
	rule.addprecondition(location_prim);
	
	# Add postconditions  
	action_prim := CognitivePrimitive.new(ActionType, "move", 2);
	rule.addpostcondition(action_prim);
	
	rule.setweight(0.8);
	
	# Test rule to S-expression conversion
	rule_sexp := AgenticPrimitiveMapper.ruletoscheme(rule);
	sys->print("  Rule: %s\n", rule_sexp.text());
	
	# Test rule application
	context: list of ref CognitivePrimitive;
	context = agent_prim :: context;
	context = location_prim :: context;
	
	if (rule.matches(context)) {
		newcontext := rule.apply(context);
		sys->print("  Rule application successful, context size: %d -> %d\n", 
		          len context, len newcontext);
		sys->print("  PASS: Agentic rule translation successful\n");
		return 1;
	} else {
		sys->print("  FAIL: Rule does not match context\n");
		return 0;
	}
}

test_complex_grammar_translation(): int
{
	as := AtomSpace.new();
	cg := CognitiveGrammar.new();
	
	# Build complex grammar
	# Add primitives
	agent := CognitivePrimitive.new(AgentType, "intelligent_agent", 0);
	move_action := CognitivePrimitive.new(ActionType, "navigate", 2);
	location := CognitivePrimitive.new(ConceptType, "spatial_location", 1);
	can_move := CognitivePrimitive.new(PredicateType, "can_navigate", 2);
	
	cg.addprimitive(agent);
	cg.addprimitive(move_action);
	cg.addprimitive(location);
	cg.addprimitive(can_move);
	
	# Add navigation rule
	nav_rule := AgenticRule.new("navigation_capability");
	nav_rule.addprecondition(agent);
	nav_rule.addprecondition(location);
	nav_rule.addpostcondition(can_move);
	nav_rule.setweight(0.9);
	
	cg.addrule(nav_rule);
	
	# Add action rule
	action_rule := AgenticRule.new("execute_navigation");
	action_rule.addprecondition(can_move);
	action_rule.addpostcondition(move_action);
	action_rule.setweight(0.7);
	
	cg.addrule(action_rule);
	
	# Test grammar export
	grammar_sexp := AgenticPrimitiveMapper.grammartoscheme(cg);
	sys->print("  Grammar structure: %s\n", grammar_sexp.text());
	
	# Test reasoning
	query: list of ref CognitivePrimitive;
	query = agent :: query;
	query = location :: query;
	
	result := cg.reason(query);
	sys->print("  Reasoning: %d premises -> %d conclusions\n", len query, len result);
	
	# Test AtomSpace integration
	sys->print("  AtomSpace size: %d atoms\n", cg.atomspace.size());
	
	if (len result > len query && cg.atomspace.size() >= 4) {
		sys->print("  PASS: Complex grammar translation and reasoning successful\n");
		return 1;
	} else {
		sys->print("  FAIL: Complex grammar translation failed\n");
		return 0;
	}
}