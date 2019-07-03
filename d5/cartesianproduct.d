import nonsense;

//                   _         _
//  _ __ _ _ ___  __| |_  _ __| |_
// | '_ \ '_/ _ \/ _` | || / _|  _|
// | .__/_| \___/\__,_|\_,_\__|\__|
// |_|

immutable(CObject) productObject(immutable CObject objX, immutable CObject objY) {
  return new immutable CartesianProductObject(objX, objY);
}

immutable(Morphism) product(immutable Morphism f, immutable Morphism g) {
  return new immutable CartesianProductMorphism(f, g);
}

immutable(Morphism) product(immutable Morphism f, immutable CObject homSetG) {
  return new immutable CartesianProductLeftWith(f, homSetG);
}

immutable(Morphism) product(immutable CObject homSetF, immutable Morphism g) {
  
  auto prod = product(homSetF, g.set());
  auto evalWithG = evalWith(g, prod.target());
  
  return compose(evalWithG, prod);
}

immutable(Morphism) product(immutable CObject homSetF, immutable CObject homSetG) {
  return new immutable CartesianProduct(homSetF, homSetG);
}

//  ___             _         _      ___  _     _        _
// | _ \_ _ ___  __| |_  _ __| |_   / _ \| |__ (_)___ __| |_
// |  _/ '_/ _ \/ _` | || / _|  _| | (_) | '_ \| / -_) _|  _|
// |_| |_| \___/\__,_|\_,_\__|\__|  \___/|_.__// \___\__|\__|
//                                           |__/

immutable class CartesianProductObject : SymbolicObject, IProductObject {

  CObject[2] obj;

  this(immutable CObject objX, immutable CObject objY) {
    obj = [objX, objY];

    auto cat = meet(objX.category, objY.category);

    auto sym = "(" ~ objX.symbol() ~ operation() ~ objY.symbol() ~ ")";
    auto tex = "\\left( " ~ objX.latex() ~ " " ~ latexOperation() ~ " " ~ objY.latex() ~ " \\right)";

    super(cat, sym, tex);
  }

  string opName() immutable {
    return "CartesianProduct";
  }

  string operation() immutable {
    return "✕";
  }

  string latexOperation() immutable {
    return "\\times";
  }

  ulong size() immutable {
    return 2;
  }

  immutable(CObject) opIndex(ulong I) immutable {
    return obj[I];
  }
}

//  __  __      _         ___      _
// |  \/  |__ _| |_____  | _ \__ _(_)_ _
// | |\/| / _` | / / -_) |  _/ _` | | '_|
// |_|  |_\__,_|_\_\___| |_| \__,_|_|_|

immutable(Morphism) makePair(immutable Morphism x, immutable Morphism y) {
  return lazyEvaluate(product(elementMap(x), elementMap(y)), Zero);
}

//  ___             _         _     __  __              _    _
// | _ \_ _ ___  __| |_  _ __| |_  |  \/  |___ _ _ _ __| |_ (_)____ __
// |  _/ '_/ _ \/ _` | || / _|  _| | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_| |_| \___/\__,_|\_,_\__|\__| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                                                |_|

immutable class CartesianProductMorphism : SymbolicMorphism, IProductMorphism, IHasGradient {

  Morphism[2] morph;

  this(immutable Morphism f, immutable Morphism g) {

    morph = [f, g];

    assert(f.isMorphism && g.isMorphism, "Cannot construct cartesian product from elements!");

    assert(f.source().isEqual(g.source()),
        "" ~ format!"Morphism `%s` and `%s` do not share the same source!"(f.fsymbol, g.fsymbol));

    auto cat = meet(f.category, g.category);

    auto src = f.source;
    auto trg = productObject(f.target, g.target);

    auto sym = "(" ~ f.symbol ~ operation() ~ g.symbol ~ ")";
    auto tex = "\\left( " ~ f.latex() ~ " " ~ latexOperation() ~ " " ~ g.latex() ~ " \\right)";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism x) {
    assert(x.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(x.fsymbol, source().fsymbol));

    return makePair(morph[0](x), morph[1](x));
  }
  
  immutable(Morphism) gradient() immutable{
    auto x = symbolicElement(source(), "temporary_element_x_cartesian_product_grad");
    return product(morph[0].grad()(x), morph[1].grad()(x)).extract(x);
  }

  string opName() immutable {
    return "CartesianProduct";
  }

  string operation() immutable {
    return "✕";
  }

  string latexOperation() immutable {
    return "\\times";
  }

  ulong size() immutable {
    return 2;
  }

  immutable(Morphism) opIndex(ulong I) immutable {
    return morph[I];
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || morph[0].contains(x) || morph[1].contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else {

      bool m0 = morph[0].contains(x);
      bool m1 = morph[1].contains(x);

      if (!m0 && !m1)
        return constantMap(x.set(), this);

      if (m0 && !m1)
        return compose(product(morph[0].set(), morph[1]), morph[0].extract(x));

      if (!m0 && m1)
        return compose(product(morph[0], morph[1].set()), morph[1].extract(x));

      if (m0 && m1) {
	auto tmp = compose(product(morph[0].set(), morph[1].set()), morph[0].extract(x));
	auto tmp2 = compose(compose(tmp.target(), morph[1].extract(x)), tmp);
	return contract(tmp2);
      }

      assert(false, "This is should be unreachable!");
    }
  }
}

//  ___             _         _    __      ___ _   _
// | _ \_ _ ___  __| |_  _ __| |_  \ \    / (_) |_| |_
// |  _/ '_/ _ \/ _` | || / _|  _|  \ \/\/ /| |  _| ' \
// |_| |_| \___/\__,_|\_,_\__|\__|   \_/\_/ |_|\__|_||_|

immutable class CartesianProductLeftWith : SymbolicMorphism, IHasGradient {

  Morphism f;
  HomSet homSetG;

  this(immutable Morphism _f, immutable CObject _homSetG) {
    assert(_homSetG.isHomSet(), "Input object has to be a HomSet!");

    f = _f;
    homSetG = cast(immutable HomSet)(_homSetG);

    assert(f.source().isEqual(homSetG.source()),
        "" ~ format!"Morphism `%s` has to share the same source as morphisms in `%s` !"(f.fsymbol,
          homSetG.symbol));

    auto cat = (f.isZero() ? Vec : f.category()).meet(homSetG.category());
    auto resultCat = meet(f.category(), homSetG.morphismCategory());

    auto src = homSetG;
    auto trg = resultCat.homSet(homSetG.source(), productObject(f.target(), homSetG.target()));

    string sym = "(" ~ f.symbol() ~ "✕)";
    string tex = "\\left( " ~ f.latex() ~ " \\times \\right)";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism g) immutable {
    assert(g.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(g, source()));

    return product(f, g);
  }
  
  immutable(Morphism) gradient() immutable{
    
    return constantMap(homSetG, product( f.set().zeroElement(), homSetG));
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
      return compose(product(f.set(), homSetG), fe);
    }
  }
}

//  ___             _
// | _ \_ _ ___  __| |
// |  _/ '_/ _ \/ _` |
// |_| |_| \___/\__,_|

immutable class CartesianProduct : SymbolicMorphism {

  HomSet homSetF;
  HomSet homSetG;

  this(immutable CObject _homSetF, immutable CObject _homSetG) {
    assert(_homSetF.isHomSet(), "Input object has to be a HomSet!");
    assert(_homSetG.isHomSet(), "Input object has to be a HomSet!");

    homSetF = cast(immutable HomSet)(_homSetF);
    homSetG = cast(immutable HomSet)(_homSetG);

    assert(homSetF.source().isEqual(homSetG.source()),
        "" ~ format!"Horphisms in `%s` and `%s` have to share the same source!"(homSetG.symbol,
          homSetF.symbol));

    auto cat = meet(homSetF.category(), homSetG.category()).meet(Pol);

    auto resultCat = meet(homSetF.morphismCategory(), homSetG.morphismCategory());
    auto resultHomSet = resultCat.homSet(homSetF.source(),
        productObject(homSetF.target(), homSetG.target()));

    auto middleCat = meet(Pol, meet(homSetG.category(), resultHomSet.category()));

    auto src = homSetF;
    auto trg = middleCat.homSet(homSetG, resultHomSet);

    super(cat, src, trg, "Prod", "\\text{Prod}");
  }

  override immutable(Morphism) opCall(immutable Morphism f) immutable {
    assert(f.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(f, source()));

    return product(f, homSetG);
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
}

unittest {

  auto X = symbolicObject(Set, "X");
  auto Y = symbolicObject(Set, "Y");
  auto Z = symbolicObject(Set, "Z");
  auto A = symbolicObject(Set, "A");

  auto x = symbolicElement(X, "x");
  auto y = symbolicElement(Y, "y");
  auto z = symbolicElement(Z, "z");
  auto a = symbolicElement(A, "a");

  auto h = symbolicMorphism(Set, Z, X, "h");
  auto phi = symbolicMorphism(Set, X, Y, "phi", "\\phi");
  auto psi = symbolicMorphism(Set, X, Z, "psi", "\\psi");
  auto F = symbolicMorphism(Set, A, Set.homSet(X, Y), "F");
  auto G = symbolicMorphism(Set, A, Set.homSet(X, Z), "G");
  //auto H = symbolicMorphism(Set, A, Set.homSet(Y, Z), "H");

  // Test of canceling projection applied on a product morphism
  assert(phi(x).isEqual(product(phi, psi)(x).projection(0)));
  assert(psi(x).isEqual(product(phi, psi)(x).projection(1)));

  // Test that all possible product constructions yield the same result
  auto phixpsi = product(phi, psi);
  assert(phixpsi.isEqual(product(phi.set(), psi)(phi)));
  assert(phixpsi.isEqual(product(phi, psi.set())(psi)));
  assert(phixpsi.isEqual(product(phi.set(), psi.set())(phi)(psi)));

  // Distribution of composition over product is tested when evaluated
  assert(product(phi, psi)(h(z)).isEqual(compose(product(phi, psi), h)(z)));

  // pairs
  assert(makePair(x, y).isEqual(makePair(x, y).extract(x)(x)));
  assert(makePair(x, y).isEqual(makePair(x, y).extract(y)(y)));
  assert(makePair(x, y).isEqual(makePair(x, y).extract(y).extract(x)(x)(y)));
  assert(makePair(x, y).isEqual(makePair(x, y).extract(x).extract(y)(y)(x)));

  // Cartesion product tests
  assert(F.isEqual(F(a)(x).extract(x).extract(a)));
  assert(F(a)(x).isEqual(F(a)(x).extract(a)(a)));
  assert(F(a)(x).isEqual(F(a)(x).extract(a).extract(x)(x)(a)));

  // Test of extractions
  assert(product(F(a), Set.homSet(X, Z)).isEqual(product(F(a), Set.homSet(X, Z)).extract(a)(a)));
  assert(product(Set.homSet(X, Z), F(a)).isEqual(product(Set.homSet(X, Z), F(a)).extract(a)(a)));
  assert(product(F(a), G(a))(x).isEqual(product(F(a), G(a))(x).extract(a)(a)));
}
