# Cognitive Synergy API Documentation
# Phase 1.1: Scheme Cognitive Grammar Microservices Implementation

## Overview

The Cognitive Synergy modules provide a modular foundation for integrating Scheme-like symbolic representations with AtomSpace hypergraph structures for agentic reasoning. The system implements bidirectional translation between Scheme S-expressions and hypergraph patterns.

## Core Modules

### AtomSpace Module (`atomspace.m`)

The AtomSpace module provides hypergraph representation for cognitive reasoning:

#### Core Types

**Atom**: Basic node in the hypergraph
- `id`: Unique identifier  
- `type`: Atom type (e.g., "Concept", "Agent", "Action")
- `name`: Symbolic name
- `value`: Optional S-expression value
- `tv`: Truth value for uncertain reasoning

**TruthValue**: Represents uncertain knowledge
- `strength`: Confidence in the truth (0.0 to 1.0)
- `confidence`: Certainty of the strength estimate (0.0 to 1.0)

**Link**: Represents relationships between atoms
- `atom`: The link's atom representation
- `outgoing`: List of connected atoms

**AtomSpace**: Container for the hypergraph
- `atoms`: Hash table of all atoms
- `links`: Hash table of all links  
- `index`: Type-based index for efficient lookup

#### Usage Example

```limbo
# Create AtomSpace
as := AtomSpace.new();

# Create atoms
robot := Atom.new("Agent", "robot");
location := Atom.new("Concept", "kitchen");

# Add to AtomSpace
as.add(robot);
as.add(location);

# Create link
move_link := Link.new("ActionLink", robot :: location :: nil);
as.addlink(move_link);

# Export to S-expression
sexp := as.export();
```

### Cognitive Module (`cognitive.m`)

Implements agentic grammar primitives for cognitive reasoning:

#### Core Types

**CognitivePrimitive**: Basic unit of cognitive reasoning
- `primtype`: Type (Agent, Action, Predicate, Concept, Relation)
- `symbol`: Symbolic representation
- `arity`: Number of arguments
- `semantics`: Optional semantic definition

**AgenticRule**: Grammar rules for cognitive composition  
- `preconditions`: Required cognitive primitives
- `postconditions`: Inferred cognitive primitives
- `weight`: Rule confidence weight

**CognitiveGrammar**: Complete grammar system
- `primitives`: Collection of cognitive primitives
- `rules`: Set of agentic rules
- `atomspace`: Integrated hypergraph representation

#### Usage Example

```limbo
# Create grammar
cg := CognitiveGrammar.new();

# Define primitives
agent := CognitivePrimitive.new(AgentType, "robot", 0);
action := CognitivePrimitive.new(ActionType, "navigate", 2);

cg.addprimitive(agent);
cg.addprimitive(action);

# Define rule
rule := AgenticRule.new("navigation_rule");
rule.addprecondition(agent);
rule.addpostcondition(action);

cg.addrule(rule);

# Reasoning
query := agent :: nil;
result := cg.reason(query);
```

### SchemeAdapter Module (`scheme-adapter.m`)

Provides bidirectional translation between Scheme and AtomSpace:

#### Core Types

**Translator**: Main translation interface
- `schemetohypergraph()`: Convert S-expression to AtomSpace
- `hypergraphtoscheme()`: Convert AtomSpace to S-expression  
- `roundtrip()`: Full round-trip translation with verification
- `verify()`: Structural equality verification

**TranslationContext**: Maintains conversion state
- Symbol-to-atom mappings
- Reverse atom-to-symbol mappings
- Associated grammar and AtomSpace

#### Usage Example

```limbo
# Setup
as := AtomSpace.new();
cg := CognitiveGrammar.new();
translator := Translator.new(as, cg);

# Parse Scheme
(sexp, err) := Sexp.parse("(implies (and premise1 premise2) conclusion)");

# Forward translation
atom := translator.schemetohypergraph(sexp);

# Reverse translation  
result_sexp := translator.hypergraphtoscheme(atom);

# Round-trip verification
(roundtrip_sexp, error) := translator.roundtrip(sexp);
verified := translator.verify(sexp, roundtrip_sexp);
```

## Translation Mappings

### Scheme to AtomSpace

| Scheme Form | AtomSpace Type | Description |
|-------------|----------------|-------------|
| `symbol` | ConceptNode | Basic symbol to concept |
| `(and ...)` | AndLink | Logical conjunction |
| `(or ...)` | OrLink | Logical disjunction |  
| `(not ...)` | NotLink | Logical negation |
| `(implies ...)` | ImplicationLink | Logical implication |
| `(lambda ...)` | LambdaLink | Function abstraction |
| `(apply ...)` | EvaluationLink | Function application |

### Cognitive Primitives

| Primitive Type | Symbol Prefix | Usage |
|----------------|---------------|-------|
| Agent | `(agent ...)` | Autonomous entities |
| Action | `(action ...)` | Behaviors and operations |
| Predicate | `(predicate ...)` | Truth-valued functions |
| Concept | `(concept ...)` | Abstract categories |
| Relation | `(relation ...)` | Connections between entities |

## Testing Framework

The `test-cognitive-synergy.b` module provides comprehensive tests:

1. **Basic Atom Translation**: Simple symbol round-trip
2. **Simple List Translation**: Basic list structure preservation
3. **Nested Structure Translation**: Complex hierarchical forms
4. **Cognitive Primitive Translation**: Agentic primitive conversion
5. **Agentic Rule Translation**: Rule-based reasoning validation
6. **Complex Grammar Translation**: Full system integration

### Running Tests

```limbo
# Load and run test module
test := load CognitiveSynergyTest CognitiveSynergyTest->PATH;
test->init(nil, nil);
```

## Design Principles

1. **Real Data Only**: No mocked interfaces - all tests use live data
2. **Bidirectional Translation**: Preserves structural and semantic information
3. **Modular Architecture**: Clean separation of concerns
4. **AtomSpace Integration**: Native hypergraph representation
5. **Agentic Grammar**: Support for autonomous reasoning patterns

## Extension Points

The system is designed for extensibility:

- **Custom Primitive Types**: Add new cognitive primitive categories
- **Translation Rules**: Define custom Scheme-to-AtomSpace mappings
- **Reasoning Algorithms**: Implement advanced inference methods
- **Truth Value Systems**: Support different uncertainty models

## Error Handling

All translation operations return error information:
- Parse errors from malformed S-expressions
- Translation failures with diagnostic messages
- Verification failures for round-trip consistency
- Module loading errors with clear failure reasons

This foundation enables building sophisticated cognitive reasoning systems while maintaining compatibility with both Scheme symbolic processing and AtomSpace hypergraph operations.