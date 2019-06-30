import nonsense;

//  __  __              _    _
// |  \/  |___ _ _ _ __| |_ (_)____ __
// | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|

abstract immutable class Morphism : ISymbolic {

  immutable(Category) category() immutable; // category in which it belongs
  immutable(CObject) set() immutable; // set in which it belongs, for true morphims it is some HomSet

  immutable(Morphism) opCall(immutable Morphism x) immutable;
  immutable(CObject) source() immutable;
  immutable(CObject) target() immutable;

  bool contains(immutable Morphism x) immutable;
  immutable(Morphism) extract(immutable Morphism x) immutable;

  // ISymbolic - I have to add it here again for some reason :(
  string symbol() immutable;
  string latex() immutable;
  ulong toHash() immutable;

  final bool isEqual(immutable Morphism s) immutable {
    return toHash() == s.toHash();
  }

}

//  ___    _         _   _ _
// |_ _|__| |___ _ _| |_(_) |_ _  _
//  | |/ _` / -_) ' \  _| |  _| || |
// |___\__,_\___|_||_\__|_|\__|\_, |
//                             |__/

immutable(Morphism) identity(immutable CObject obj) {
  return new immutable Identity(obj);
}

immutable class Identity : Morphism {

  CObject obj;

  this(immutable CObject _obj) {
    obj = _obj;
  }

  override immutable(Category) category() immutable {
    return obj.category();
  }

  override immutable(CObject) set() immutable {
    return category().homSet(source(), target());
  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable {
    return x;
  }

  override immutable(CObject) source() immutable {
    return obj;
  }

  override immutable(CObject) target() immutable {
    return obj;
  }

  override bool contains(immutable Morphism x) immutable {
    return true;
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else {
      return constantMap(x.set(), this);
    }
  }

  // Symbolic

  override string symbol() immutable {
    return "id";
  }

  override string latex() immutable {
    return "\\text{id}_{" ~ obj.latex() ~ "}";
  }

  override ulong toHash() immutable {
    return computeHash(obj, "Identity");
  }
}

//  ___          _        _   _
// | _ \_ _ ___ (_)___ __| |_(_)___ _ _
// |  _/ '_/ _ \| / -_) _|  _| / _ \ ' \
// |_| |_| \___// \___\__|\__|_\___/_||_|
//            |__/

immutable(Morphism) projection(immutable CObject obj, ulong index) {
  return new immutable Projection(obj, index);
}

immutable(Morphism) projection(immutable Morphism morph, ulong index) {
  if (morph.isElement()) {
    auto evaluated = cast(immutable Evaluated)(morph);
    auto prodMorph = cast(immutable IProductMorphism)(evaluated.morph);
    assert(evaluated && prodMorph, "Something is wrong!");
    return prodMorph[index](Zero);
  }
  else {
    return compose(morph.target().projection(index), morph);
  }
}

immutable class Projection : Morphism {

  CObject obj;
  ulong index;

  this(immutable CObject _obj, ulong _index) {

    obj = _obj;
    index = _index;

    auto pr = cast(immutable IProductObject)(obj);
    assert(pr, "Input object must be a product object");
    assert(index < pr.size(), "Index out of range!");
  }

  override immutable(Category) category() immutable {
    return obj.category();
  }

  override immutable(CObject) set() immutable {
    return category().homSet(source(), target());
  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable {
    assert(x.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(x.fsymbol, source().fsymbol));

    return evaluate(this, x);
  }

  override immutable(CObject) source() immutable {
    return obj;
  }

  override immutable(CObject) target() immutable {
    auto pr = cast(immutable IProductObject)(obj);
    return pr[index];
  }

  // Symbolic

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return x.set().identity();
    }
    else {
      return constantMap(x.set(), this);
    }
  }

  // ISymbolic - I have to add it here again for some reason :(
  override string symbol() immutable {
    return "π" ~ to!string(index);
  }

  override string latex() immutable {
    return "\\pi_{" ~ to!string(index) ~ "}";
  }

  override ulong toHash() immutable {
    return computeHash(obj, index, "Projection");
  }

}

//  ___            _         _ _      __  __              _    _
// / __|_  _ _ __ | |__  ___| (_)__  |  \/  |___ _ _ _ __| |_ (_)____ __
// \__ \ || | '  \| '_ \/ _ \ | / _| | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |___/\_, |_|_|_|_.__/\___/_|_\__| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//      |__/                                        |_|

immutable(Morphism) symbolicMorphism(immutable Category category,
    immutable CObject source, immutable CObject target, string symbol, string latex = "") {
  return new immutable SymbolicMorphism(category, source, target, symbol, latex);
}

immutable class SymbolicMorphism : Morphism {

  Category cat;

  CObject src;
  CObject trg;

  string sym;
  string tex;

  this(immutable Category _category, immutable CObject _source,
      immutable CObject _target, string _symbol, string _latex = "") {

    // string msg = "hovno";
    // const(char) [] er = "" ~ format!"efho %s"(msg);
    // assert(false, er);

    assert(_category.isObject(_source),
        "" ~ format!"The source object: `%s` is not in the category: `%s`"(_source, _category));
    assert(_category.isObject(_target),
        "" ~ format!"The target object: `%s` is not in the category: `%s`"(_target, _category));

    cat = _category;

    src = _source;
    trg = _target;

    sym = _symbol;
    tex = _latex == "" ? _symbol : _latex;
  }

  override immutable(Category) category() immutable {
    return cat;
  }

  override immutable(CObject) set() immutable {
    return category().homSet(source(), target());
  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable
  in(x.isElementOf(source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(x.fsymbol, source().fsymbol))
  out(r; r.isElementOf(target()),
      "" ~ format!"Output `%s` is not an element of the target `%s`!"(r.fsymbol, target().fsymbol))do {
    return lazyEvaluate(this, x);
  }

  override immutable(CObject) source() immutable {
    return src;
  }

  override immutable(CObject) target() immutable {
    return trg;
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else {
      return constantMap(x.set(), this);
    }
  }

  override string symbol() immutable {
    return sym;
  }

  override string latex() immutable {
    return tex;
  }

  override ulong toHash() immutable {
    import hash;

    return computeHash(cat, src, trg, sym, tex, "SymbolicMorphism");
  }
}
