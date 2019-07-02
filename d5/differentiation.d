import nonsense;

immutable(Category) changeOrder(immutable Category cat, int d) {

  if (cast(immutable VecCategory)(cat)) {
    return Vec;
  }
  else if (cast(immutable PolCategory)(cat)) {
    return Pol;
  }
  else if (cast(immutable DiffCategory)(cat)) {
    auto diff = cast(immutable DiffCategory)(cat);
    return Diff(diff.order() + d);
  }
  else if (cast(immutable SetCategory)(cat)) {
    return Set;
  }
  else {
    assert(false, format!"Encountered unknown category: %s"(cat));
  }
}

bool isDifferentiable(immutable Morphism morph){
  return morph.category().meet(Diff(1)).isEqual(Diff(1));  
}

interface IHasGradient {
  immutable(Morphism) grad() immutable;
}

immutable(Morphism) grad(immutable CObject homSet){
  return new immutable Gradient(homSet);
}

immutable(Morphism) grad(immutable Morphism morph){
  return grad(morph.set())(morph);
}

immutable(Morphism) tangentMap(immutable Morphism morph){
  auto XX = productObject(morph.source(), morph.source());
  auto grd = morph.grad();
  
  return product( compose(morph,XX.projection(0)), uncurry(morph.grad()));
}

immutable(Morphism) tangentMapToGrad(immutable Morphism morph){
  
  return morph.projection(1).curry;
}

immutable class Gradient : SymbolicMorphism {

  HomSet homSet;

  this(immutable CObject _homSet) {

    homSet = cast(immutable HomSet) _homSet;

    assert(homSet, "" ~ format!"Invalid argument `%s`!"(_homSet.fsymbol));

    assert(homSet.morphismCategory().meet(Diff(1)).isEqual(Diff(1)),
        "" ~ format!"Functions in the inputh HomSet: `%s` are not differentiable!"(_homSet.fsymbol));

    auto resultCat = homSet.morphismCategory.changeOrder(-1).meet(Pol);

    auto cat = Vec;
    auto src = homSet;
    auto trg = resultCat.homSet(homSet.source(), Vec.homSet(homSet.source(), homSet.target()));

    string sym = "∇";
    string tex = "\\nabla";

    super(cat, src, trg, sym, tex);
  }

  override immutable(Morphism) opCall(immutable Morphism morph) immutable
  in(morph.isElementOf(source()),
      "" ~ format!"Input `%s` in not an element of the source `%s`!"(morph.fsymbol,
        source().fsymbol))
  out(r; r.isElementOf(target()),
      "" ~ format!"Output `%s` is not an element of the target `%s`!"(r.fsymbol, target().fsymbol))do {

    if (morph.category().isEqual(Vec)) {
      return constantMap(morph.source(), morph);
    }
    
    if(auto hasGrad = cast(immutable IHasGradient)morph){
      return hasGrad.grad();
    }

    return lazyEvaluate(this, morph);
  }
}
