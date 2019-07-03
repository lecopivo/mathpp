import nonsense;

immutable(Morphism) evalWith(immutable Morphism elem, immutable CObject homSet) {
  return new immutable EvalWith(elem, homSet);
}

immutable(Morphism) eval(immutable CObject homSet) {
  return new immutable Eval(homSet);
}

immutable(Morphism) lazyEvaluate(immutable Morphism morph, immutable Morphism elem) {
  return new immutable Evaluated(morph, elem);
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
      return lazyEvaluate(this, x);
    }
  }

  override immutable(CObject) set() immutable {
    return resultSet;
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || morph.contains(x) || elem.contains(x);
  }

  bool isOpElement() immutable {

    if (!this.isElement())
      return false;

    auto opMorph = cast(immutable IOpResult!(Morphism))(morph);

    if (!opMorph)
      return false;

    if (!cast(immutable ElementMap) opMorph[0])
      return false;

    if (!cast(immutable ElementMap) opMorph[1])
      return false;

    return true;
  }

  immutable(Morphism) opElement(ulong index) immutable {
    assert(isOpElement(), "Not a result of an operation!");

    auto opMorph = cast(immutable IOpResult!(Morphism)) morph;
    auto em = cast(immutable ElementMap) opMorph[index];

    return em.elem;
  }
  
  
  override string symbol() immutable{
    if(isOpElement){
      auto opMorph = cast(immutable IOpResult!(Morphism))(morph);
      
      string op = opMorph.operation();
      
      if(op=="✕")
	op = ",";

      return  "(" ~ opElement(0).symbol() ~ op ~ opElement(1).symbol() ~  ")";
    }
    
    if(this.isElement){
      // if(cast(immutable SymbolicMorphism)morph && morph.source().isEqual(ZeroSet))
      // 	return morph.symbol();
      // else
	return morph.symbol()~"("~elem.symbol()~")";
    }
    
    return super.symbol();
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if (isOpElement()) {

      auto opMorph = cast(immutable IOpResult!(Morphism))(morph);

      if (opMorph.opName() == "CartesianProduct") {
        return product(opElement(0).extract(x), opElement(1).extract(x));
      }

      if (opMorph.opName() == "addition") {
        return add(opElement(0).extract(x), opElement(1).extract(x));
      }

      assert(false, "" ~ format!"Unknownd operation `%s`!"(opMorph.opName()));
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
        return compose(evalWith(elem, morph.set()), me);
      }

      if (inElem && inMorph) {
        // a bit of an unreadable black magic :/, I do not know how to make it readable :(
        auto tmp = compose(eval(morph.set()), elem.extract(x));
        auto tmp2 = compose(compose(tmp.target(), morph.extract(x)), tmp);
        return contract(tmp2);
      }

      assert(false, "This is should be unreachable!");
    }
  }

  override ulong toHash() immutable {
    return computeHash(morph, elem, resultSet, "Evaluated");
  }
}

//  ___          _           _        __      ___ _   _
// | __|_ ____ _| |_  _ __ _| |_ ___  \ \    / (_) |_| |_
// | _|\ V / _` | | || / _` |  _/ -_)  \ \/\/ /| |  _| ' \
// |___|\_/\__,_|_|\_,_\__,_|\__\___|   \_/\_/ |_|\__|_||_|

immutable class EvalWith : SymbolicMorphism {

  Morphism elem;
  HomSet homSet;

  this(immutable Morphism _elem, immutable CObject _homSet) {

    homSet = cast(immutable HomSet) _homSet;
    elem = _elem;

    assert(homSet, "" ~ format!"Input object `%s` has to be a HomSet!"(_homSet.fsymbol));
    assert(elem.isElementOf(homSet.source()),
        "" ~ format!"Input element `%s` has to be an element of `%s`!"(elem.fsymbol,
          homSet.source.fsymbol));

    auto cat = homSet.category();
    auto src = homSet;
    auto trg = homSet.target();

    string sym = "EvalWith(" ~ elem.symbol ~ ")";
    string tex = "\\text{EvalWith}_{" ~ elem.latex ~ "}";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism morph) immutable
  in(morph.isElementOf(source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(morph.fsymbol,
        source().fsymbol))
  out(r; r.isElementOf(target()),
      "" ~ format!"Output `%s` is not an element of the target `%s`!"(r.fsymbol, target().fsymbol))do {

    return morph(elem);
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || elem.contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if (!contains(x)) {
      return constantMap(x.set(), this);
    }
    else {
      return compose(eval(homSet), elem.extract(x));
    }
  }
}

//  ___          _
// | __|_ ____ _| |
// | _|\ V / _` | |
// |___|\_/\__,_|_|

immutable class Eval : SymbolicMorphism {

  HomSet homSet;

  this(immutable CObject _homSet) {

    homSet = cast(immutable HomSet) _homSet;

    assert(homSet, "" ~ format!"Input object `%s` has to be a HomSet!"(_homSet.fsymbol));

    auto cat = meet(homSet.source().category(), homSet.target().category()).meet(
        homSet.morphismCategory());
    auto src = homSet.source();
    auto trg = homSet.category().homSet(homSet, homSet.target());

    string sym = "Eval";
    string tex = "\\text{Eval}";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism elem) immutable
  in(elem.isElementOf(source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem.fsymbol,
        source().fsymbol))
  out(r; r.isElementOf(target()),
      "" ~ format!"Output `%s` is not an element of the target `%s`!"(r.fsymbol, target().fsymbol))do {

    return evalWith(elem, homSet);
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
