implement TensorTest;

include "sys.m";
	sys: Sys;

include "sexprs.m";
	sexprs: Sexprs;
	Sexp: import sexprs;

include "../../module/cognitive-synergy/tensor.m";
	tensor: TensorFragment;
	TensorFragment, TensorValidator, TensorCollection, PrimeFactors: import tensor;

include "../../module/cognitive-synergy/atomspace.m";
	atomspace: AtomSpace;
	Atom, Link: import atomspace;

include "../../module/cognitive-synergy/test-tensor.m";

init()
{
	sys = load Sys Sys->PATH;
	sexprs = load Sexprs Sexprs->PATH;
	tensor = load TensorFragment TensorFragment->PATH;
	atomspace = load AtomSpace AtomSpace->PATH;
	
	if(sexprs != nil)
		sexprs->init();
	if(tensor != nil)
		tensor->init();
	if(atomspace != nil)
		atomspace->init();
}

# Test result implementation
TestResult.new(name: string): ref TestResult
{
	return ref TestResult(name, 0, "");
}

TestResult.pass(tr: self ref TestResult)
{
	tr.passed = 1;
	tr.error = "";
}

TestResult.fail(tr: self ref TestResult, error: string)
{
	tr.passed = 0;
	tr.error = error;
}

TestResult.report(tr: self ref TestResult): string
{
	if(tr.passed)
		return "✓ " + tr.name + " - PASSED";
	else
		return "✗ " + tr.name + " - FAILED: " + tr.error;
}

# Test suite implementation
TestSuite.new(): ref TestSuite
{
	return ref TestSuite(nil, 0, 0);
}

TestSuite.add(ts: self ref TestSuite, result: ref TestResult)
{
	ts.results = result :: ts.results;
	ts.total++;
	if(result.passed)
		ts.passed++;
}

TestSuite.summary(ts: self ref TestSuite): string
{
	return "Tests: " + string ts.passed + "/" + string ts.total + " passed";
}

TestSuite.report(ts: self ref TestSuite): string
{
	report := "Tensor Fragment Architecture Test Report\n";
	report += "========================================\n\n";
	
	for(results := ts.results; results != nil; results = tl results) {
		result := hd results;
		report += result.report() + "\n";
	}
	
	report += "\n" + ts.summary() + "\n";
	
	if(ts.passed == ts.total)
		report += "All tests PASSED! ✓\n";
	else
		report += "Some tests FAILED! ✗\n";
	
	return report;
}

# Main test runner
run_all_tests(): ref TestSuite
{
	suite := TestSuite.new();
	
	# Run all test functions
	suite.add(test_tensor_creation());
	suite.add(test_shape_validation());
	suite.add(test_prime_factorization());
	suite.add(test_serialization());
	suite.add(test_hypergraph_integration());
	suite.add(test_tensor_operations());
	suite.add(test_collection_management());
	suite.add(test_edge_cases());
	
	return suite;
}

# Test tensor creation and basic operations
test_tensor_creation(): ref TestResult
{
	result := TestResult.new("Tensor Creation");
	
	# Test valid tensor creation
	tf := TensorFragment.new(1, 2, 3, 5, 0);
	if(tf == nil) {
		result.fail("Failed to create tensor fragment");
		return result;
	}
	
	# Verify shape
	if(len tf.shape != tensor->TENSOR_DIMENSIONS) {
		result.fail("Incorrect tensor dimensions: " + string len tf.shape);
		return result;
	}
	
	if(tf.shape[tensor->MODALITY] != 1 || tf.shape[tensor->DEPTH] != 2 || 
	   tf.shape[tensor->CONTEXT] != 3 || tf.shape[tensor->SALIENCE] != 5 || 
	   tf.shape[tensor->AUTONOMY_INDEX] != 0) {
		result.fail("Incorrect shape values");
		return result;
	}
	
	# Test data setting
	data := array[30] of real;  # 1*2*3*5*1 = 30
	for(i := 0; i < len data; i++)
		data[i] = real i * 0.1;
	
	tf.setdata(data);
	if(len tf.data != len data) {
		result.fail("Data not set correctly");
		return result;
	}
	
	# Test agent and state setting
	tf.setagent("test_agent");
	tf.setstate("test_state");
	
	if(tf.agent_id != "test_agent" || tf.state_type != "test_state") {
		result.fail("Agent ID or state type not set correctly");
		return result;
	}
	
	result.pass();
	return result;
}

# Test shape validation mechanisms
test_shape_validation(): ref TestResult
{
	result := TestResult.new("Shape Validation");
	validator := TensorValidator.new();
	
	# Test valid shapes
	valid_shape := array[] of { 1, 2, 3, 5, 0 };
	err := validator.validateshape(valid_shape);
	if(err != nil) {
		result.fail("Valid shape rejected: " + err);
		return result;
	}
	
	# Test invalid dimensions count
	invalid_shape := array[] of { 1, 2, 3 };
	err = validator.validateshape(invalid_shape);
	if(err == nil) {
		result.fail("Invalid dimension count accepted");
		return result;
	}
	
	# Test out of range values
	out_of_range := array[] of { -1, 2, 3, 5, 0 };
	err = validator.validateshape(out_of_range);
	if(err == nil) {
		result.fail("Negative modality accepted");
		return result;
	}
	
	out_of_range = array[] of { 1, 2, 3, 101, 0 };
	err = validator.validateshape(out_of_range);
	if(err == nil) {
		result.fail("Out of range salience accepted");
		return result;
	}
	
	result.pass();
	return result;
}

# Test prime factorization encoding/decoding
test_prime_factorization(): ref TestResult
{
	result := TestResult.new("Prime Factorization");
	pf := PrimeFactors.new();
	
	# Test encoding and decoding
	original_shape := array[] of { 2, 1, 3, 4, 0 };
	encoded := pf.encode(original_shape);
	decoded_shape := pf.decode(encoded);
	
	# Verify decoding matches original
	if(len decoded_shape != len original_shape) {
		result.fail("Decoded shape has wrong dimensions");
		return result;
	}
	
	for(i := 0; i < len original_shape; i++) {
		if(original_shape[i] != decoded_shape[i]) {
			result.fail("Decoded shape doesn't match original");
			return result;
		}
	}
	
	# Test specific encoding values
	simple_shape := array[] of { 1, 1, 1, 1, 1 };
	simple_encoded := pf.encode(simple_shape);
	expected := big 2 * big 3 * big 5 * big 7 * big 11; # 2310
	if(simple_encoded != expected) {
		result.fail("Simple encoding incorrect: got " + string simple_encoded + ", expected " + string expected);
		return result;
	}
	
	# Test validation
	err := pf.validate(encoded);
	if(err != nil) {
		result.fail("Valid encoding rejected: " + err);
		return result;
	}
	
	result.pass();
	return result;
}

# Test serialization and deserialization
test_serialization(): ref TestResult
{
	result := TestResult.new("Serialization");
	
	# Create test tensor
	tf := TensorFragment.new(1, 2, 1, 3, 0);
	tf.setagent("serial_test");
	tf.setstate("serial_state");
	
	data := array[6] of real;  # 1*2*1*3*1 = 6
	for(i := 0; i < len data; i++)
		data[i] = real i + 0.5;
	tf.setdata(data);
	
	# Test S-expression serialization
	sexp := tf.tosexp();
	if(sexp == nil) {
		result.fail("Failed to convert to S-expression");
		return result;
	}
	
	# Test deserialization
	recovered := TensorFragment.fromsexp(sexp);
	if(recovered == nil) {
		result.fail("Failed to recover from S-expression");
		return result;
	}
	
	# Verify recovered tensor
	if(recovered.agent_id != tf.agent_id || recovered.state_type != tf.state_type) {
		result.fail("Agent ID or state type not preserved");
		return result;
	}
	
	if(len recovered.shape != len tf.shape) {
		result.fail("Shape dimensions not preserved");
		return result;
	}
	
	for(i := 0; i < len tf.shape; i++) {
		if(recovered.shape[i] != tf.shape[i]) {
			result.fail("Shape values not preserved");
			return result;
		}
	}
	
	# Test binary serialization
	binary := tf.serialize();
	if(binary == nil) {
		result.fail("Failed to serialize to binary");
		return result;
	}
	
	recovered2 := TensorFragment.deserialize(binary);
	if(recovered2 == nil) {
		result.fail("Failed to deserialize from binary");
		return result;
	}
	
	result.pass();
	return result;
}

# Test hypergraph integration
test_hypergraph_integration(): ref TestResult
{
	result := TestResult.new("Hypergraph Integration");
	
	if(atomspace == nil) {
		result.fail("AtomSpace module not available");
		return result;
	}
	
	# Create test tensor
	tf := TensorFragment.new(1, 1, 2, 4, 1);
	tf.setagent("hypergraph_agent");
	tf.setstate("hypergraph_state");
	
	# Convert to atom
	atom := tf.toatom();
	if(atom == nil) {
		result.fail("Failed to convert tensor to atom");
		return result;
	}
	
	# Verify atom properties
	if(atom.type != "TensorFragment") {
		result.fail("Incorrect atom type: " + atom.type);
		return result;
	}
	
	# Convert back from atom
	recovered := TensorFragment.fromatom(atom);
	if(recovered == nil) {
		result.fail("Failed to recover tensor from atom");
		return result;
	}
	
	# Verify recovery
	if(recovered.agent_id != tf.agent_id) {
		result.fail("Agent ID not preserved in atom conversion");
		return result;
	}
	
	# Test link creation
	related_atoms: list of ref Atom;
	related_atoms = atomspace->Atom.new("Concept", "goal") :: related_atoms;
	
	link := tf.tolink(related_atoms);
	if(link == nil) {
		result.fail("Failed to create tensor link");
		return result;
	}
	
	result.pass();
	return result;
}

# Test tensor operations
test_tensor_operations(): ref TestResult
{
	result := TestResult.new("Tensor Operations");
	
	# Create test tensors
	tf1 := TensorFragment.new(2, 1, 1, 2, 0);
	tf2 := TensorFragment.new(2, 1, 1, 2, 0);
	
	data1 := array[4] of real;  # 2*1*1*2*1 = 4
	data2 := array[4] of real;
	
	for(i := 0; i < len data1; i++) {
		data1[i] = real i;
		data2[i] = real i + 1.0;
	}
	
	tf1.setdata(data1);
	tf2.setdata(data2);
	
	# Test similarity
	sim := tf1.similarity(tf2);
	if(sim < 0.0 || sim > 1.0) {
		result.fail("Similarity out of range: " + string sim);
		return result;
	}
	
	# Test combination
	combined := tf1.combine(tf2);
	if(combined == nil) {
		result.fail("Failed to combine tensors");
		return result;
	}
	
	# Test copying
	copy := tf1.copy();
	if(copy == nil) {
		result.fail("Failed to copy tensor");
		return result;
	}
	
	if(copy.id == tf1.id) {
		result.fail("Copy has same ID as original");
		return result;
	}
	
	# Test reshaping (should fail for incompatible shapes)
	new_shape := array[] of { 1, 2, 1, 2, 0 };
	err := tf1.reshape(new_shape);
	if(err != nil) {
		result.fail("Reshape failed: " + err);
		return result;
	}
	
	result.pass();
	return result;
}

# Test collection management
test_collection_management(): ref TestResult
{
	result := TestResult.new("Collection Management");
	
	collection := TensorCollection.new();
	if(collection == nil) {
		result.fail("Failed to create tensor collection");
		return result;
	}
	
	# Add tensors
	tf1 := TensorFragment.new(1, 1, 1, 1, 0);
	tf1.setagent("agent1");
	tf1.setstate("state1");
	
	tf2 := TensorFragment.new(2, 1, 1, 2, 0);
	tf2.setagent("agent2");
	tf2.setstate("state1");
	
	err := collection.add(tf1);
	if(err != nil) {
		result.fail("Failed to add tensor 1: " + err);
		return result;
	}
	
	err = collection.add(tf2);
	if(err != nil) {
		result.fail("Failed to add tensor 2: " + err);
		return result;
	}
	
	# Test size
	if(collection.size() != 2) {
		result.fail("Incorrect collection size: " + string collection.size());
		return result;
	}
	
	# Test find by agent
	found := collection.find("agent1");
	if(found == nil || found.agent_id != "agent1") {
		result.fail("Failed to find tensor by agent ID");
		return result;
	}
	
	# Test find all by state
	state_tensors := collection.findall("state1");
	if(len state_tensors != 2) {
		result.fail("Incorrect number of tensors found by state");
		return result;
	}
	
	# Test export/import
	sexp := collection.export();
	if(sexp == nil) {
		result.fail("Failed to export collection");
		return result;
	}
	
	new_collection := TensorCollection.new();
	err = new_collection.import(sexp);
	if(err != nil) {
		result.fail("Failed to import collection: " + err);
		return result;
	}
	
	if(new_collection.size() != collection.size()) {
		result.fail("Imported collection has wrong size");
		return result;
	}
	
	result.pass();
	return result;
}

# Test edge cases and error conditions
test_edge_cases(): ref TestResult
{
	result := TestResult.new("Edge Cases");
	
	# Test nil tensor validation
	validator := TensorValidator.new();
	err := validator.validatefull(nil);
	if(err == nil) {
		result.fail("Nil tensor accepted");
		return result;
	}
	
	# Test empty agent ID validation
	err = validator.validateagent("");
	if(err == nil) {
		result.fail("Empty agent ID accepted");
		return result;
	}
	
	# Test tensor with mismatched data size
	tf := TensorFragment.new(2, 2, 1, 1, 0);
	wrong_data := array[3] of real;  # Should be 4 elements
	tf.setdata(wrong_data);
	
	err = validator.validatedata(tf);
	if(err == nil) {
		result.fail("Mismatched data size accepted");
		return result;
	}
	
	# Test prime factorization with invalid input
	pf := PrimeFactors.new();
	err = pf.validate(big 0);
	if(err == nil) {
		result.fail("Zero encoding accepted");
		return result;
	}
	
	# Test deserializing invalid S-expression
	invalid_sexp := ref Sexp.String("not-a-tensor", nil);
	recovered := TensorFragment.fromsexp(invalid_sexp);
	if(recovered != nil) {
		result.fail("Invalid S-expression accepted");
		return result;
	}
	
	result.pass();
	return result;
}