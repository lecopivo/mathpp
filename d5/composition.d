import nonsense;

//  __ ___ _ __  _ __  ___ ___ ___
// / _/ _ \ '  \| '_ \/ _ (_-</ -_)
// \__\___/_|_|_| .__/\___/__/\___|
//              |_|

immutable(Morphism) compose(immutable CObject homSetF, immutable CObject homSetG) {
  return new immutable Compose(homSetF, homSetG);
}

immutable(Morphism) compose(immutable Morphism f, immutable CObject homSetG) {

  if (f.isIdentity)
    return homSetG.identity();

  return new immutable ComposeLeftWith(f, homSetG);
}

immutable(Morphism) compose(immutable CObject homSetF, immutable Morphism g) {

  if (g.isIdentity)
    return homSetF.identity();
  
  auto comp = compose(homSetF, g.set());
  auto evalWithG = evalWith(g, comp.target());
  
  return compose(evalWithG, comp);
}

immutable(Morphism) compose(immutable Morphism f, immutable Morphism g) {

  assert(f.source().isEqual(g.target()),
      "" ~ format!"Morphism `%s` and `%s` are not composable!"(g.fsymbol, f.fsymbol));

  // Basic optimizations
  if (g.isIdentity)
    return f;

  if (f.isIdentity)
    return g;

  // calcelation of projection with product morphisms
  if (f.isProjection && g.isProductMorphism) {
    auto pi = cast(immutable Projection)(f);
    auto pr = cast(immutable IProductMorphism)(g);
    return pr[pi.index];
  }

  // distribution of ∘ over ✕
  if (f.isProductMorphism) {
    auto pr = cast(immutable IProductMorphism)(f);
    return product(compose(pr[0], g), compose(pr[1], g));
  }

  // Composing with zero morphism 0 ⟶ 0
  if (g.source().isEqual(ZeroSet) && g.target().isEqual(ZeroSet)) {
    return f;
  }

  // shortcut for terminal morphism
  if (f.isTerminalMorphism()) {
    return terminalMorphism(g.source());
  }

  return new immutable ComposedMorphism(f, g);
}

//   ___                                _   __  __              _    _
//  / __|___ _ __  _ __  ___ ___ ___ __| | |  \/  |___ _ _ _ __| |_ (_)____ __
// | (__/ _ \ '  \| '_ \/ _ (_-</ -_) _` | | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
//  \___\___/_|_|_| .__/\___/__/\___\__,_| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|                                     |_|

immutable class ComposedMorphism : Morphism, IOpResult!Morphism {

  Morphism f;
  Morphism g;

  this(immutable Morphism _f, immutable Morphism _g) {

    f = _f;
    g = _g;

    assert(f.source().isEqual(g.target()),
        "" ~ format!"Morphisms `%s` and `%s` are not composable!"(f.fsymbol, g.fsymbol));
  }

  override immutable(Category) category() immutable {
    return meet(f.category(), g.category());
  }

  override immutable(CObject) set() immutable {
    return category().homSet(source(), target());
  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable {
    return f(g(x));
  }

  override immutable(CObject) source() immutable {
    return g.source();
  }

  override immutable(CObject) target() immutable {
    return f.target();
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
        return compose(compose(f.set(), g), f.extract(x));

      if (!cf && cg)
        return compose(compose(f, g.set()), g.extract(x));

      if (cf && cg) {
	auto tmp = compose(compose(f.set(), g.set()), f.extract(x));
	auto tmp2 = compose(compose(tmp.target(), g.extract(x)), tmp);
	return contract(tmp2);
      }

      assert(false, "This is should be unreachable!");
    }
  }

  // IOpResult
  string opName() immutable {
    return "Composition";
  }

  string operation() immutable {
    return "∘";
  }

  string latexOperation() immutable {
    return "\\circ";
  }

  ulong size() immutable {
    return 2;
  }

  immutable(Morphism) opIndex(ulong I) immutable {
    return I == 0 ? f : g;
  }

  // Symbolic 
  override string symbol() immutable {
    return "(" ~ f.symbol() ~ "∘" ~ g.symbol() ~ ")";
  }

  override string latex() immutable {
    return "\\left( " ~ f.latex() ~ " \\circ " ~ g.latex() ~ " \\right)";
  }

  override ulong toHash() immutable {
    return computeHash(f, g, "ComposedMorphism");
  }

}

//   ___                              __      ___ _   _
//  / __|___ _ __  _ __  ___ ___ ___  \ \    / (_) |_| |_
// | (__/ _ \ '  \| '_ \/ _ (_-</ -_)  \ \/\/ /| |  _| ' \
//  \___\___/_|_|_| .__/\___/__/\___|   \_/\_/ |_|\__|_||_|
//                |_|

immutable class ComposeLeftWith : SymbolicMorphism {

  Morphism f;
  HomSet homSetG;

  this(immutable Morphism _f, immutable CObject _homSetG) {
    assert(_homSetG.isHomSet(), "Input object has to be a HomSet!");

    f = _f;
    homSetG = cast(immutable HomSet)(_homSetG);

    assert(f.source().isEqual(homSetG.target()),
        "" ~ format!"Morphism `%s` is not left composable with morphisms in `%s` !"(f.fsymbol,
          homSetG.symbol));

    auto cat = meet(f.category(), homSetG.category());
    auto composedCat = meet(f.category(), homSetG.morphismCategory());

    auto src = homSetG;
    auto trg = composedCat.homSet(homSetG.source(), f.target());

    string sym = "(" ~ f.symbol() ~ "∘)";
    string tex = "\\left( " ~ f.latex() ~ " \\circ \\right)";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism g) immutable {
    assert(g.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(g, source()));

    return compose(f, g);
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || f.contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if (!contains(x)) {
      return constantMap(x.set(), this);
    }
    else {
      auto fe = f.extract(x);
      return compose(compose(f.set(), homSetG), fe);
    }
  }
}

//   ___
//  / __|___ _ __  _ __  ___ ___ ___
// | (__/ _ \ '  \| '_ \/ _ (_-</ -_)
//  \___\___/_|_|_| .__/\___/__/\___|
//                |_|

immutable class Compose : Morphism {

  HomSet homSetF;
  HomSet homSetG;

  this(immutable CObject _homSetF, immutable CObject _homSetG) {
    assert(_homSetF.isHomSet(), "Input object has to be a HomSet!");
    assert(_homSetG.isHomSet(), "Input object has to be a HomSet!");

    homSetF = cast(immutable HomSet)(_homSetF);
    homSetG = cast(immutable HomSet)(_homSetG);

    assert(homSetF.source().isEqual(homSetG.target()),
        "" ~ format!"Homrphisms from sets `%s` and `%s` are not composable!"(homSetG.symbol,
          homSetF.symbol));
  }

  override immutable(Category) category() immutable {
    return homSetF.category();
  }

  override immutable(CObject) set() immutable {
    return category().homSet(source(), target());
  }

  override immutable(Morphism) opCall(immutable Morphism f) immutable
  in(f.isElementOf(source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(f.fsymbol, source().fsymbol))
  out(r; r.isElementOf(target()),
      "" ~ format!"Output `%s` is not an element of the target `%s`!"(r.fsymbol, target().fsymbol))do {

    return compose(f, homSetG);
  }

  override immutable(CObject) source() immutable {
    return homSetF;
  }

  override immutable(CObject) target() immutable {
    auto composeWithCat = meet(homSetF.morphismCategory(), homSetG.category());

    auto morphCat = meet(homSetF.morphismCategory(), homSetG.morphismCategory());
    auto morphHomSet = morphCat.homSet(homSetG.source(), homSetF.target());
    return composeWithCat.homSet(homSetG, morphHomSet);
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

  // Symbolic
  override string symbol() immutable {
    return "Comp";
  }

  override string latex() immutable {
    return "\\text{Comp}";
  }

  override ulong toHash() immutable {
    return computeHash(homSetF, homSetG, "Compose");
  }
}

unittest {

  auto X = symbolicObject(Set, "X");
  auto Y = symbolicObject(Set, "Y");
  auto Z = symbolicObject(Set, "Z");
  auto A = symbolicObject(Set, "A");

  auto g = symbolicMorphism(Set, X, Y, "g");
  auto f = symbolicMorphism(Set, Y, Z, "f");
  auto h = symbolicMorphism(Set, Z, X, "h");
  auto F = symbolicMorphism(Set, A, Set.homSet(X, Y), "F");
  auto G = symbolicMorphism(Set, A, Set.homSet(X, Z), "G");
  auto H = symbolicMorphism(Set, A, Set.homSet(Y, Z), "H");

  auto x = symbolicElement(X, "x");
  auto y = symbolicElement(Y, "y");
  auto z = symbolicElement(Z, "z");
  auto a = symbolicElement(A, "a");

  // Test of that extracting and then applying should yield the same thing!
  assert(x.isEqual(x.extract(x)(x)));
  assert(y.isEqual(y.extract(x)(x)));
  assert(compose(f, g).isEqual(compose(f, g).extract(g)(g)));
  assert(g(x).isEqual(g(x).extract(x)(x)));
  assert(g(x).isEqual(g(x).extract(g)(g)));

  // Associativity of composition is checked when evaluated
  assert(compose(f, g)(x).isEqual(f(g(x))));

  // Compostion tests
  assert(compose(F(a), Set.homSet(Z, X)).isEqual(compose(F(a), Set.homSet(Z, X)).extract(a)(a)));
  assert(compose(Set.homSet(Y, Z), F(a)).isEqual(compose(Set.homSet(Y, Z), F(a)).extract(a)(a)));
  assert(compose(H(a), F(a)).isEqual(compose(H(a), F(a)).extract(a)(a)));
}
