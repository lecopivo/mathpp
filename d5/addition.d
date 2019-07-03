import nonsense;

immutable class AdditionOp : Operation {

  override string opName() immutable {
    return "addition";
  }

  override string symbol() immutable {
    return "+";
  }

  override string latex() immutable {
    return "+";
  }

  override ulong arity() immutable {
    return 2;
  }
}

//    _      _    _
//   /_\  __| |__| |
//  / _ \/ _` / _` |
// /_/ \_\__,_\__,_|

immutable(Morphism) add(immutable Morphism x, immutable Morphism y) {
  assert(x.set().isEqual(y.set()), ""~format!"Set of `%s` and `%s` must be equal!"(x.fsymbol, y.fsymbol));

  if (x.isElement && y.isElement) {
    return lazyEvaluate(add(elementMap(x), elementMap(y)), Zero);
  }
  else {
    return new immutable AdditionMorphism(x, y);
  }
}

immutable(Morphism) add(immutable Morphism f, immutable CObject homSet){
 
  assert(homSet.isEqual(f.set()), ""~format!"HomSet `%s` does not match set of morphism `%s`"(homSet.fsymbol, f.fsymbol));
  
  return new immutable AdditionFromLeftMorphism(f);
}

immutable(Morphism) add(immutable CObject homSet, immutable Morphism g){
 
  assert(homSet.isEqual(g.set()), ""~format!"HomSet `%s` does not match set of morphism `%s`"(homSet.fsymbol, g.fsymbol));
  
  return add(homSet, homSet).swapArguments()(g);
}

immutable(Morphism) add(immutable CObject homSetF, immutable CObject homSetG){
  
  assert(homSetF.isEqual(homSetG), ""~format!"Invalid input! HomSet `%s` does not equal to HomSet `%s`"(homSetF.fsymbol, homSetG.fsymbol));
  
  return new immutable Addition(homSetF);
}


//    _      _    _ _ _   _            __  __              _    _
//   /_\  __| |__| (_) |_(_)___ _ _   |  \/  |___ _ _ _ __| |_ (_)____ __
//  / _ \/ _` / _` | |  _| / _ \ ' \  | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// /_/ \_\__,_\__,_|_|\__|_\___/_||_| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                                                   |_|


immutable class AdditionMorphism : SymbolicMorphism, IOpResult!(Morphism), IHasGradient {

  Morphism f;
  Morphism g;

  this(immutable Morphism _f, immutable Morphism _g) {

    f = _f;
    g = _g;

    assert(f.source().isEqual(g.source()),
        "" ~ format!"Invalid input! Morphisms `%s` and `%s` has to share the same source!"(f.fsymbol,
          g.fsymbol));
    assert(f.target().isEqual(g.target()),
        "" ~ format!"Invalid input! Morphisms `%s` and `%s` has to share the same target!"(f.fsymbol,
          g.fsymbol));
    assert(f.target().isIn(Vec),
        "" ~ format!"Invalid input! The target of morphism `%s` has to be a vector space!"(
          f.fsymbol));

    auto cat = meet(f.category(), g.category());
    auto src = f.source();
    auto trg = f.target();

    string sym = f.symbol() ~ "+" ~ g.symbol();
    string tex = f.latex() ~ " + " ~ g.latex();

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable
  in(x.isElementOf(source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(x.fsymbol, source().fsymbol))
  out(r; r.isElementOf(target()),
      "" ~ format!"Output `%s` is not an element of the target `%s`!"(r.fsymbol, target().fsymbol))do {
    return add(f(x), g(x));
  }
  
  immutable(Morphism) gradient() immutable{
    return add(f.grad, g.grad);
  }
  
  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || f.contains(x) || g.contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else {

      bool cf = f.contains(x);
      bool cg = g.contains(x);

      if (!cf && !cg)
        return constantMap(x.set(), this);

      if (cf && !cg)
        return compose(add(f.set(), g), f.extract(x));

      if (!cf && cg)
        return compose(add(f, g.set()), g.extract(x));

      if (cf && cg) {
        // auto tmp = compose(add(f.set(), g.set()), f.extract(x));
        // auto tmp2 = compose(compose(tmp.target(), g.extract(x)), tmp);
        // return contract(tmp2);
	return add(f.extract(x), g.extract(x));
      }

      assert(false, "This is should be unreachable!");
    }
  }

  string opName() immutable {
    return "addition";
  }

  string operation() immutable {
    return "+";
  }

  string latexOperation() immutable {
    return "+";
  }

  ulong size() immutable {
    return 2;
  }

  immutable(Morphism) opIndex(ulong I) immutable {
    assert(I < 2, "Invalid input!");
    return I == 0 ? f : g;
  }
}

//    _      _    _ _ _   _            ___                _         __ _
//   /_\  __| |__| (_) |_(_)___ _ _   | __| _ ___ _ __   | |   ___ / _| |_
//  / _ \/ _` / _` | |  _| / _ \ ' \  | _| '_/ _ \ '  \  | |__/ -_)  _|  _|
// /_/ \_\__,_\__,_|_|\__|_\___/_||_| |_||_| \___/_|_|_| |____\___|_|  \__|


immutable class AdditionFromLeftMorphism : SymbolicMorphism, IHasGradient {

  Morphism f;

  this(immutable Morphism _f) {

    f = _f;

    assert(f.target().isIn(Vec),
        "" ~ format!"Invalid input! The target of morphism `%s` has to be a vector space!"(
          f.fsymbol));

    auto cat = Pol;
    auto src = f.set();
    auto trg = f.set();

    string sym = f.symbol ~ "+";
    string tex = f.latex ~ " +";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism g) immutable
  in(g.isElementOf(source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(g.fsymbol, source().fsymbol))
  out(r; r.isElementOf(target()),
      "" ~ format!"Output `%s` is not an element of the target `%s`!"(r.fsymbol, target().fsymbol))do {
    return add(f, g);
  }
  
  immutable(Morphism) gradient() immutable{
    return constantMap(source(), source().identity());
  }
  
  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || f.contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if(!f.contains(x)){
      return constantMap(x.set(), this);
    }else{
      return compose(add(f.set(), f.set()), f.extract(x));
    }
  }
}

//    _      _    _ _ _   _
//   /_\  __| |__| (_) |_(_)___ _ _
//  / _ \/ _` / _` | |  _| / _ \ ' \
// /_/ \_\__,_\__,_|_|\__|_\___/_||_|

immutable class Addition : SymbolicMorphism, IHasGradient {

  HomSet homSet;

  this(immutable CObject _homSet) {

    homSet = cast(immutable HomSet) _homSet;

    assert(homSet,
        "" ~ format!"Invalid input! Input object `%s` has to be a HomSet!"(_homSet.fsymbol));
    assert(homSet.target().isIn(Vec),
        "" ~ format!"Invalid input! The target of `%s` has to be a vector space!"(homSet.fsymbol));
    
    auto cat = Pol;
    auto src = homSet;
    auto trg = Pol.homSet(homSet, homSet);
    
    string sym = "Add";
    string tex = "\\text{Add}";
    
    super(cat, src, trg, sym, tex);
  }
  
  override immutable(Morphism) opCall(immutable Morphism f) immutable
  in(f.isElementOf(source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(f.fsymbol, source().fsymbol))
  out(r; r.isElementOf(target()),
      "" ~ format!"Output `%s` is not an element of the target `%s`!"(r.fsymbol, target().fsymbol))do {
      return add(f, f.set());
  }
  
  immutable(Morphism) gradient() immutable{
    return constantMap(source(), makeConstant(homSet,homSet));
  }

}
