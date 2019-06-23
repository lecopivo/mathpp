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

  return new immutable ComposeRightWith(homSetF, g);
}

immutable(Morphism) compose(immutable Morphism f, immutable Morphism g) {

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
    else if (!f.contains(x)) {
      auto xg = g.extract(x);
      return compose(compose(f, g.set()), xg);
    }
    else {
      if (!g.contains(x)) {
        auto xf = f.extract(x);
        return compose(compose(f.set(), g), xf);
      }
      else {
        assert(false, "Implement me!");
      }
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

/////////////////////////////////////////////////////////////
// Left Version

immutable class ComposeLeftWith : SymbolicMorphism {

  Morphism f;

  this(immutable Morphism _f, immutable CObject _homSetG) {
    assert(_homSetG.isHomSet(), "Input object has to be a HomSet!");

    f = _f;
    auto homSetG = cast(immutable HomSet)(_homSetG);

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
    else {
      assert(false, "Implement me!");
    }
  }
}

/////////////////////////////////////////////////////////////
// Right Version

immutable class ComposeRightWith : SymbolicMorphism {

  Morphism g;

  this(immutable CObject _homSetF, immutable Morphism _g) {
    assert(_homSetF.isHomSet(), "Input object has to be a HomSet!");

    g = _g;
    auto homSetF = cast(immutable HomSet)(_homSetF);

    assert(g.target().isEqual(homSetF.source()),
        "" ~ format!"Morphism `%s` is not right composable with morphisms in `%s` !"(g.fsymbol,
          homSetF.symbol));

    auto cat = meet(g.category(), homSetF.category());
    auto composedCat = meet(g.category(), homSetF.morphismCategory());

    auto src = homSetF;
    auto trg = composedCat.homSet(g.source(), homSetF.target());

    string sym = "(∘" ~ g.symbol() ~ ")";
    string tex = "\\left( \\circ " ~ g.latex() ~ " \\right)";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism f) immutable {
    assert(f.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(f, source()));

    return compose(f, g);
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || g.contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else {
      assert(false, "Implement me!");
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

  override immutable(Morphism) opCall(immutable Morphism f) immutable {

    assert(f.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(f.fsymbol, source().fsymbol));

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
      assert(false, "Implement me!");
      //return constantMap(x.set(), this);
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
