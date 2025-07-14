# Cognitive Synergy Usage Examples
# Phase 1.1: Scheme Cognitive Grammar Microservices Implementation

This document demonstrates how to use the Cognitive Synergy modules for bidirectional 
translation between Scheme S-expressions and AtomSpace hypergraph patterns.

## Basic Usage Examples

### 1. Creating an AtomSpace and Adding Atoms

```limbo
include "module/cognitive-synergy/atomspace.m";
atomspace := load AtomSpace AtomSpace->PATH;
atomspace->init();

# Create new AtomSpace
as := AtomSpace.new();

# Create basic atoms
robot := Atom.new("Agent", "robot");
kitchen := Atom.new("Concept", "kitchen");

# Add to AtomSpace
as.add(robot);
as.add(kitchen);

# Create a relationship
at_link := Link.new("AtLink", robot :: kitchen :: nil);
as.addlink(at_link);

sys->print("AtomSpace size: %d atoms\n", as.size());
```

### 2. Working with Cognitive Primitives

```limbo
include "module/cognitive-synergy/cognitive.m";
cognitive := load Cognitive Cognitive->PATH;
cognitive->init();

# Create cognitive grammar
cg := CognitiveGrammar.new();

# Define agentic primitives
agent := CognitivePrimitive.new(AgentType, "intelligent_robot", 0);
action := CognitivePrimitive.new(ActionType, "navigate", 2);
location := CognitivePrimitive.new(ConceptType, "target_location", 1);

cg.addprimitive(agent);
cg.addprimitive(action);
cg.addprimitive(location);

# Create reasoning rule
nav_rule := AgenticRule.new("navigation_capability");
nav_rule.addprecondition(agent);
nav_rule.addprecondition(location);
nav_rule.addpostcondition(action);
nav_rule.setweight(0.85);

cg.addrule(nav_rule);

# Perform reasoning
query := agent :: location :: nil;
result := cg.reason(query);

sys->print("Reasoning result: %d conclusions from %d premises\n", 
           len result, len query);
```

### 3. Scheme to AtomSpace Translation

```limbo
include "module/cognitive-synergy/scheme-adapter.m";
schemeadapter := load SchemeAdapter SchemeAdapter->PATH;
schemeadapter->init();

# Setup translation context
as := AtomSpace.new();
cg := CognitiveGrammar.new();
translator := Translator.new(as, cg);

# Parse Scheme expression
(sexp, err) := Sexp.parse("(implies (and premise1 premise2) conclusion)");
if (err != nil) {
    sys->print("Parse error: %s\n", err);
    return;
}

sys->print("Original Scheme: %s\n", sexp.text());

# Translate to hypergraph
atom := translator.schemetohypergraph(sexp);
if (atom != nil) {
    sys->print("Translated to atom: %s\n", atom.tostring());
}

# Translate back to Scheme
result_sexp := translator.hypergraphtoscheme(atom);
if (result_sexp != nil) {
    sys->print("Back to Scheme: %s\n", result_sexp.text());
}
```

### 4. Round-Trip Translation with Verification

```limbo
# Test round-trip translation
test_expressions := array[] of {
    "hello",
    "(and premise conclusion)", 
    "(implies (or p1 p2) (not q))",
    "(lambda (x) (apply f x))",
    "(agent robot (action move location))"
};

for (i := 0; i < len test_expressions; i++) {
    expr := test_expressions[i];
    sys->print("\nTesting: %s\n", expr);
    
    (original, err) := Sexp.parse(expr);
    if (err != nil) {
        sys->print("  Parse error: %s\n", err);
        continue;
    }
    
    (roundtrip, error) := translator.roundtrip(original);
    if (error != nil) {
        sys->print("  Round-trip error: %s\n", error);
        continue;
    }
    
    verified := translator.verify(original, roundtrip);
    if (verified) {
        sys->print("  ✓ Round-trip successful\n");
        sys->print("  Result: %s\n", roundtrip.text());
    } else {
        sys->print("  ✗ Verification failed\n");
        sys->print("  Expected: %s\n", original.text());
        sys->print("  Got: %s\n", roundtrip.text());
    }
}
```

### 5. Complex Agentic Grammar Example

```limbo
# Build sophisticated agentic reasoning system
create_advanced_grammar(): ref CognitiveGrammar
{
    cg := CognitiveGrammar.new();
    
    # Define agent types
    robot := CognitivePrimitive.new(AgentType, "autonomous_robot", 0);
    human := CognitivePrimitive.new(AgentType, "human_operator", 0);
    
    # Define capabilities
    sense := CognitivePrimitive.new(ActionType, "perceive_environment", 1);
    plan := CognitivePrimitive.new(ActionType, "generate_plan", 2);
    execute := CognitivePrimitive.new(ActionType, "execute_action", 1);
    
    # Define concepts
    environment := CognitivePrimitive.new(ConceptType, "physical_environment", 0);
    goal := CognitivePrimitive.new(ConceptType, "objective", 1);
    obstacle := CognitivePrimitive.new(ConceptType, "impediment", 1);
    
    # Define predicates
    can_sense := CognitivePrimitive.new(PredicateType, "capable_of_sensing", 2);
    can_plan := CognitivePrimitive.new(PredicateType, "capable_of_planning", 2);
    can_act := CognitivePrimitive.new(PredicateType, "capable_of_acting", 2);
    
    # Add all primitives
    primitives := array[] of {
        robot, human, sense, plan, execute,
        environment, goal, obstacle,
        can_sense, can_plan, can_act
    };
    
    for (i := 0; i < len primitives; i++)
        cg.addprimitive(primitives[i]);
    
    # Define reasoning rules
    
    # Sensing rule: robot + environment -> can_sense
    sense_rule := AgenticRule.new("sensing_capability");
    sense_rule.addprecondition(robot);
    sense_rule.addprecondition(environment);
    sense_rule.addpostcondition(can_sense);
    sense_rule.setweight(0.9);
    cg.addrule(sense_rule);
    
    # Planning rule: can_sense + goal -> can_plan
    plan_rule := AgenticRule.new("planning_capability");
    plan_rule.addprecondition(can_sense);
    plan_rule.addprecondition(goal);
    plan_rule.addpostcondition(can_plan);
    plan_rule.setweight(0.8);
    cg.addrule(plan_rule);
    
    # Execution rule: can_plan -> can_act
    exec_rule := AgenticRule.new("execution_capability");
    exec_rule.addprecondition(can_plan);
    exec_rule.addpostcondition(can_act);
    exec_rule.setweight(0.85);
    cg.addrule(exec_rule);
    
    return cg;
}

# Usage
advanced_grammar := create_advanced_grammar();
sys->print("Advanced grammar created with %d primitives\n", 
           advanced_grammar.primitives.len());

# Export to Scheme representation
grammar_sexp := AgenticPrimitiveMapper.grammartoscheme(advanced_grammar);
sys->print("Grammar as Scheme:\n%s\n", grammar_sexp.text());
```

### 6. AtomSpace Import/Export

```limbo
# Create and populate AtomSpace
as := AtomSpace.new();

# Add various atom types
concepts := array[] of { "robot", "human", "environment", "goal" };
for (i := 0; i < len concepts; i++) {
    atom := Atom.new("Concept", concepts[i]);
    as.add(atom);
}

# Add some links
robot_atom := as.find("Concept", "robot");
env_atom := as.find("Concept", "environment");
if (robot_atom != nil && env_atom != nil) {
    interaction := Link.new("InteractionLink", robot_atom :: env_atom :: nil);
    as.addlink(interaction);
}

# Export to S-expression
exported := as.export();
sys->print("Exported AtomSpace:\n%s\n", exported.text());

# Create new AtomSpace and import
as2 := AtomSpace.new();
err := as2.import(exported);
if (err == nil) {
    sys->print("Import successful. New AtomSpace size: %d\n", as2.size());
} else {
    sys->print("Import failed: %s\n", err);
}
```

## Testing Framework Usage

The test suite can be run to validate all functionality:

```limbo
include "module/cognitive-synergy/test-cognitive-synergy.m";
test := load CognitiveSynergyTest CognitiveSynergyTest->PATH;

# Run comprehensive test suite
test->init(nil, nil);
```

This will execute:
1. Basic atom translation tests
2. Simple list structure tests  
3. Nested structure translation tests
4. Cognitive primitive conversion tests
5. Agentic rule reasoning tests
6. Complex grammar integration tests

All tests use real data with no mocked interfaces, ensuring the translation 
mechanisms work correctly with actual S-expressions and AtomSpace structures.

## Integration with Existing Inferno Systems

The cognitive synergy modules integrate seamlessly with Inferno's existing infrastructure:

- **File System**: AtomSpace can be serialized to/from files using standard Inferno I/O
- **Network**: Cognitive grammars can be transmitted across the network using 9P protocol
- **Concurrent Processes**: Each AtomSpace can run in separate Limbo threads
- **Module System**: Standard Inferno module loading and dependency management

## Extension and Customization

The modular design supports easy extension:

1. **Custom Primitive Types**: Add new cognitive primitive categories
2. **Advanced Reasoning**: Implement backward chaining, abduction, etc.
3. **Truth Value Systems**: Support probabilistic or fuzzy logic
4. **Optimization**: Add indexing and caching for large AtomSpaces
5. **Visualization**: Create graphical representations of hypergraphs

This foundation enables building sophisticated cognitive reasoning systems 
while maintaining full compatibility with both Scheme symbolic processing 
and AtomSpace hypergraph operations within the Inferno distributed environment.