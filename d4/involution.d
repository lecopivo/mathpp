import category;

import std.format;

immutable class Involution : Morphism{

  this(immutable ICategory _category, immutable IObject _source,
      immutable IObject _target, string _symbol, string _latex = "") {
    super(_category, _source, _target, _symbol, _latex);
  }

  override immutable(IElement) opCall(immutable IElement elem) immutable {
    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    if(auto evl = cast(immutable IEvaluated)(elem)){
      if(evl.morphism.isEqual(this))
	return evl.element;
    }

    return super.opCall(elem);
  }
}


