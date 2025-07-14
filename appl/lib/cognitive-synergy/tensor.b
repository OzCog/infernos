implement TensorFragment;

include "sys.m";
	sys: Sys;

include "draw.m";

include "sexprs.m";
	sexprs: Sexprs;
	Sexp: import sexprs;

include "hash.m";
	hash: Hash;
	HashTable, HashVal: import hash;

include "../../module/cognitive-synergy/atomspace.m";
	atomspace: AtomSpace;
	Atom, Link: import atomspace;

include "../../module/cognitive-synergy/tensor.m";

# Prime numbers for factorization encoding (first 5 primes)
PRIMES := array[] of { 2, 3, 5, 7, 11 };

init()
{
	sys = load Sys Sys->PATH;
	sexprs = load Sexprs Sexprs->PATH;
	hash = load Hash Hash->PATH;
	atomspace = load AtomSpace AtomSpace->PATH;
	
	if(sexprs != nil)
		sexprs->init();
	if(atomspace != nil)
		atomspace->init();
}

# Prime factorization implementation
PrimeFactors.new(): ref PrimeFactors
{
	pf := ref PrimeFactors;
	pf.modality_prime = PRIMES[MODALITY];
	pf.depth_prime = PRIMES[DEPTH];
	pf.context_prime = PRIMES[CONTEXT];
	pf.salience_prime = PRIMES[SALIENCE];
	pf.autonomy_prime = PRIMES[AUTONOMY_INDEX];
	return pf;
}

PrimeFactors.encode(pf: self ref PrimeFactors, shape: array of int): big
{
	if(len shape != TENSOR_DIMENSIONS)
		return big 0;
	
	encoded := big 1;
	
	# Encode each dimension using prime factorization
	# encoded = p1^d1 * p2^d2 * p3^d3 * p4^d4 * p5^d5
	for(i := 0; i < shape[MODALITY]; i++)
		encoded *= big pf.modality_prime;
	for(i := 0; i < shape[DEPTH]; i++)
		encoded *= big pf.depth_prime;
	for(i := 0; i < shape[CONTEXT]; i++)
		encoded *= big pf.context_prime;
	for(i := 0; i < shape[SALIENCE]; i++)
		encoded *= big pf.salience_prime;
	for(i := 0; i < shape[AUTONOMY_INDEX]; i++)
		encoded *= big pf.autonomy_prime;
	
	return encoded;
}

PrimeFactors.decode(pf: self ref PrimeFactors, encoded: big): array of int
{
	shape := array[TENSOR_DIMENSIONS] of int;
	remaining := encoded;
	
	# Decode by counting how many times each prime divides the encoded value
	for(shape[MODALITY] = 0; remaining % big pf.modality_prime == big 0; shape[MODALITY]++)
		remaining /= big pf.modality_prime;
	
	for(shape[DEPTH] = 0; remaining % big pf.depth_prime == big 0; shape[DEPTH]++)
		remaining /= big pf.depth_prime;
		
	for(shape[CONTEXT] = 0; remaining % big pf.context_prime == big 0; shape[CONTEXT]++)
		remaining /= big pf.context_prime;
		
	for(shape[SALIENCE] = 0; remaining % big pf.salience_prime == big 0; shape[SALIENCE]++)
		remaining /= big pf.salience_prime;
		
	for(shape[AUTONOMY_INDEX] = 0; remaining % big pf.autonomy_prime == big 0; shape[AUTONOMY_INDEX]++)
		remaining /= big pf.autonomy_prime;
	
	return shape;
}

PrimeFactors.validate(pf: self ref PrimeFactors, encoded: big): string
{
	if(encoded <= big 0)
		return "invalid prime encoding: must be positive";
	
	decoded := pf.decode(encoded);
	validator := TensorValidator.new();
	return validator.validateshape(decoded);
}

# Tensor fragment implementation
TensorFragment.new(modality, depth, context, salience, autonomy: int): ref TensorFragment
{
	tf := ref TensorFragment;
	tf.id = big sys->millisec();
	tf.shape = array[TENSOR_DIMENSIONS] of int;
	tf.shape[MODALITY] = modality;
	tf.shape[DEPTH] = depth;
	tf.shape[CONTEXT] = context;
	tf.shape[SALIENCE] = salience;
	tf.shape[AUTONOMY_INDEX] = autonomy;
	tf.agent_id = "";
	tf.state_type = "default";
	tf.timestamp = big sys->millisec();
	
	# Calculate tensor size and initialize data
	size := 1;
	for(i := 0; i < len tf.shape; i++)
		size *= tf.shape[i];
	if(size > 0)
		tf.data = array[size] of real;
	
	# Calculate prime encoding
	pf := PrimeFactors.new();
	tf.prime_encoding = pf.encode(tf.shape);
	
	return tf;
}

TensorFragment.setdata(tf: self ref TensorFragment, data: array of real)
{
	expected_size := 1;
	for(i := 0; i < len tf.shape; i++)
		expected_size *= tf.shape[i];
		
	if(len data == expected_size)
		tf.data = data;
}

TensorFragment.setagent(tf: self ref TensorFragment, agent_id: string)
{
	tf.agent_id = agent_id;
}

TensorFragment.setstate(tf: self ref TensorFragment, state_type: string)
{
	tf.state_type = state_type;
}

TensorFragment.validate(tf: self ref TensorFragment): string
{
	validator := TensorValidator.new();
	return validator.validatefull(tf);
}

TensorFragment.copy(tf: self ref TensorFragment): ref TensorFragment
{
	copy := ref TensorFragment;
	copy.id = big sys->millisec();
	copy.shape = array[len tf.shape] of int;
	for(i := 0; i < len tf.shape; i++)
		copy.shape[i] = tf.shape[i];
	
	if(tf.data != nil) {
		copy.data = array[len tf.data] of real;
		for(i := 0; i < len tf.data; i++)
			copy.data[i] = tf.data[i];
	}
	
	copy.agent_id = tf.agent_id;
	copy.state_type = tf.state_type;
	copy.timestamp = big sys->millisec();
	copy.prime_encoding = tf.prime_encoding;
	
	return copy;
}

# Hypergraph integration
TensorFragment.toatom(tf: self ref TensorFragment): ref Atom
{
	if(atomspace == nil)
		return nil;
		
	atom := atomspace->Atom.new("TensorFragment", tf.agent_id + ":" + tf.state_type);
	sexp := tf.tosexp();
	atom.setvalue(sexp);
	
	return atom;
}

TensorFragment.fromatom(atom: ref Atom): ref TensorFragment
{
	if(atom == nil || atom.value == nil)
		return nil;
		
	return TensorFragment.fromsexp(atom.value);
}

TensorFragment.tolink(tf: self ref TensorFragment, outgoing: list of ref Atom): ref Link
{
	if(atomspace == nil)
		return nil;
		
	# Add tensor fragment atom to outgoing list
	tensor_atom := tf.toatom();
	if(tensor_atom != nil)
		outgoing = tensor_atom :: outgoing;
	
	return atomspace->Link.new("TensorLink", outgoing);
}

# Serialization/deserialization
TensorFragment.serialize(tf: self ref TensorFragment): array of byte
{
	sexp := tf.tosexp();
	if(sexp == nil)
		return nil;
	return sexp.pack();
}

TensorFragment.deserialize(data: array of byte): ref TensorFragment
{
	if(sexprs == nil)
		return nil;
		
	(sexp, remaining, err) := sexprs->Sexp.unpack(data);
	if(err != nil)
		return nil;
		
	return TensorFragment.fromsexp(sexp);
}

TensorFragment.tosexp(tf: self ref TensorFragment): ref Sexp
{
	if(sexprs == nil)
		return nil;
	
	# Create S-expression representation: (tensor-fragment ...)
	elements: list of ref Sexp;
	
	# Add ID
	elements = ref Sexp.String(string tf.id, nil) :: elements;
	
	# Add shape as list
	shape_list: list of ref Sexp;
	for(i := len tf.shape - 1; i >= 0; i--)
		shape_list = ref Sexp.String(string tf.shape[i], nil) :: shape_list;
	elements = ref Sexp.List(shape_list) :: elements;
	
	# Add agent ID and state type
	elements = ref Sexp.String(tf.agent_id, nil) :: elements;
	elements = ref Sexp.String(tf.state_type, nil) :: elements;
	
	# Add timestamp and prime encoding
	elements = ref Sexp.String(string tf.timestamp, nil) :: elements;
	elements = ref Sexp.String(string tf.prime_encoding, nil) :: elements;
	
	# Add data if present
	if(tf.data != nil) {
		data_list: list of ref Sexp;
		for(i := len tf.data - 1; i >= 0; i--)
			data_list = ref Sexp.String(string tf.data[i], nil) :: data_list;
		elements = ref Sexp.List(data_list) :: elements;
	}
	
	# Create final S-expression
	elements = ref Sexp.String("tensor-fragment", nil) :: elements;
	return ref Sexp.List(elements);
}

TensorFragment.fromsexp(e: ref Sexp): ref TensorFragment
{
	if(e == nil || !e.islist())
		return nil;
		
	els := e.els();
	if(els == nil || len els < 7)
		return nil;
	
	# Check if it's a tensor-fragment
	if(hd els == nil || !isstring(hd els) || (hd els).astext() != "tensor-fragment")
		return nil;
	
	els = tl els;
	
	tf := ref TensorFragment;
	
	# Parse ID
	if(hd els != nil && isstring(hd els))
		tf.id = big (hd els).astext();
	els = tl els;
	
	# Parse shape
	if(hd els != nil && (hd els).islist()) {
		shape_els := (hd els).els();
		tf.shape = array[len shape_els] of int;
		for(i := 0; i < len shape_els && shape_els != nil; i++) {
			if(isstring(hd shape_els))
				tf.shape[i] = int (hd shape_els).astext();
			shape_els = tl shape_els;
		}
	}
	els = tl els;
	
	# Parse agent ID and state type
	if(hd els != nil && isstring(hd els))
		tf.agent_id = (hd els).astext();
	els = tl els;
	
	if(hd els != nil && isstring(hd els))
		tf.state_type = (hd els).astext();
	els = tl els;
	
	# Parse timestamp and prime encoding
	if(hd els != nil && isstring(hd els))
		tf.timestamp = big (hd els).astext();
	els = tl els;
	
	if(hd els != nil && isstring(hd els))
		tf.prime_encoding = big (hd els).astext();
	els = tl els;
	
	# Parse data if present
	if(els != nil && hd els != nil && (hd els).islist()) {
		data_els := (hd els).els();
		tf.data = array[len data_els] of real;
		for(i := 0; i < len data_els && data_els != nil; i++) {
			if(isstring(hd data_els))
				tf.data[i] = real (hd data_els).astext();
			data_els = tl data_els;
		}
	}
	
	return tf;
}

# Tensor operations
TensorFragment.reshape(tf: self ref TensorFragment, new_shape: array of int): string
{
	if(len new_shape != TENSOR_DIMENSIONS)
		return "shape must have exactly " + string TENSOR_DIMENSIONS + " dimensions";
	
	# Calculate sizes
	old_size := 1;
	for(i := 0; i < len tf.shape; i++)
		old_size *= tf.shape[i];
	
	new_size := 1;
	for(i := 0; i < len new_shape; i++)
		new_size *= new_shape[i];
	
	if(old_size != new_size)
		return "reshape must preserve total tensor size";
	
	# Validate new shape
	validator := TensorValidator.new();
	err := validator.validateshape(new_shape);
	if(err != nil)
		return err;
	
	# Update shape and prime encoding
	tf.shape = new_shape;
	pf := PrimeFactors.new();
	tf.prime_encoding = pf.encode(tf.shape);
	
	return nil;
}

TensorFragment.slice(tf: self ref TensorFragment, dim: int, index: int): ref TensorFragment
{
	if(dim < 0 || dim >= len tf.shape)
		return nil;
	if(index < 0 || index >= tf.shape[dim])
		return nil;
	
	# Create new tensor with reduced dimension
	new_shape := array[TENSOR_DIMENSIONS] of int;
	for(i := 0; i < len tf.shape; i++)
		new_shape[i] = tf.shape[i];
	new_shape[dim] = 1;
	
	result := TensorFragment.new(new_shape[MODALITY], new_shape[DEPTH], 
		new_shape[CONTEXT], new_shape[SALIENCE], new_shape[AUTONOMY_INDEX]);
	result.agent_id = tf.agent_id;
	result.state_type = tf.state_type + "_slice";
	
	return result;
}

TensorFragment.combine(tf1, tf2: self ref TensorFragment): ref TensorFragment
{
	if(tf1 == nil || tf2 == nil)
		return nil;
	
	# Simple combination: element-wise average
	if(len tf1.shape != len tf2.shape)
		return nil;
	
	for(i := 0; i < len tf1.shape; i++)
		if(tf1.shape[i] != tf2.shape[i])
			return nil;
	
	result := tf1.copy();
	result.state_type = tf1.state_type + "_combined";
	
	if(tf1.data != nil && tf2.data != nil && len tf1.data == len tf2.data) {
		for(i := 0; i < len result.data; i++)
			result.data[i] = (tf1.data[i] + tf2.data[i]) / 2.0;
	}
	
	return result;
}

TensorFragment.similarity(tf1, tf2: self ref TensorFragment): real
{
	if(tf1 == nil || tf2 == nil)
		return 0.0;
	
	# Shape similarity
	shape_sim := 0.0;
	if(len tf1.shape == len tf2.shape) {
		matches := 0;
		for(i := 0; i < len tf1.shape; i++)
			if(tf1.shape[i] == tf2.shape[i])
				matches++;
		shape_sim = real matches / real len tf1.shape;
	}
	
	# Data similarity (if both have data)
	data_sim := 0.0;
	if(tf1.data != nil && tf2.data != nil && len tf1.data == len tf2.data) {
		sum_diff := 0.0;
		for(i := 0; i < len tf1.data; i++)
			sum_diff += abs(tf1.data[i] - tf2.data[i]);
		data_sim = 1.0 - (sum_diff / real len tf1.data);
		if(data_sim < 0.0)
			data_sim = 0.0;
	}
	
	# Average of shape and data similarity
	return (shape_sim + data_sim) / 2.0;
}

# Tensor validator implementation
TensorValidator.new(): ref TensorValidator
{
	return ref TensorValidator;
}

TensorValidator.validateshape(tv: self ref TensorValidator, shape: array of int): string
{
	if(len shape != TENSOR_DIMENSIONS)
		return "tensor must have exactly " + string TENSOR_DIMENSIONS + " dimensions";
	
	if(shape[MODALITY] < 0 || shape[MODALITY] > MAX_MODALITY)
		return "modality must be between 0 and " + string MAX_MODALITY;
	
	if(shape[DEPTH] < 0 || shape[DEPTH] > MAX_DEPTH)
		return "depth must be between 0 and " + string MAX_DEPTH;
	
	if(shape[CONTEXT] < 0 || shape[CONTEXT] > MAX_CONTEXT)
		return "context must be between 0 and " + string MAX_CONTEXT;
	
	if(shape[SALIENCE] < 0 || shape[SALIENCE] > MAX_SALIENCE)
		return "salience must be between 0 and " + string MAX_SALIENCE;
	
	if(shape[AUTONOMY_INDEX] < 0 || shape[AUTONOMY_INDEX] > MAX_AUTONOMY)
		return "autonomy index must be between 0 and " + string MAX_AUTONOMY;
	
	return nil;
}

TensorValidator.validatedata(tv: self ref TensorValidator, tf: ref TensorFragment): string
{
	if(tf == nil)
		return "tensor fragment is nil";
	
	if(tf.data == nil)
		return nil; # Data is optional
	
	expected_size := 1;
	for(i := 0; i < len tf.shape; i++)
		expected_size *= tf.shape[i];
	
	if(len tf.data != expected_size)
		return "data size doesn't match tensor shape";
	
	return nil;
}

TensorValidator.validateagent(tv: self ref TensorValidator, agent_id: string): string
{
	if(agent_id == "")
		return "agent ID cannot be empty";
	
	if(len agent_id > 255)
		return "agent ID too long (max 255 characters)";
	
	return nil;
}

TensorValidator.validatefull(tv: self ref TensorValidator, tf: ref TensorFragment): string
{
	if(tf == nil)
		return "tensor fragment is nil";
	
	if(err := tv.validateshape(tf.shape); err != nil)
		return err;
	
	if(err := tv.validatedata(tf); err != nil)
		return err;
	
	if(tf.agent_id != "" && (err := tv.validateagent(tf.agent_id); err != nil))
		return err;
	
	return nil;
}

# Tensor collection implementation
TensorCollection.new(): ref TensorCollection
{
	tc := ref TensorCollection;
	tc.fragments = nil;
	tc.index = hash->new(101);
	tc.validator = TensorValidator.new();
	return tc;
}

TensorCollection.add(tc: self ref TensorCollection, tf: ref TensorFragment): string
{
	if(err := tc.validator.validatefull(tf); err != nil)
		return err;
	
	tc.fragments = tf :: tc.fragments;
	
	# Index by agent ID if available
	if(tf.agent_id != "")
		tc.index.insert(tf.agent_id, ref HashVal(int tf.id, 0.0, tf.agent_id));
	
	return nil;
}

TensorCollection.remove(tc: self ref TensorCollection, id: big): int
{
	new_fragments: list of ref TensorFragment;
	found := 0;
	
	for(fragments := tc.fragments; fragments != nil; fragments = tl fragments) {
		tf := hd fragments;
		if(tf.id != id)
			new_fragments = tf :: new_fragments;
		else {
			found = 1;
			if(tf.agent_id != "")
				tc.index.delete(tf.agent_id);
		}
	}
	
	tc.fragments = new_fragments;
	return found;
}

TensorCollection.find(tc: self ref TensorCollection, agent_id: string): ref TensorFragment
{
	for(fragments := tc.fragments; fragments != nil; fragments = tl fragments) {
		tf := hd fragments;
		if(tf.agent_id == agent_id)
			return tf;
	}
	return nil;
}

TensorCollection.findall(tc: self ref TensorCollection, state_type: string): list of ref TensorFragment
{
	result: list of ref TensorFragment;
	
	for(fragments := tc.fragments; fragments != nil; fragments = tl fragments) {
		tf := hd fragments;
		if(tf.state_type == state_type)
			result = tf :: result;
	}
	
	return result;
}

TensorCollection.export(tc: self ref TensorCollection): ref Sexp
{
	if(sexprs == nil)
		return nil;
	
	# Export as (tensor-collection ...)
	elements: list of ref Sexp;
	
	for(fragments := tc.fragments; fragments != nil; fragments = tl fragments) {
		tf := hd fragments;
		tf_sexp := tf.tosexp();
		if(tf_sexp != nil)
			elements = tf_sexp :: elements;
	}
	
	elements = ref Sexp.String("tensor-collection", nil) :: elements;
	return ref Sexp.List(elements);
}

TensorCollection.import(tc: self ref TensorCollection, e: ref Sexp): string
{
	if(e == nil || !e.islist())
		return "invalid S-expression format";
	
	els := e.els();
	if(els == nil || len els < 1)
		return "empty tensor collection";
	
	# Check if it's a tensor-collection
	if(hd els == nil || !isstring(hd els) || (hd els).astext() != "tensor-collection")
		return "not a tensor collection";
	
	els = tl els;
	
	# Clear existing data
	tc.clear();
	
	# Import each tensor fragment
	for(; els != nil; els = tl els) {
		tf := TensorFragment.fromsexp(hd els);
		if(tf != nil) {
			if(err := tc.add(tf); err != nil)
				return "failed to add tensor fragment: " + err;
		}
	}
	
	return nil;
}

TensorCollection.size(tc: self ref TensorCollection): int
{
	count := 0;
	for(fragments := tc.fragments; fragments != nil; fragments = tl fragments)
		count++;
	return count;
}

TensorCollection.clear(tc: self ref TensorCollection)
{
	tc.fragments = nil;
	tc.index = hash->new(101);
}

# Helper functions
isstring(e: ref Sexp): int
{
	if(e == nil)
		return 0;
	pick s := e {
	String => return 1;
	* => return 0;
	}
}

abs(x: real): real
{
	if(x < 0.0)
		return -x;
	return x;
}