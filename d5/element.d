import nonsense;

immutable(Morphism) symbolicElement(immutable CObject obj, string symbol, string latex = "") {
  auto cat = obj.isIn(Vec) ? Pol : Set;
  return lazyEvaluate(symbolicMorphism(cat, ZeroSet, obj, symbol, latex), Zero);
}

// element map

immutable(Morphism) elementMap(immutable Morphism morph) {
  return new immutable ElementMap(morph);
}

// make element map

immutable(Morphism) makeElementMap(immutable CObject obj) {
  return new immutable MakeElementMap(obj);
}

immutable(Morphism) makeElementMap(immutable Morphism morph) {
  return compose(makeElementMap(morph.target()), morph);
}

//  ___ _                   _   __  __
// | __| |___ _ __  ___ _ _| |_|  \/  |__ _ _ __
// | _|| / -_) '  \/ -_) ' \  _| |\/| / _` | '_ \
// |___|_\___|_|_|_\___|_||_\__|_|  |_\__,_| .__/
//                                         |_|

immutable class ElementMap : SymbolicMorphism, IHasGradient {

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
  
  immutable(Morphism) gradient() immutable{
    return initialMorphism(initialMorphism(elem.set()).set());
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || elem.contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if (!elem.contains(x)) {
      return constantMap(x.set(), this);
    }
    else {
      return elem.extract(x).makeElementMap;
    }
  }

  override ulong toHash() immutable {
    return computeHash(elem, "ElementMap");
  }
}

//  __  __      _         ___ _                   _     __  __
// |  \/  |__ _| |_____  | __| |___ _ __  ___ _ _| |_  |  \/  |__ _ _ __
// | |\/| / _` | / / -_) | _|| / -_) '  \/ -_) ' \  _| | |\/| / _` | '_ \
// |_|  |_\__,_|_\_\___| |___|_\___|_|_|_\___|_||_\__| |_|  |_\__,_| .__/
//                                                                 |_|

class MakeElementMap : SymbolicMorphism {

  CObject obj;

  this(immutable CObject _obj) {
    obj = _obj;
    
    auto resultCat = meet(Pol, obj.category());

    auto cat = obj.category();
    auto src = obj;
    auto trg = resultCat.homSet(ZeroSet, obj);

    string sym = "MakeElem";
    string tex = "\\text{MakeElem}";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable {
    assert(x.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(x.fsymbol, source().fsymbol));

    return elementMap(x);
  }

}
