import category;

import std.format;

immutable(IMorphism) inverse(immutable IMorphism morph){
  auto inv = new immutable Inverse(morph.set());
  return inv(morph).toMorph();
}

immutable(IMorphism) inversion(immutable IObject obj){
  return new immutable Inverse(obj);
}

immutable class Inverse : Involution, IHasGradient{

  this(immutable IObject _obj) {
    assert(_obj.isHomSet(),"Input has to be a homset");

    auto _homSet = cast(immutable IHomSet)(_obj);

    auto cat = meet([Smooth,_homSet.morphismCategory()]);
    auto src = _homSet;
    auto trg = _homSet.morphismCategory().homSet(_homSet.target(), _homSet.source());
    
    super(cat, src, trg, "inv", "\\text{inv}");
  }

  override immutable(IElement) opCall(immutable IElement elem) immutable {
    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    return super.opCall(elem);
  }


  immutable(IMorphism) gradient() immutable{

    auto homSet = cast(immutable IHomSet)source();
    auto cat = homSet.morphismCategory();
    auto src = homSet.source();
    auto trg = homSet.target();

    auto y = new immutable Element(trg, "y");
    
    auto f = new immutable Morphism(cat, src, trg, "f");
    auto g = new immutable Morphism(cat, src, trg, "g", "g");

    auto inv_f = inverse(f);
    auto gradf = f.grad()(inv_f(y)).toMorph();
    auto inv_gradf = inverse(gradf).toMorph();

    return inv_gradf( g( inv_f(y))).extractElement(y).extractElement(g).extractElement(f);
  }
}


