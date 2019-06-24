import nonsense;

immutable(Morphism) symbolicElement(immutable CObject obj, string symbol, string latex = "") {
  auto cat = obj.isIn(Vec) ? Pol : Set;
  return evaluate(symbolicMorphism(cat, ZeroSet, obj, symbol, latex), Zero);
}

// This function takes a function A→((X→Y)✕X) and produces A→Y
immutable(Morphism) evaluate(immutable Morphism morph) {
  if (morph.isMorphism) {
    assert(morph.target().isProductObject(),
        "" ~ format!"Invalid input morphism `%s`, expected form of the morphism is A→((X→Y)✕X)"(
          morph.fsymbol));

    auto prodObj = cast(immutable IProductObject) morph.target();
    auto homSet = cast(immutable HomSet) prodObj[0];
    auto X = prodObj[1];

    assert(homSet && X.isEqual(homSet.source()),
        "" ~ format!"Invalid input morphism `%s`, expected form of the morphism is A→((X→Y)✕X)"(
          morph.fsymbol));

    return compose(evaluate(homSet), morph);

    // alternative implementation - short but it delays an error reporting!
    // auto homSet = morph.target().projection(0).target();
    // return compose(evaluate(homSet), morph);
  }
  else {
    return evaluate(morph.projection(0), morph.projection(1));
  }
}

immutable(Morphism) evaluate(immutable Morphism morph, immutable Morphism elem) {
  assert(elem.isElementOf(morph.source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem.fsymbol,
        morph.source().fsymbol));

  if (morph.target().isEqual(ZeroSet)) {
    return Zero;
  }

  return new immutable Evaluated(morph, elem);
}

immutable(Morphism) evaluate(immutable CObject homSet) {
  return new immutable Evaluate(homSet);
}

immutable(Morphism) elementMap(immutable Morphism morph) {
  return new immutable ElementMap(morph);
}

//  ___          _           _          _
// | __|_ ____ _| |_  _ __ _| |_ ___ __| |
// | _|\ V / _` | | || / _` |  _/ -_) _` |
// |___|\_/\__,_|_|\_,_\__,_|\__\___\__,_|

immutable class Evaluated : SymbolicMorphism {

  Morphism morph;
  Morphism elem;
  CObject resultSet;

  this(immutable Morphism _morph, immutable Morphism _elem) {

    morph = _morph;
    elem = _elem;

    assert(morph.isMorphism(),
        "" ~ format!"The first input: `%s` is not a morphism!"(morph.fsymbol));

    assert(elem.isElementOf(morph.source()),
        "" ~ format!"The element `%s` is not an element of the source of the morphism `%s`"(elem.fsymbol,
          morph.fsymbol));

    // The result is a morphism
    if (morph.target().isHomSet()) {
      auto homSet = cast(immutable HomSet) morph.target();

      auto cat = homSet.morphismCategory();

      string sym = morph.symbol() ~ "(" ~ elem.symbol() ~ ")";
      string tex = morph.latex() ~ " \\left( " ~ elem.latex() ~ " \\right)";

      resultSet = homSet;

      super(cat, homSet.source(), homSet.target(), sym, tex);
    }
    else // the result is a pure element
    {
      auto cat = meet(Pol, morph.target().category());

      string sym = morph.symbol() ~ "(" ~ elem.symbol() ~ ")";
      string tex = morph.latex() ~ " \\left( " ~ elem.latex() ~ " \\right)";
      
      // // special cases
      // if(auto )
      // 	auto elMap = cast(immutable 
      // 	string sym = morph.symbol()


      resultSet = morph.target();

      super(cat, ZeroSet, morph.target(), sym, tex);
    }

  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable {
    assert(x.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(x.fsymbol, source().fsymbol));

    if (this.isElement()) {
      return this;
    }
    else {
      return evaluate(this, x);
    }
  }

  override immutable(CObject) set() immutable {
    return resultSet;
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || morph.contains(x) || elem.contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else {
      bool inMorph = morph.contains(x);
      bool inElem = elem.contains(x);

      if (!inElem && !inMorph) {
        return constantMap(x.set(), this);
      }

      if (inElem && !inMorph) {
        auto ee = elem.extract(x);
        return compose(morph, ee);
      }

      if (!inElem && inMorph) {
        auto me = morph.extract(x);
        return product(me, constantMap(x.set(), elem)).evaluate;
      }

      if (inElem && inMorph) {
        auto me = morph.extract(x);
        auto ee = elem.extract(x);
        return product(me, ee).evaluate();
      }

      assert(false, "This is should be unreachable!");
    }
  }

  override ulong toHash() immutable {
    return computeHash(morph, elem, resultSet, "Evaluated");
  }
}

//  ___          _           _
// | __|_ ____ _| |_  _ __ _| |_ ___
// | _|\ V / _` | | || / _` |  _/ -_)
// |___|\_/\__,_|_|\_,_\__,_|\__\___|

immutable class Evaluate : SymbolicMorphism {

  HomSet homSet;

  this(immutable CObject _homSet) {
    assert(_homSet.isHomSet(), "Input object has to be a HomSet!");

    homSet = cast(immutable HomSet) _homSet;

    auto cat = meet(Pol, meet(homSet.category(), homSet.morphismCategory()));

    super(cat, productObject(homSet, homSet.source()), homSet.target(), "Eval", "\\text{Eval}");
  }

  override immutable(Morphism) opCall(immutable Morphism morph_and_x) immutable {
    assert(morph_and_x.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(morph_and_x.fsymbol,
          source().fsymbol));

    auto morph = morph_and_x.projection(0);
    auto x = morph_and_x.projection(1);

    return evaluate(morph, x);
  }

}

//  ___          _
// | __|_ ____ _| |
// | _|\ V / _` | |
// |___|\_/\__,_|_|

// immutable class Eval : SymbolicMorphism{

//   HomSet homSet;

//   this(immutable CObject _homSet){

//     assert(_homSet.isHomSet(), ""~format!"Invalid input! `%s` is not a HomSet"(_homSet.fsymbol()));
//     homSet = cast(immutable HomSet)(_homSet);

//     //super(
//   }

// }

//  ___ _                   _   __  __
// | __| |___ _ __  ___ _ _| |_|  \/  |__ _ _ __
// | _|| / -_) '  \/ -_) ' \  _| |\/| / _` | '_ \
// |___|_\___|_|_|_\___|_||_\__|_|  |_\__,_| .__/
//                                         |_|

immutable class ElementMap : SymbolicMorphism {

  Morphism elem;

  this(immutable Morphism _elem) {

    elem = _elem;

    //assert(elem.isElement, "" ~ format!"The input `%s` is not an element!"(elem.fsymbol));

    auto cat = meet(Pol, elem.set().category());

    auto sym = "Elem(" ~ elem.symbol() ~ ")";
    auto tex = "\\text{Elem}_{" ~ elem.latex() ~ "}";

    super(cat, ZeroSet, elem.set(), sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable {
    assert(x.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(x.fsymbol, source().fsymbol));
    return elem;
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || elem.contains(x);
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

  override ulong toHash() immutable {
    return computeHash(elem, "ElementMap");
  }
}
