import category;

immutable(Eval) eval(immutable IHomSet homSet) {
  return new immutable Eval(homSet);
}

immutable(IElement) evaluate(immutable IMorphism morph, immutable IElement elem) {
  return eval(morph.set())(cList(morph, elem));
}

immutable class Eval : Morphism {

  this(immutable IHomSet homSet) {
    super(meet([Pol, homSet.morphismCategory()]), Set.productObject([
          homSet, homSet.source()
        ]), homSet.target(), "Eval", "\\text{Eval}");
  }

  override immutable(IElement) opCall(immutable IElement elem) immutable {
    import std.format;

    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    auto e = cast(immutable IOpElement)(elem);
    auto f = cast(immutable IMorphism)(e[0]);
    auto x = e[1];

    if (f.target().isHomSet()) {
      return new immutable MorphEvaluated(f, x);
    }
    else {
      return new immutable ElemEvaluated(f, x);
    }
  }

}

immutable class ElemEvaluated : Element {

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

  override immutable(IObject) set() immutable {
    return morph.target();
  }

  override bool containsSymbol(immutable IExpression s) immutable {
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

immutable class MorphEvaluated : Morphism {

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

  override immutable(IHomSet) set() immutable {
    return cast(immutable IHomSet) morph.target();
  }

  override bool containsSymbol(immutable IExpression s) immutable {
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