# Cognitive Synergy API Documentation
# Phase 1.1: Scheme Cognitive Grammar Microservices Implementation
# Phase 1.2: Tensor Fragment Architecture Design

## Overview

The Cognitive Synergy modules provide a modular foundation for integrating Scheme-like symbolic representations with AtomSpace hypergraph structures for agentic reasoning. The system now includes tensor fragment architecture for encoding agent/state as hypergraph nodes/links with systematic 5-dimensional tensor representation.

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

### TensorFragment Module (`tensor.m`)

Provides systematic encoding of agent/state as hypergraph nodes/links using 5-dimensional tensors:

#### Core Types

**TensorFragment**: Main tensor representation with 5D shape
- `shape`: `[modality, depth, context, salience, autonomy_index]`
- `data`: Tensor data values (real array)
- `agent_id`: Associated agent identifier
- `state_type`: Type of cognitive state being encoded
- `prime_encoding`: Prime factorization encoding of shape

**PrimeFactors**: Prime factorization mapping for efficient storage
- `encode()`: Convert 5D shape to single integer using prime factorization
- `decode()`: Convert prime encoding back to 5D shape
- `validate()`: Validate prime-encoded tensor shapes

**TensorValidator**: Comprehensive validation mechanisms
- `validateshape()`: Ensure 5D tensor with valid dimension ranges
- `validatedata()`: Verify data consistency with tensor shape
- `validatefull()`: Complete tensor fragment validation

**TensorCollection**: Management of multiple tensor fragments
- Index by agent ID and state type
- Bulk export/import operations
- Efficient lookup and filtering

#### Tensor Shape Specification

| Dimension | Range | Description |
|-----------|-------|-------------|
| Modality | 0-15 | Sensory/cognitive modality |
| Depth | 0-31 | Processing depth level |
| Context | 0-63 | Contextual state identifier |
| Salience | 0-99 | Attention/importance weight |
| Autonomy Index | 0-9 | Level of agent autonomy |

#### Usage Example

```limbo
# Create tensor fragment
tf := TensorFragment.new(1, 2, 5, 8, 3);  # Visual, medium depth, context 5, high salience, moderate autonomy
tf.setagent("robot_navigator");
tf.setstate("obstacle_avoidance");

# Set tensor data
data := array[60] of real;  # 1*2*5*8*1 = 80, but using 1*2*5*6*1 = 60 for example
for(i := 0; i < len data; i++)
    data[i] = sensor_reading(i);
tf.setdata(data);

# Prime factorization encoding
pf := PrimeFactors.new();
encoded := pf.encode(tf.shape);  # Single integer representation

# Convert to hypergraph
atom := tf.toatom();
atomspace.add(atom);

# Create relationships
goal_atom := Atom.new("Concept", "navigation_goal");
link := tf.tolink(goal_atom :: nil);
atomspace.addlink(link);

# Serialization
sexp := tf.tosexp();
binary := tf.serialize();

# Collection management
collection := TensorCollection.new();
collection.add(tf);
found := collection.find("robot_navigator");
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

### Tensor Fragment Mappings

| Tensor Component | S-Expression Form | Description |
|------------------|-------------------|-------------|
| TensorFragment | `(tensor-fragment id shape agent state timestamp encoding data)` | Complete tensor representation |
| Shape | `(modality depth context salience autonomy)` | 5-dimensional tensor shape |
| Prime Encoding | `integer` | Prime factorization of shape |
| Data | `(value1 value2 ...)` | Real-valued tensor data |

### Prime Factorization Examples

| Shape | Prime Factorization | Encoded Value |
|-------|-------------------|---------------|
| `[1,1,1,1,1]` | `2¹×3¹×5¹×7¹×11¹` | 2310 |
| `[2,0,1,3,0]` | `2²×3⁰×5¹×7³×11⁰` | 6860 |
| `[0,2,0,0,1]` | `2⁰×3²×5⁰×7⁰×11¹` | 99 |

## Testing Framework

The testing framework includes comprehensive validation for both the original cognitive synergy modules and the new tensor fragment architecture:

### Original Tests (`test-cognitive-synergy.b`)

1. **Basic Atom Translation**: Simple symbol round-trip
2. **Simple List Translation**: Basic list structure preservation
3. **Nested Structure Translation**: Complex hierarchical forms
4. **Cognitive Primitive Translation**: Agentic primitive conversion
5. **Agentic Rule Translation**: Rule-based reasoning validation
6. **Complex Grammar Translation**: Full system integration

### Tensor Tests (`test-tensor.b`)

1. **Tensor Creation**: Basic tensor fragment creation and property setting
2. **Shape Validation**: 5D tensor shape validation and range checking
3. **Prime Factorization**: Encoding/decoding round-trip verification
4. **Serialization**: S-expression and binary serialization testing
5. **Hypergraph Integration**: AtomSpace conversion and link creation
6. **Tensor Operations**: Copy, combine, similarity, and reshape operations
7. **Collection Management**: Multi-tensor storage and retrieval
8. **Edge Cases**: Error conditions and validation boundary testing

### Running Tests

```limbo
# Load and run cognitive synergy tests
test := load CognitiveSynergyTest CognitiveSynergyTest->PATH;
test->init(nil, nil);

# Load and run tensor tests
tensor_test := load TensorTest TensorTest->PATH;
tensor_test->init(nil, nil);
suite := tensor_test->run_all_tests();
report := suite.report();
sys->print(report);
```

## Design Principles

1. **Real Data Only**: No mocked interfaces - all tests use live data
2. **Bidirectional Translation**: Preserves structural and semantic information
3. **Modular Architecture**: Clean separation of concerns
4. **AtomSpace Integration**: Native hypergraph representation
5. **Agentic Grammar**: Support for autonomous reasoning patterns
6. **Tensor Validation**: Comprehensive shape and data validation
7. **Prime Factorization**: Efficient tensor shape encoding
8. **Serialization Consistency**: Standard format compatibility

## Extension Points

The system is designed for extensibility:

- **Custom Primitive Types**: Add new cognitive primitive categories
- **Translation Rules**: Define custom Scheme-to-AtomSpace mappings
- **Reasoning Algorithms**: Implement advanced inference methods
- **Truth Value Systems**: Support different uncertainty models
- **Tensor Modalities**: Add new sensory/cognitive modalities
- **Tensor Operations**: Implement domain-specific tensor manipulations
- **Prime Encodings**: Extend factorization for specialized applications

## Error Handling

All operations return comprehensive error information:
- Parse errors from malformed S-expressions
- Translation failures with diagnostic messages
- Verification failures for round-trip consistency
- Module loading errors with clear failure reasons
- Tensor shape validation errors with specific constraint violations
- Prime encoding validation with mathematical verification
- Serialization errors with format-specific diagnostics

This foundation enables building sophisticated cognitive reasoning systems while maintaining compatibility with both Scheme symbolic processing and AtomSpace hypergraph operations, now enhanced with systematic tensor fragment architecture for encoding agent/state information.