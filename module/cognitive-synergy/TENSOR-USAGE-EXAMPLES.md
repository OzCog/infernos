# Tensor Fragment Architecture Usage Examples
# Phase 1.2: Tensor Fragment Architecture Design

## Basic Tensor Creation and Validation

```limbo
implement TensorExample;

include "sys.m";
    sys: Sys;
include "../../module/cognitive-synergy/tensor.m";
    tensor: TensorFragment;
    TensorFragment, TensorValidator, PrimeFactors: import tensor;

init()
{
    sys = load Sys Sys->PATH;
    tensor = load TensorFragment TensorFragment->PATH;
    tensor->init();
    
    # Example 1: Create a basic tensor fragment
    example_basic_creation();
    
    # Example 2: Demonstrate prime factorization
    example_prime_encoding();
    
    # Example 3: Show serialization
    example_serialization();
    
    # Example 4: Collection management
    example_collection();
}

example_basic_creation()
{
    sys->print("=== Basic Tensor Creation ===\n");
    
    # Create tensor for robot navigation state
    # Shape: [modality=1(visual), depth=2(medium), context=5, salience=8(high), autonomy=3]
    tf := TensorFragment.new(1, 2, 5, 8, 3);
    
    # Set agent and state information
    tf.setagent("robot_navigator");
    tf.setstate("obstacle_avoidance");
    
    # Calculate expected data size: 1*2*5*8*1 = 80
    data_size := 1 * 2 * 5 * 8 * 1;
    data := array[data_size] of real;
    
    # Fill with sample sensor data
    for(i := 0; i < len data; i++)
        data[i] = real i * 0.1;  # Simulated sensor readings
    
    tf.setdata(data);
    
    # Validate the tensor
    validator := TensorValidator.new();
    err := validator.validatefull(tf);
    
    if(err == nil)
        sys->print("✓ Tensor created and validated successfully\n");
    else
        sys->print("✗ Validation failed: " + err + "\n");
    
    sys->print("Agent: " + tf.agent_id + "\n");
    sys->print("State: " + tf.state_type + "\n");
    sys->print("Shape: [" + string tf.shape[0] + "," + string tf.shape[1] + "," + 
              string tf.shape[2] + "," + string tf.shape[3] + "," + string tf.shape[4] + "]\n");
    sys->print("Data size: " + string len tf.data + "\n\n");
}

example_prime_encoding()
{
    sys->print("=== Prime Factorization Encoding ===\n");
    
    pf := PrimeFactors.new();
    
    # Test different tensor shapes
    test_shapes := array[] of {
        array[] of { 1, 1, 1, 1, 1 },  # Simple case
        array[] of { 2, 0, 1, 3, 0 },  # Complex case
        array[] of { 0, 2, 0, 0, 1 },  # Sparse case
    };
    
    expected_encodings := array[] of { big 2310, big 6860, big 99 };
    
    for(i := 0; i < len test_shapes; i++) {
        shape := test_shapes[i];
        encoded := pf.encode(shape);
        decoded := pf.decode(encoded);
        
        sys->print("Shape: [" + string shape[0] + "," + string shape[1] + "," + 
                  string shape[2] + "," + string shape[3] + "," + string shape[4] + "]\n");
        sys->print("Encoded: " + string encoded + "\n");
        sys->print("Expected: " + string expected_encodings[i] + "\n");
        
        # Verify round-trip
        match := 1;
        for(j := 0; j < len shape; j++)
            if(shape[j] != decoded[j])
                match = 0;
        
        if(match && encoded == expected_encodings[i])
            sys->print("✓ Encoding/decoding successful\n");
        else
            sys->print("✗ Encoding/decoding failed\n");
        
        sys->print("\n");
    }
}

example_serialization()
{
    sys->print("=== Serialization Examples ===\n");
    
    # Create a tensor with data
    tf := TensorFragment.new(2, 1, 3, 4, 1);
    tf.setagent("serialization_test");
    tf.setstate("demo_state");
    
    data := array[24] of real;  # 2*1*3*4*1 = 24
    for(i := 0; i < len data; i++)
        data[i] = real i + 0.5;
    tf.setdata(data);
    
    # Convert to S-expression
    sexp := tf.tosexp();
    if(sexp != nil) {
        sys->print("✓ S-expression serialization successful\n");
        sys->print("S-exp format: " + sexp.text() + "\n\n");
    } else {
        sys->print("✗ S-expression serialization failed\n");
    }
    
    # Test round-trip
    recovered := TensorFragment.fromsexp(sexp);
    if(recovered != nil && recovered.agent_id == tf.agent_id) {
        sys->print("✓ S-expression round-trip successful\n");
    } else {
        sys->print("✗ S-expression round-trip failed\n");
    }
    
    # Binary serialization
    binary := tf.serialize();
    if(binary != nil) {
        sys->print("✓ Binary serialization successful (" + string len binary + " bytes)\n");
        
        recovered2 := TensorFragment.deserialize(binary);
        if(recovered2 != nil && recovered2.agent_id == tf.agent_id) {
            sys->print("✓ Binary round-trip successful\n");
        } else {
            sys->print("✗ Binary round-trip failed\n");
        }
    } else {
        sys->print("✗ Binary serialization failed\n");
    }
    
    sys->print("\n");
}

example_collection()
{
    sys->print("=== Collection Management ===\n");
    
    collection := TensorCollection.new();
    
    # Create multiple tensors for different agents/states
    tensors := array[] of {
        TensorFragment.new(1, 1, 2, 5, 1),  # Agent 1, navigation
        TensorFragment.new(2, 2, 1, 7, 2),  # Agent 1, perception  
        TensorFragment.new(1, 1, 3, 4, 0),  # Agent 2, navigation
    };
    
    agents := array[] of { "robot_01", "robot_01", "robot_02" };
    states := array[] of { "navigation", "perception", "navigation" };
    
    # Add tensors to collection
    for(i := 0; i < len tensors; i++) {
        tf := tensors[i];
        tf.setagent(agents[i]);
        tf.setstate(states[i]);
        
        err := collection.add(tf);
        if(err != nil)
            sys->print("Failed to add tensor " + string i + ": " + err + "\n");
    }
    
    sys->print("Collection size: " + string collection.size() + "\n");
    
    # Find tensor by agent
    found := collection.find("robot_01");
    if(found != nil)
        sys->print("✓ Found tensor for robot_01: " + found.state_type + "\n");
    else
        sys->print("✗ Failed to find tensor for robot_01\n");
    
    # Find all navigation tensors
    nav_tensors := collection.findall("navigation");
    sys->print("Navigation tensors found: " + string len nav_tensors + "\n");
    
    # Export collection
    exported := collection.export();
    if(exported != nil) {
        sys->print("✓ Collection export successful\n");
        
        # Import to new collection
        new_collection := TensorCollection.new();
        err := new_collection.import(exported);
        if(err == nil && new_collection.size() == collection.size())
            sys->print("✓ Collection import successful\n");
        else
            sys->print("✗ Collection import failed\n");
    } else {
        sys->print("✗ Collection export failed\n");
    }
    
    sys->print("\n");
}
```

## Advanced Usage Patterns

### Multi-Modal Agent State

```limbo
# Create tensor for multi-modal perception
visual_tensor := TensorFragment.new(1, 3, 2, 9, 2);  # Visual, deep processing
audio_tensor := TensorFragment.new(2, 2, 2, 7, 2);   # Audio, medium processing
haptic_tensor := TensorFragment.new(3, 1, 2, 5, 2);  # Haptic, surface processing

# Set agent context
for(tensor in [visual_tensor, audio_tensor, haptic_tensor]) {
    tensor.setagent("multimodal_robot");
    tensor.setstate("environment_scan");
}

# Combine modalities
combined := visual_tensor.combine(audio_tensor);
if(combined != nil) {
    final := combined.combine(haptic_tensor);
    # Result represents fused multi-modal state
}
```

### Temporal State Sequences

```limbo
# Create sequence of temporal states
time_steps := 5;
temporal_tensors := array[time_steps] of ref TensorFragment;

for(t := 0; t < time_steps; t++) {
    # Decrease salience over time (memory fade)
    salience := 9 - t;
    tf := TensorFragment.new(1, 2, 1, salience, 1);
    tf.setagent("temporal_agent");
    tf.setstate("memory_step_" + string t);
    temporal_tensors[t] = tf;
}

# Analyze temporal similarity
for(t := 1; t < time_steps; t++) {
    sim := temporal_tensors[t-1].similarity(temporal_tensors[t]);
    sys->print("Similarity t=" + string (t-1) + " to t=" + string t + ": " + string sim + "\n");
}
```

### Hierarchical Agent Architectures

```limbo
# High-level planning (high autonomy)
plan_tensor := TensorFragment.new(4, 3, 5, 8, 4);  # Symbolic, deep, high autonomy
plan_tensor.setagent("executive_planner");
plan_tensor.setstate("goal_planning");

# Mid-level control (medium autonomy)
control_tensor := TensorFragment.new(2, 2, 3, 6, 2);  # Audio-motor, medium autonomy
control_tensor.setagent("motor_controller");
control_tensor.setstate("action_execution");

# Low-level reflexes (low autonomy)
reflex_tensor := TensorFragment.new(1, 1, 1, 9, 0);  # Visual, surface, high salience, no autonomy
reflex_tensor.setagent("reflex_system");
reflex_tensor.setstate("emergency_stop");

# Create hierarchical links in AtomSpace
plan_atom := plan_tensor.toatom();
control_atom := control_tensor.toatom();
reflex_atom := reflex_tensor.toatom();

hierarchy_link := plan_tensor.tolink(control_atom :: reflex_atom :: nil);
# Represents hierarchical control relationship
```

## Performance Optimization

### Efficient Shape Encoding

```limbo
# Use prime encoding for fast shape comparison
pf := PrimeFactors.new();

# Instead of comparing arrays element by element
if(tensor1.prime_encoding == tensor2.prime_encoding) {
    # Shapes are identical - O(1) comparison
    proceed_with_operation();
}

# Decode only when needed
if(need_individual_dimensions) {
    shape := pf.decode(tensor.prime_encoding);
    process_dimensions(shape);
}
```

### Batch Operations

```limbo
# Process multiple tensors efficiently
collection := TensorCollection.new();
batch_results := array[100] of real;

nav_tensors := collection.findall("navigation");
for(i := 0; i < len nav_tensors && i < len batch_results; i++) {
    tf := nth_tensor(nav_tensors, i);
    batch_results[i] = compute_metric(tf);
}
```

This tensor fragment architecture provides a systematic approach to encoding cognitive agent states while maintaining efficient storage, validation, and manipulation capabilities within the Inferno distributed cognitive synergy framework.