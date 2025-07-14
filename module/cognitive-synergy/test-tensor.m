TensorTest: module
{
	PATH:	con "/dis/lib/cognitive-synergy/test-tensor.dis";

	# Test suite for tensor fragment architecture validation

	# Test result structure
	TestResult: adt {
		name: string;
		passed: int;
		error: string;
		
		new: fn(name: string): ref TestResult;
		pass: fn(tr: self ref TestResult);
		fail: fn(tr: self ref TestResult, error: string);
		report: fn(tr: self ref TestResult): string;
	};

	# Test suite collection
	TestSuite: adt {
		results: list of ref TestResult;
		total: int;
		passed: int;
		
		new: fn(): ref TestSuite;
		add: fn(ts: self ref TestSuite, result: ref TestResult);
		summary: fn(ts: self ref TestSuite): string;
		report: fn(ts: self ref TestSuite): string;
	};

	# Main test functions
	run_all_tests: fn(): ref TestSuite;
	test_tensor_creation: fn(): ref TestResult;
	test_shape_validation: fn(): ref TestResult;
	test_prime_factorization: fn(): ref TestResult;
	test_serialization: fn(): ref TestResult;
	test_hypergraph_integration: fn(): ref TestResult;
	test_tensor_operations: fn(): ref TestResult;
	test_collection_management: fn(): ref TestResult;
	test_edge_cases: fn(): ref TestResult;

	init: fn();
};