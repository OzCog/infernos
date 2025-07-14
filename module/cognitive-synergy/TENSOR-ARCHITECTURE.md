# Tensor Fragment Architecture Documentation
# Phase 1.2: Tensor Fragment Architecture Design

## Overview

The Tensor Fragment Architecture provides a systematic approach to encoding agent/state information as hypergraph nodes and links using a 5-dimensional tensor representation. This architecture enables efficient storage, retrieval, and manipulation of cognitive state data within the Inferno cognitive synergy framework.

## Tensor Shape Specification

### Tensor Dimensions

Each tensor fragment has exactly 5 dimensions representing different aspects of cognitive state:

```
Tensor Shape: [modality, depth, context, salience, autonomy_index]
```

| Dimension | Index | Range | Description |
|-----------|-------|-------|-------------|
| **Modality** | 0 | 0-15 | Sensory/cognitive modality (visual, auditory, symbolic, etc.) |
| **Depth** | 1 | 0-31 | Processing depth level (surface to deep reasoning) |
| **Context** | 2 | 0-63 | Contextual state identifier |
| **Salience** | 3 | 0-99 | Attention/importance weight (0=low, 99=high) |
| **Autonomy Index** | 4 | 0-9 | Level of agent autonomy in this state |

### Dimension Constraints

- **Total Dimensions**: Exactly 5 (enforced at compile time)
- **Value Ranges**: Each dimension has specific valid ranges to ensure efficient encoding
- **Validation**: All tensor operations include automatic shape and range validation

## Prime Factorization Mapping

### Encoding Algorithm

The tensor shape is encoded using prime factorization for efficient storage and unique identification:

```
encoded_value = p₁^d₁ × p₂^d₂ × p₃^d₃ × p₄^d₄ × p₅^d₅
```

Where:
- `p₁ = 2` (modality prime)
- `p₂ = 3` (depth prime) 
- `p₃ = 5` (context prime)
- `p₄ = 7` (salience prime)
- `p₅ = 11` (autonomy prime)

### Example Encodings

| Tensor Shape | Prime Factorization | Encoded Value |
|--------------|---------------------|---------------|
| `[1,1,1,1,1]` | `2¹×3¹×5¹×7¹×11¹` | 2310 |
| `[2,0,1,3,0]` | `2²×3⁰×5¹×7³×11⁰` | `4×1×5×343×1` = 6860 |
| `[0,2,0,0,1]` | `2⁰×3²×5⁰×7⁰×11¹` | `1×9×1×1×11` = 99 |

### Decoding Algorithm

To decode a prime-encoded value back to tensor shape:

1. Initialize dimension counters to 0
2. For each prime factor (2, 3, 5, 7, 11):
   - Count how many times it divides the encoded value
   - Store count as corresponding dimension value
3. Validate resulting shape against dimension constraints

### Benefits of Prime Encoding

1. **Uniqueness**: Each tensor shape maps to exactly one encoded value
2. **Compactness**: Single integer represents entire 5D shape
3. **Validation**: Invalid encodings are easily detected
4. **Ordering**: Natural ordering for similarity comparisons

## Tensor Fragment Structure

### Core Components

```limbo
TensorFragment: adt {
    id: big;                    # Unique identifier
    shape: array of int;        # [modality, depth, context, salience, autonomy]
    data: array of real;        # Tensor data values
    agent_id: string;           # Associated agent identifier
    state_type: string;         # Type of cognitive state
    timestamp: big;             # Creation timestamp
    prime_encoding: big;        # Prime factorization of shape
}
```

### Data Layout

- **Shape-Data Consistency**: Data array size must equal product of shape dimensions
- **Memory Layout**: Row-major ordering for multi-dimensional data access
- **Type Safety**: Real-valued data with validated tensor operations

## Serialization Format

### S-Expression Representation

Tensor fragments serialize to S-expressions for interoperability:

```scheme
(tensor-fragment
  12345                                    ; ID
  (2 1 3 5 0)                             ; Shape
  "agent_01"                              ; Agent ID
  "navigation_state"                      ; State type
  1672531200000                           ; Timestamp
  14700                                   ; Prime encoding
  (1.0 0.5 0.8 0.2 0.9 0.1))             ; Data values
```

### Binary Serialization

- **Format**: S-expression packed to binary using existing Sexp.pack() method
- **Efficiency**: Compact representation for network transmission
- **Compatibility**: Standard Inferno serialization format

## Validation Mechanisms

### Shape Validation

```limbo
TensorValidator.validateshape(shape: array of int): string
```

Validates:
- Exactly 5 dimensions
- Each dimension within valid range
- Non-negative values
- Reasonable tensor size limits

### Data Validation

```limbo
TensorValidator.validatedata(tf: ref TensorFragment): string
```

Validates:
- Data size matches shape product
- Finite real values
- Memory layout consistency

### Agent Validation

```limbo
TensorValidator.validateagent(agent_id: string): string
```

Validates:
- Non-empty agent identifier
- Reasonable length limits
- Valid character encoding

## Hypergraph Integration

### AtomSpace Mapping

Tensor fragments integrate with the existing AtomSpace hypergraph:

```limbo
# Convert tensor to hypergraph node
atom := tensor.toatom()

# Create hypergraph links with other atoms
link := tensor.tolink(related_atoms)

# Retrieve tensor from hypergraph
recovered_tensor := TensorFragment.fromatom(atom)
```

### Link Types

- **TensorLink**: Connects tensor fragments to other cognitive primitives
- **AgentLink**: Associates tensors with agent representations
- **StateLink**: Groups related state tensor fragments

## Tensor Operations

### Shape Operations

```limbo
# Reshape while preserving data size
tensor.reshape(new_shape)

# Extract slice along dimension
slice := tensor.slice(dimension, index)
```

### Combination Operations

```limbo
# Combine two compatible tensors
combined := tensor1.combine(tensor2)

# Calculate similarity between tensors
similarity := tensor1.similarity(tensor2)
```

### Collection Management

```limbo
collection := TensorCollection.new()
collection.add(tensor)
found := collection.find("agent_01")
by_type := collection.findall("navigation_state")
```

## Performance Characteristics

### Memory Usage

- **Shape Storage**: 5 integers = 20 bytes
- **Prime Encoding**: 1 big integer = 8 bytes
- **Data Storage**: n × 8 bytes (for n real values)
- **Metadata**: ~100 bytes for strings and timestamps

### Computational Complexity

- **Prime Encoding**: O(log(max_value)) for encoding/decoding
- **Shape Validation**: O(1) constant time
- **Serialization**: O(n) linear in data size
- **Similarity**: O(n) linear in data size

## Integration Examples

### Agent State Encoding

```limbo
# Create tensor for robot navigation state
tensor := TensorFragment.new(
    1,  # Visual modality
    2,  # Medium processing depth
    5,  # Current context
    8,  # High salience
    3   # Moderate autonomy
)

tensor.setagent("robot_navigator")
tensor.setstate("obstacle_avoidance")
tensor.setdata(sensor_data)
```

### Hypergraph Composition

```limbo
# Add tensor to AtomSpace
atom := tensor.toatom()
atomspace.add(atom)

# Create relationships
goal_atom := Atom.new("Concept", "navigation_goal")
link := tensor.tolink(goal_atom :: nil)
atomspace.addlink(link)
```

### State Collection

```limbo
# Manage multiple agent states
collection := TensorCollection.new()
collection.add(navigation_tensor)
collection.add(perception_tensor)

# Export for persistence
sexp := collection.export()
serialized := sexp.pack()
```

## Extension Points

### Custom Modalities

Add new sensory or cognitive modalities by extending the modality dimension range and updating validation constraints.

### Additional Dimensions

For specialized applications, consider creating derived tensor types with additional dimensions while maintaining the core 5D structure.

### Advanced Operations

Implement domain-specific tensor operations such as:
- Temporal tensor sequences
- Multi-agent tensor fusion
- Probabilistic tensor inference

## Design Principles

1. **Consistency**: All tensors follow the same 5D structure
2. **Validation**: Comprehensive error checking at all levels
3. **Efficiency**: Prime encoding for compact representation
4. **Interoperability**: Standard serialization formats
5. **Extensibility**: Modular design for future enhancements

This tensor fragment architecture provides a robust foundation for representing cognitive agent states within the Inferno distributed cognitive synergy framework.