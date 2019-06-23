import nonsense;

immutable(Morphism) symbolicElement(immutable CObject obj, string symbol, string latex = "") {
  auto cat = obj.isIn(Vec) ? Pol : Set;
  return symbolicMorphism(cat, ZeroSet, obj, symbol, latex).evaluate();
}

immutable(Morphism) evaluate(immutable Morphism morph) {
  if (auto elementMap = cast(immutable ElementMap)(morph)) {
    return elementMap.morph;
  }
  else {
    return new immutable Evaluated(morph);
  }
}

immutable(Morphism) elementMap(immutable Morphism morph) {
  if (auto evaluated = cast(immutable Evaluated)(morph)) {
    return evaluated.morph;
  }
  else {
    return new immutable ElementMap(morph);
  }
}

immutable(Morphism) evaluate(immutable Morphism morph, immutable Morphism elem) {
  assert(elem.isElement(),
      "" ~ format!"You can evaluate function only on an elements! The input `%s` is not an element!"(
        elem.fsymbol));
  return evaluate(compose(morph, elementMap(elem)));
}

immutable(Morphism) evaluate(immutable CObject obj){
  return new immutable Evaluate(obj);
}

//  ___ _                   _   __  __
// | __| |___ _ __  ___ _ _| |_|  \/  |__ _ _ __
// | _|| / -_) '  \/ -_) ' \  _| |\/| / _` | '_ \
// |___|_\___|_|_|_\___|_||_\__|_|  |_\__,_| .__/
//                                         |_|

immutable class ElementMap : Morphism {

  Morphism morph;

  this(immutable Morphism _morph) {

    morph = _morph;

    assert(cast(immutable Evaluated)(morph),
        "Do not create an `ElementMap` from `Evaluated`! Use function `elementMap` which correctly handles `Evaluated`!");
  }

  override immutable(Category) category() immutable {
    return meet(Pol, morph.set().category());
  }

  override immutable(CObject) set() immutable {
    return category().homSet(source(), target());
  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable {
    assert(x.isElementOf(source()),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(x.fsymbol, source().fsymbol));
    return morph;
  }

  override immutable(CObject) source() immutable {
    return ZeroSet;
  }

  override immutable(CObject) target() immutable {
    return morph.set();
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || morph.contains(x);
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

  // ISymbolic - I have to add it here again for some reason :(
  override string symbol() immutable {
    return "Elem(" ~ morph.symbol() ~ ")";
  }

  override string latex() immutable {
    return "\\text{Elem}\\left( " ~ morph.latex() ~ " \\right)";
  }

  override ulong toHash() immutable {
    return computeHash(morph, "ElementMap");
  }
}

//  ___          _           _          _
// | __|_ ____ _| |_  _ __ _| |_ ___ __| |
// | _|\ V / _` | | || / _` |  _/ -_) _` |
// |___|\_/\__,_|_|\_,_\__,_|\__\___\__,_|

immutable class Evaluated : Morphism {

  Morphism morph;

  this(immutable Morphism _morph) {

    morph = _morph;

    assert(!morph.isElement(), "You cannot evaluated already evaluated morphism!");
    assert(morph.source().isEqual(ZeroSet), "Only morphisms from ZeroSet can be evaluated!");
    if (cast(immutable ElementMap)(morph)) {
      import std.stdio;

      writeln(
          "Do not create an `Evaluated` from an ElementMap! Use function `evaluate` which correctly handles ElementMaps!");
    }
  }

  override immutable(Category) category() immutable {
    return morph.category();
  }

  override immutable(CObject) set() immutable {
    return morph.target();
  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable {
    if (this.isElement()) {
      return this;
    }
    else {
      assert(false, "Implement me!");
      //return evaluate(this, x);
    }
  }

  override immutable(CObject) source() immutable {
    if (auto homSet = cast(immutable HomSet)(morph.target())) {
      return homSet.source();
    }
    else {
      return morph.source();
    }
  }

  override immutable(CObject) target() immutable {
    if (auto homSet = cast(immutable HomSet)(morph.target())) {
      return homSet.target();
    }
    else {
      return morph.target();
    }
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || morph.contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if(!morph.contains(x)){
      return constantMap(x.set(), this);
    }else{
      return  compose(evaluate(morph.target()), morph.extract(x));
    }
  }

  // ISymbolic - I have to add it here again for some reason :(
  override string symbol() immutable {
    return morph.symbol();
  }

  override string latex() immutable {
    if (auto compMorph = cast(immutable ComposedMorphism)(morph)) {
      return compMorph[0].latex() ~ "\\left( " ~ compMorph[1].symbol() ~ " \\right)";
    }
    else {
      assert(this.isElement(),
          "Somethig is fishy! The evaluated morphism should be either be an element of a composed morphism! Investigate!");
      return morph.latex();
    }
  }

  override ulong toHash() immutable {
    return computeHash(morph, "Evaluated");
  }
}


//  ___          _           _
// | __|_ ____ _| |_  _ __ _| |_ ___
// | _|\ V / _` | | || / _` |  _/ -_)
// |___|\_/\__,_|_|\_,_\__,_|\__\___|


immutable class Evaluate : SymbolicMorphism{

  this(immutable CObject obj){

    auto cat = obj.category();

    super(meet(cat,Vec), meet(cat,Pol).homSet(ZeroSet, obj), obj, "Eval", "\\text{Eval}");
  }

  override immutable(Morphism) opCall(immutable Morphism morph)immutable{
    assert(morph.isElementOf(source()),
	   "" ~ format!"Input `%s` in not an element of the source `%s`!"(morph.fsymbol, source().fsymbol));

    return evaluate(morph);
  }

}


//  ___          _
// | __|_ ____ _| |
// | _|\ V / _` | |
// |___|\_/\__,_|_|


immutable class Eval : SymbolicMorphism{

  HomSet homSet;

  this(immutable CObject _homSet){

    assert(_homSet.isHomSet(), ""~format!"Invalid input! `%s` is not a HomSet"(_homSet.fsymbol()));
    homSet = cast(immutable HomSet)(_homSet);

    //super(
  }

}
