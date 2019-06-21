import category;

import std.format;

immutable class Identity : Morphism {

  this(immutable IObject obj) {

    immutable ICategory cat = obj.isIn(Vec) ? Vec : Set;

    super(cat, obj, obj, "id", format!"\\text{id}_{%s}"(obj.latex()));
  }

  override immutable(IElement) opCall(immutable IElement elem) immutable {
    return elem;
  }
}

immutable class Projection : Morphism {

  ulong id;

  this(immutable IObject obj, ulong I) {

    auto o = cast(immutable IProductObject)(obj);
    assert(o, format!"Trying to create projection from a non-product object `%s`!"(obj));
    assert(I < o.size(),
        format!"Index out of range when creating projection-`%d` from `%s`!"(I, obj));

    immutable ICategory cat = o.isIn(Vec) ? Vec : Set;

    id = I;

    super(cat, o, o[I], format!"π%d"(I), format!"\\pi_{%d}"(I));
  }

  override immutable(IElement) opCall(immutable IElement elem) immutable {
    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    auto e = cast(immutable IOpElement)(elem);
    if (e) {
      return e[index()];
    }
    else {
      return evaluate(this, elem);
    }
  }

  ulong index() immutable {
    return id;
  }
}

bool isIdentity(immutable IMorphism morph) {
  if (cast(immutable Identity)(morph)) {
    return true;
  }
  else {
    return false;
  }
}

bool isProjection(immutable IMorphism morph) {
  if (cast(immutable Projection)(morph)) {
    return true;
  }
  else {
    return false;
  }
}
