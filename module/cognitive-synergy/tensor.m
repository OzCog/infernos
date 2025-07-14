TensorFragment: module
{
	PATH:	con "/dis/lib/cognitive-synergy/tensor.dis";

	# Tensor fragment architecture for encoding agent/state as hypergraph nodes/links
	# Tensor shape: [modality, depth, context, salience, autonomy_index]
	
	# Tensor dimension indices
	MODALITY: con 0;
	DEPTH: con 1;
	CONTEXT: con 2;
	SALIENCE: con 3;
	AUTONOMY_INDEX: con 4;
	
	# Tensor shape constraints
	TENSOR_DIMENSIONS: con 5;
	MAX_MODALITY: con 16;      # Support up to 16 different modalities
	MAX_DEPTH: con 32;         # Support up to 32 depth levels
	MAX_CONTEXT: con 64;       # Support up to 64 context states
	MAX_SALIENCE: con 100;     # Salience values 0-99
	MAX_AUTONOMY: con 10;      # Autonomy index 0-9

	# Prime factorization mapping for efficient storage
	PrimeFactors: adt {
		modality_prime: int;
		depth_prime: int;
		context_prime: int;
		salience_prime: int;
		autonomy_prime: int;
		
		new: fn(): ref PrimeFactors;
		encode: fn(pf: self ref PrimeFactors, shape: array of int): big;
		decode: fn(pf: self ref PrimeFactors, encoded: big): array of int;
		validate: fn(pf: self ref PrimeFactors, encoded: big): string;
	};

	# Tensor fragment with 5-dimensional shape
	TensorFragment: adt {
		id: big;
		shape: array of int;  # [modality, depth, context, salience, autonomy_index]
		data: array of real;  # Tensor data values
		agent_id: string;     # Associated agent identifier
		state_type: string;   # Type of state being encoded
		timestamp: big;       # Creation timestamp
		prime_encoding: big;  # Prime factorization encoding of shape
		
		new: fn(modality, depth, context, salience, autonomy: int): ref TensorFragment;
		setdata: fn(tf: self ref TensorFragment, data: array of real);
		setagent: fn(tf: self ref TensorFragment, agent_id: string);
		setstate: fn(tf: self ref TensorFragment, state_type: string);
		validate: fn(tf: self ref TensorFragment): string;
		copy: fn(tf: self ref TensorFragment): ref TensorFragment;
		
		# Hypergraph integration
		toatom: fn(tf: self ref TensorFragment): ref Atom;
		fromatom: fn(atom: ref Atom): ref TensorFragment;
		tolink: fn(tf: self ref TensorFragment, outgoing: list of ref Atom): ref Link;
		
		# Serialization/deserialization
		serialize: fn(tf: self ref TensorFragment): array of byte;
		deserialize: fn(data: array of byte): ref TensorFragment;
		tosexp: fn(tf: self ref TensorFragment): ref Sexp;
		fromsexp: fn(e: ref Sexp): ref TensorFragment;
		
		# Tensor operations
		reshape: fn(tf: self ref TensorFragment, new_shape: array of int): string;
		slice: fn(tf: self ref TensorFragment, dim: int, index: int): ref TensorFragment;
		combine: fn(tf1, tf2: self ref TensorFragment): ref TensorFragment;
		similarity: fn(tf1, tf2: self ref TensorFragment): real;
	};

	# Tensor shape validation
	TensorValidator: adt {
		new: fn(): ref TensorValidator;
		validateshape: fn(tv: self ref TensorValidator, shape: array of int): string;
		validatedata: fn(tv: self ref TensorValidator, tf: ref TensorFragment): string;
		validateagent: fn(tv: self ref TensorValidator, agent_id: string): string;
		validatefull: fn(tv: self ref TensorValidator, tf: ref TensorFragment): string;
	};

	# Tensor fragment collection for managing multiple tensor fragments
	TensorCollection: adt {
		fragments: list of ref TensorFragment;
		index: ref Hash->HashTable[string, ref TensorFragment];
		validator: ref TensorValidator;
		
		new: fn(): ref TensorCollection;
		add: fn(tc: self ref TensorCollection, tf: ref TensorFragment): string;
		remove: fn(tc: self ref TensorCollection, id: big): int;
		find: fn(tc: self ref TensorCollection, agent_id: string): ref TensorFragment;
		findall: fn(tc: self ref TensorCollection, state_type: string): list of ref TensorFragment;
		export: fn(tc: self ref TensorCollection): ref Sexp;
		import: fn(tc: self ref TensorCollection, e: ref Sexp): string;
		size: fn(tc: self ref TensorCollection): int;
		clear: fn(tc: self ref TensorCollection);
	};

	init: fn();
};