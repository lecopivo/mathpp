import category;

import std.format;

immutable class Inverse : Involution{

  this(immutable IHomSet _homSet) {

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
}


