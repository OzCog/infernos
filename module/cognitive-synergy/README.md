# Cognitive Synergy Module Directory
# Phase 1.1: Scheme Cognitive Grammar Microservices Implementation
# Phase 1.2: Tensor Fragment Architecture Design

This directory contains the modular Scheme adapters, cognitive grammar components, and tensor fragment architecture for agentic AtomSpace integration.

## Module Structure

### Core Modules
- atomspace.m - AtomSpace hypergraph representation interface
- cognitive.m - Cognitive grammar primitives interface  
- scheme-adapter.m - Scheme adapter for agentic grammar integration
- tensor.m - Tensor fragment architecture for agent/state encoding

### Test Modules
- test-cognitive-synergy.m - Tests for original cognitive synergy modules
- test-tensor.m - Comprehensive tensor fragment validation tests

### Documentation
- API-DOCUMENTATION.md - Complete API reference for all modules
- TENSOR-ARCHITECTURE.md - Detailed tensor fragment architecture specification
- TENSOR-USAGE-EXAMPLES.md - Practical usage examples and patterns

## Implementation Files

- atomspace.b - AtomSpace implementation
- cognitive.b - Cognitive grammar primitives implementation
- scheme-adapter.b - Scheme adapter implementation
- tensor.b - Tensor fragment architecture implementation
- test-cognitive-synergy.b - Cognitive synergy test suite
- test-tensor.b - Tensor fragment test suite

## Tensor Fragment Architecture

### 5-Dimensional Tensor Shape
```
[modality, depth, context, salience, autonomy_index]
```

- **Modality** (0-15): Sensory/cognitive modality
- **Depth** (0-31): Processing depth level  
- **Context** (0-63): Contextual state identifier
- **Salience** (0-99): Attention/importance weight
- **Autonomy Index** (0-9): Level of agent autonomy

### Prime Factorization Mapping
Efficient tensor shape encoding using prime factorization:
```
encoded = 2^modality × 3^depth × 5^context × 7^salience × 11^autonomy
```

### Key Features
- Systematic agent/state encoding as hypergraph nodes/links
- Comprehensive shape validation mechanisms
- Efficient serialization/deserialization
- AtomSpace integration with existing cognitive modules
- Prime factorization for compact representation
- Comprehensive test coverage