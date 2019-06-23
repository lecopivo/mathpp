import nonsense;

immutable(Morphism) compose(immutable CObject homSetF, immutable CObject homSetG) {
  return new immutable Compose(homSetF, homSetG);
}

immutable(Morphism) compose(immutable Morphism f, immutable CObject homSetG) {
  return compose(f.set(), homSetG)(f);
}

immutable(Morphism) compose(immutable Morphism f, immutable Morphism g) {
  return compose(f.set(), g.set())(f)(g);
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
      if(!g.contains(x)){
	assert(false, "Implement me!");
      }else{
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

immutable class ComposeWith : Morphism {

  Morphism morphF;
  HomSet homSetG;

  this(immutable Morphism _morphF, immutable CObject _homSetG) {
    assert(_homSetG.isHomSet(), "Input object has to be a HomSet!");

    morphF = _morphF;
    homSetG = cast(immutable HomSet)(_homSetG);

    assert(morphF.source().isEqual(homSetG.target()),
        "" ~ format!"Morphism `%s` is not left composable with morphisms in `%s` !"(morphF.fsymbol,
          homSetG.symbol));
  }

  override immutable(Category) category() immutable {
    return meet(morphF.category(), homSetG.category());
  }

  override immutable(CObject) set() immutable {
    return category().homSet(source(), target());
  }

  override immutable(Morphism) opCall(immutable Morphism g) immutable {
    assert(g.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(g, source()));

    if (g.isIdentity)
      return morphF;

    if (g.source().isEqual(ZeroSet) && g.target().isEqual(ZeroSet)) {
      return morphF;
    }

    auto morphCat = meet(morphF.category(), homSetG.morphismCategory());
    if (morphF.target().isTerminalObjectIn(morphCat)) {
      return symbolicMorphism(morphCat, homSetG.source(), morphF.target(), "0", "0");
    }
    else {
      return new immutable ComposedMorphism(morphF, g);
    }
  }

  override immutable(CObject) source() immutable {
    return homSetG;
  }

  override immutable(CObject) target() immutable {
    // This implementation is reduntant and probably error prodne
    // non redundant implementation would be
    auto morphCat = meet(morphF.category(), homSetG.morphismCategory());
    return morphCat.homSet(homSetG.source(), morphF.target());
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || morphF.contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else {
      assert(false, "Implement me!");
    }
  }

  // Symbolic

  override string symbol() immutable {
    return "(" ~ morphF.symbol() ~ "∘)";
  }

  override string latex() immutable {
    return "\\left( " ~ morphF.latex() ~ " \\circ \\right)";
  }

  override ulong toHash() immutable {
    return computeHash(morphF.toHash(), homSetG.toHash(), "ComposeWith");
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

    if (f.isIdentity())
      return homSetG.identity();

    return new immutable ComposeWith(f, homSetG);
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
