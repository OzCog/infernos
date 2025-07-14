implement AtomSpace;

#
# AtomSpace: Hypergraph representation for cognitive reasoning
# Phase 1.1: Scheme Cognitive Grammar Microservices Implementation
#

include "sys.m";
	sys: Sys;

include "sexprs.m";
	sexprs: Sexprs;
	Sexp: import sexprs;

include "hash.m";
	hash: Hash;

include "lists.m";
	lists: Lists;

include "../../module/cognitive-synergy/atomspace.m";

init()
{
	sys = load Sys Sys->PATH;
	sexprs = load Sexprs Sexprs->PATH;
	hash = load Hash Hash->PATH;
	lists = load Lists Lists->PATH;
	if (sexprs == nil) {
		sys->print("cannot load %s: %r\n", Sexprs->PATH);
		exit;
	}
	if (hash == nil) {
		sys->print("cannot load %s: %r\n", Hash->PATH);
		exit;
	}
	if (lists == nil) {
		sys->print("cannot load %s: %r\n", Lists->PATH);
		exit;
	}
	sexprs->init();
	hash->init();
}

# Generate unique atom IDs
atomid_counter := big 1;

nextatomid(): big
{
	return atomid_counter++;
}

# Atom implementation
Atom.new(atomtype: string, name: string): ref Atom
{
	atom := ref Atom;
	atom.id = nextatomid();
	atom.type = atomtype;
	atom.name = name;
	atom.value = nil;
	atom.tv = TruthValue.new(1.0, 1.0);  # Default truth value
	return atom;
}

Atom.setvalue(atom: self ref Atom, value: ref Sexp)
{
	atom.value = value;
}

Atom.settruthvalue(atom: self ref Atom, tv: ref TruthValue)
{
	atom.tv = tv;
}

Atom.tostring(atom: self ref Atom): string
{
	valuestr := "";
	if (atom.value != nil)
		valuestr = " " + atom.value.text();
	tvstr := atom.tv.tostring();
	return sys->sprint("Atom[%bd](%s:%s%s) %s", atom.id, atom.type, atom.name, valuestr, tvstr);
}

Atom.tosexp(atom: self ref Atom): ref Sexp
{
	elements: list of ref Sexp;
	elements = ref Sexp.String("atom") :: elements;
	elements = ref Sexp.String(sys->sprint("%bd", atom.id)) :: elements;
	elements = ref Sexp.String(atom.type) :: elements;
	elements = ref Sexp.String(atom.name) :: elements;
	if (atom.value != nil)
		elements = atom.value :: elements;
	elements = atom.tv.tosexp() :: elements;
	return ref Sexp.List(lists->reverse(elements));
}

Atom.fromstring(s: string): ref Atom
{
	# Simple string parsing - could be enhanced
	atom := Atom.new("Node", s);
	return atom;
}

Atom.fromsexp(e: ref Sexp): ref Atom
{
	if (!e.islist() || len e.els() < 4)
		return nil;
	
	elems := e.els();
	if (hd elems == nil || !tagof(hd elems) == tagof(Sexp.String("")) || 
	    (hd elems).s != "atom")
		return nil;
	
	elems = tl elems;
	idstr := (hd elems).s;
	elems = tl elems;
	atomtype := (hd elems).s;
	elems = tl elems;
	name := (hd elems).s;
	
	atom := Atom.new(atomtype, name);
	atom.id = big idstr;
	
	if (elems != nil) {
		elems = tl elems;
		if (elems != nil)
			atom.value = hd elems;
	}
	
	return atom;
}

# TruthValue implementation
TruthValue.new(strength, confidence: real): ref TruthValue
{
	tv := ref TruthValue;
	tv.strength = strength;
	tv.confidence = confidence;
	return tv;
}

TruthValue.combine(tv1, tv2: self ref TruthValue): ref TruthValue
{
	# Simple truth value combination - could use more sophisticated methods
	newstrength := (tv1.strength * tv1.confidence + tv2.strength * tv2.confidence) / 
	               (tv1.confidence + tv2.confidence);
	newconfidence := tv1.confidence + tv2.confidence;
	if (newconfidence > 1.0)
		newconfidence = 1.0;
	return TruthValue.new(newstrength, newconfidence);
}

TruthValue.tostring(tv: self ref TruthValue): string
{
	return sys->sprint("<%.3f,%.3f>", tv.strength, tv.confidence);
}

TruthValue.tosexp(tv: self ref TruthValue): ref Sexp
{
	elements: list of ref Sexp;
	elements = ref Sexp.String("tv") :: elements;
	elements = ref Sexp.String(sys->sprint("%.6f", tv.strength)) :: elements;
	elements = ref Sexp.String(sys->sprint("%.6f", tv.confidence)) :: elements;
	return ref Sexp.List(lists->reverse(elements));
}

# Link implementation  
Link.new(linktype: string, outgoing: list of ref Atom): ref Link
{
	link := ref Link;
	link.atom = Atom.new(linktype, "");
	link.outgoing = outgoing;
	return link;
}

Link.arity(link: self ref Link): int
{
	return len link.outgoing;
}

Link.getoutgoing(link: self ref Link): list of ref Atom
{
	return link.outgoing;
}

Link.tosexp(link: self ref Link): ref Sexp
{
	elements: list of ref Sexp;
	elements = ref Sexp.String("link") :: elements;
	elements = link.atom.tosexp() :: elements;
	
	outgoing_sexps: list of ref Sexp;
	for (atoms := link.outgoing; atoms != nil; atoms = tl atoms)
		outgoing_sexps = (hd atoms).tosexp() :: outgoing_sexps;
	
	elements = ref Sexp.List(lists->reverse(outgoing_sexps)) :: elements;
	return ref Sexp.List(lists->reverse(elements));
}

Link.fromsexp(e: ref Sexp): ref Link
{
	if (!e.islist() || len e.els() < 3)
		return nil;
		
	elems := e.els();
	if (hd elems == nil || !tagof(hd elems) == tagof(Sexp.String("")) ||
	    (hd elems).s != "link")
		return nil;
	
	elems = tl elems;
	atom := Atom.fromsexp(hd elems);
	if (atom == nil)
		return nil;
	
	elems = tl elems;
	outgoing_list := hd elems;
	if (!outgoing_list.islist())
		return nil;
	
	outgoing: list of ref Atom;
	for (osexp := outgoing_list.els(); osexp != nil; osexp = tl osexp) {
		oatom := Atom.fromsexp(hd osexp);
		if (oatom != nil)
			outgoing = oatom :: outgoing;
	}
	
	link := ref Link;
	link.atom = atom;
	link.outgoing = lists->reverse(outgoing);
	return link;
}

# AtomSpace implementation
AtomSpace.new(): ref AtomSpace
{
	as := ref AtomSpace;
	as.atoms = hash->new(1009, nil);
	as.links = hash->new(1009, nil);
	as.index = hash->new(1009, nil);
	return as;
}

AtomSpace.add(as: self ref AtomSpace, atom: ref Atom): ref Atom
{
	as.atoms.add(atom.id, atom);
	
	# Update type index
	key := atom.type;
	existing := as.index.find(key);
	if (existing == nil)
		as.index.add(key, atom :: nil);
	else {
		atomlist := cast[list of ref Atom] existing;
		as.index.del(key);
		as.index.add(key, atom :: atomlist);
	}
	
	return atom;
}

AtomSpace.addlink(as: self ref AtomSpace, link: ref Link): ref Link
{
	# First add the link's atom
	as.add(link.atom);
	# Then add to links table
	as.links.add(link.atom.id, link);
	return link;
}

AtomSpace.find(as: self ref AtomSpace, atomtype, name: string): ref Atom
{
	typekey := atomtype;
	existing := as.index.find(typekey);
	if (existing == nil)
		return nil;
		
	atomlist := cast[list of ref Atom] existing;
	for (atoms := atomlist; atoms != nil; atoms = tl atoms) {
		atom := hd atoms;
		if (atom.name == name)
			return atom;
	}
	return nil;
}

AtomSpace.findall(as: self ref AtomSpace, atomtype: string): list of ref Atom
{
	existing := as.index.find(atomtype);
	if (existing == nil)
		return nil;
	return cast[list of ref Atom] existing;
}

AtomSpace.remove(as: self ref AtomSpace, atom: ref Atom): int
{
	found := as.atoms.find(atom.id);
	if (found == nil)
		return 0;
		
	as.atoms.del(atom.id);
	as.links.del(atom.id);
	
	# Update type index
	key := atom.type;
	existing := as.index.find(key);
	if (existing != nil) {
		atomlist := cast[list of ref Atom] existing;
		newlist: list of ref Atom;
		for (atoms := atomlist; atoms != nil; atoms = tl atoms) {
			if ((hd atoms).id != atom.id)
				newlist = hd atoms :: newlist;
		}
		as.index.del(key);
		if (newlist != nil)
			as.index.add(key, newlist);
	}
	
	return 1;
}

AtomSpace.clear(as: self ref AtomSpace)
{
	as.atoms = hash->new(1009, nil);
	as.links = hash->new(1009, nil);
	as.index = hash->new(1009, nil);
}

AtomSpace.size(as: self ref AtomSpace): int
{
	return as.atoms.len();
}

AtomSpace.export(as: self ref AtomSpace): ref Sexp
{
	elements: list of ref Sexp;
	elements = ref Sexp.String("atomspace") :: elements;
	
	atoms_list: list of ref Sexp;
	for (i := 0; i < as.atoms.len(); i++) {
		(id, atom) := as.atoms.itemno(i);
		if (atom != nil) {
			a := cast[ref Atom] atom;
			atoms_list = a.tosexp() :: atoms_list;
		}
	}
	
	links_list: list of ref Sexp;
	for (i := 0; i < as.links.len(); i++) {
		(id, link) := as.links.itemno(i);
		if (link != nil) {
			l := cast[ref Link] link;
			links_list = l.tosexp() :: links_list;
		}
	}
	
	elements = ref Sexp.List(lists->reverse(atoms_list)) :: elements;
	elements = ref Sexp.List(lists->reverse(links_list)) :: elements;
	return ref Sexp.List(lists->reverse(elements));
}

AtomSpace.import(as: self ref AtomSpace, e: ref Sexp): string
{
	if (!e.islist() || len e.els() < 3)
		return "Invalid atomspace format";
		
	elems := e.els();
	if (hd elems == nil || !tagof(hd elems) == tagof(Sexp.String("")) ||
	    (hd elems).s != "atomspace")
		return "Not an atomspace";
	
	# Clear existing content
	as.clear();
	
	elems = tl elems;
	atoms_sexp := hd elems;
	if (!atoms_sexp.islist())
		return "Invalid atoms list";
	
	# Import atoms
	for (asexp := atoms_sexp.els(); asexp != nil; asexp = tl asexp) {
		atom := Atom.fromsexp(hd asexp);
		if (atom != nil)
			as.add(atom);
	}
	
	elems = tl elems;
	if (elems != nil) {
		links_sexp := hd elems;
		if (links_sexp.islist()) {
			# Import links
			for (lsexp := links_sexp.els(); lsexp != nil; lsexp = tl lsexp) {
				link := Link.fromsexp(hd lsexp);
				if (link != nil)
					as.addlink(link);
			}
		}
	}
	
	return nil;
}