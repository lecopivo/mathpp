import category;

immutable(Eval) eval(immutable IHomSet homSet) {
  return new immutable Eval(homSet);
}

immutable(IElement) evaluate(immutable IMorphism morph, immutable IElement elem) {
  return eval(morph.set())(cList(morph, elem));
}

immutable class Eval : Morphism {

  this(immutable IHomSet homSet) {
    super(meet([Pol, homSet.morphismCategory()]), productObject(homSet,
        homSet.source()), homSet.target(), "Eval", "\\text{Eval}");
  }

  override immutable(IElement) opCall(immutable IElement elem) immutable {
    import std.format;

    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    auto src = cast(immutable IProductObject)(source);
    auto f = cast(immutable IMorphism)(src.projection(0)(elem));
    auto x = src.projection(1)(elem);

    // special case for terminal objects
    if (f.target().isTerminalObjectIn(f.category())) {
      if (auto homSet = cast(immutable IHomSet)(f.target())) {
        return new immutable Morphism(Vec, homSet.source(), homSet.target(), "0");
      }
      else {
        return emptySet;
      }
    }

    // special case for initial objects
    if (f.source().isInitialObjectIn(f.category())) {
      if (auto homSet = cast(immutable IHomSet)(f.target())) {
        return zeroMorphism(homSet.source(), homSet.target());
      }
      else {
        return new immutable Element(f.target(), "0");
      }
    }

    if (auto homSet = cast(immutable IHomSet)(f.target())) {
      return new immutable MorphEvaluated(f, x);
    }
    else {
      return new immutable ElemEvaluated(f, x);
    }
  }
}

interface IEvaluated {

  immutable(IMorphism) morphism() immutable;
  immutable(IElement) element() immutable;

}

immutable class ElemEvaluated : Element, IEvaluated {

  IMorphism morph;
  IElement elem;

  this(immutable IMorphism _morph, immutable IElement _elem) {
    import std.format;

    morph = _morph;
    elem = _elem;

    string symbol = format!"%s(%s)"(morph, elem);
    string latex = format!"%s \\left( %s \\right)"(morph.latex(), elem.latex());

    super(morph.target(), symbol, latex);
  }


  immutable(IMorphism) morphism() immutable {
    return morph;
  }

  immutable(IElement) element() immutable {
    return elem;
  }

  override immutable(IObject) set() immutable {
    return morph.target();
  }

  override bool containsSymbol(immutable IElement s) immutable {
    return this.isEqual(s) || morph.containsSymbol(s) || elem.containsSymbol(s);
  }

  override immutable(IMorphism) extractElement(immutable IElement x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if (!containsSymbol(x)) {
      return constantMap(x.set(), this);
    }
    else if (!morph.containsSymbol(x)) {
      return compose(morph, elem.extractElement(x)).removeIdentities();
    }
    else {
      auto prod = product(morph.extractElement(x), elem.extractElement(x));
      return compose(eval(morph.set()), prod).removeIdentities();
    }
  }

  override ulong toHash() immutable {
    import hash;

    return computeHash(morph, elem, "ElemEvaluated");
  }

}

immutable class MorphEvaluated : Morphism, IEvaluated {

  IMorphism morph;
  IElement elem;

  this(immutable IMorphism _morph, immutable IElement _elem) {
    import std.format;

    morph = _morph;
    elem = _elem;

    assert(morph.target().isHomSet(),
        "" ~ format!"The target of morphism `%s` has to be a HomSet!"(morph));

    string symbol = format!"%s(%s)"(morph, elem);
    string latex = format!"%s \\left( %s \\right)"(morph.latex(), elem.latex());

    auto homSet = cast(immutable IHomSet)(morph.target());
    super(homSet.morphismCategory(), homSet.source(), homSet.target(), symbol, latex);
  }

  immutable(IMorphism) morphism() immutable {
    return morph;
  }

  immutable(IElement) element() immutable {
    return elem;
  }

  override immutable(IHomSet) set() immutable {
    return cast(immutable IHomSet) morph.target();
  }

  override bool containsSymbol(immutable IElement s) immutable {
    return this.isEqual(s) || morph.containsSymbol(s) || elem.containsSymbol(s);
  }

  override immutable(IMorphism) extractElement(immutable IElement x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if (!containsSymbol(x)) {
      return constantMap(x.set(), this);
    }
    else if (!morph.containsSymbol(x)) {
      return compose(morph, elem.extractElement(x)).removeIdentities();
    }
    else {
      auto prod = product(morph.extractElement(x), elem.extractElement(x));
      return compose(eval(morph.set()), prod).removeIdentities();
    }
  }

  override ulong toHash() immutable {
    import hash;

    return computeHash(morph, elem, "MorphEvaluated");
  }
}
