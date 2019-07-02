import nonsense;

immutable(Morphism) contract(immutable Morphism morph) {
  return new immutable Contracted(morph);
}

immutable(Morphism) contract(immutable CObject homSet) {
  return new immutable Contract(homSet);
}

//   ___         _               _          _
//  / __|___ _ _| |_ _ _ __ _ __| |_ ___ __| |
// | (__/ _ \ ' \  _| '_/ _` / _|  _/ -_) _` |
//  \___\___/_||_\__|_| \__,_\__|\__\___\__,_|

immutable class Contracted : SymbolicMorphism {

  Morphism morph;

  this(immutable Morphism _morph) {

    morph = _morph;

    auto homSet = cast(immutable HomSet) morph.target();

    assert(homSet && morph.source().isEqual(homSet.source()),
        "" ~ format!"Invalid input morphism `%s`, morphisms with signature X→(X→Y) are expected!"(
          morph.fsymbol));

    auto cat = meet(morph.category(), homSet.morphismCategory()).meet(Pol);
    auto src = homSet.source();
    auto trg = homSet.target();

    string sym = "Contr(" ~ morph.symbol ~ ")";
    string tex = "\\text{Contr}\\left( " ~ morph.latex ~ " \\right)";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism x) immutable
  in(x.isElementOf(source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(x.fsymbol, source().fsymbol))
  out(r; r.isElementOf(target()),
      "" ~ format!"Output `%s` is not an element of the target `%s`!"(r.fsymbol, target().fsymbol))do {
    return morph(x)(x);
  }

  override bool contains(immutable Morphism x) immutable {
    return this.isEqual(x) || morph.contains(x);
  }

  override immutable(Morphism) extract(immutable Morphism x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if (!morph.contains(x)) {
      return constantMap(x.set(), this);
    }
    else {
      return compose(contract(morph.set()), morph.extract(x));
    }
  }
}

//   ___         _               _
//  / __|___ _ _| |_ _ _ __ _ __| |_
// | (__/ _ \ ' \  _| '_/ _` / _|  _|
//  \___\___/_||_\__|_| \__,_\__|\__|

immutable class Contract : SymbolicMorphism {

  HomSet homSet;

  this(immutable CObject _homSet) {

    homSet = cast(immutable HomSet) _homSet;

    assert(homSet,
        "" ~ format!"Invalid input object `%s`, expected object of the form: X→(X→Y)!"(
          _homSet.fsymbol));

    auto sndHomSet = cast(immutable HomSet) homSet.target();

    assert(sndHomSet && sndHomSet.source().isEqual(homSet.source()),
        "" ~ format!"Invalid input object `%s`, expected object of the form: X→(X→Y)!"(
          _homSet.fsymbol));

    auto trgCat = meet(homSet.morphismCategory(), sndHomSet.morphismCategory()).meet(Pol);

    auto cat = homSet.category();
    auto src = homSet;
    auto trg = trgCat.homSet(sndHomSet.source(), sndHomSet.target());

    string sym = "Contr";
    string tex = "\\text{Contr}";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism morph) immutable
  in(morph.isElementOf(source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(morph.fsymbol,
        source().fsymbol))
  out(r; r.isElementOf(target()),
      "" ~ format!"Output `%s` is not an element of the target `%s`!"(r.fsymbol, target().fsymbol))do {
    return contract(morph);
  }
}
