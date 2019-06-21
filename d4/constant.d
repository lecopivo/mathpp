import category;

immutable(IMorphism) constantMap(immutable IObject src, immutable IElement elem) {
  return compose(elementMap(elem), zeroSet.terminalMorphism(src));
}

immutable(IMorphism) makeElementMap(immutable IObject obj) {
  return new immutable MakeElementMap(obj);
}

immutable(IMorphism) elementMap(immutable IElement elem) {
  return new immutable ElementMap(elem);
}

//  __  __      _         ___ _                   _     __  __
// |  \/  |__ _| |_____  | __| |___ _ __  ___ _ _| |_  |  \/  |__ _ _ __
// | |\/| / _` | / / -_) | _|| / -_) '  \/ -_) ' \  _| | |\/| / _` | '_ \
// |_|  |_\__,_|_\_\___| |___|_\___|_|_|_\___|_||_\__| |_|  |_\__,_| .__/
//                                                                 |_|


immutable class MakeElementMap : IMorphism {

  IObject obj;

  this(immutable IObject _obj) {
    obj = _obj;
  }

  immutable(IElement) opCall(immutable IElement elem) immutable {
    import std.format;

    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    return new immutable ElementMap(elem);
  }

  immutable(IHomSet) set() immutable {
    return category().homSet(source(), target());
  }

  immutable(IObject) source() immutable {
    return obj;
  }

  immutable(IObject) target() immutable {
    return category().homSet(zeroSet, obj);
  }

  immutable(ICategory) category() immutable {
    return meet([Pol, obj.category()]);
  }

  string symbol() immutable {
    return "Elem";
  }

  string latex() immutable {
    return "\\text{Elem}";
  }

  bool containsSymbol(immutable IElement s) immutable {
    return this.isEqual(s);
  }

  immutable(IMorphism) extractElement(immutable IElement x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else {
      return constantMap(x.set(), this);
    }
  }

  ulong toHash() immutable {
    import hash;

    return computeHash(obj, "MakeElementMap");
  }
}

//  ___ _                   _     __  __
// | __| |___ _ __  ___ _ _| |_  |  \/  |__ _ _ __
// | _|| / -_) '  \/ -_) ' \  _| | |\/| / _` | '_ \
// |___|_\___|_|_|_\___|_||_\__| |_|  |_\__,_| .__/
//                                           |_|

immutable class ElementMap : IMorphism {

  IElement elem;

  this(immutable IElement _elem) {
    elem = _elem;
  }

  immutable(IElement) opCall(immutable IElement x) immutable {
    import std.format;

    assert(source().isElement(x),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(x, source()));

    return elem;
  }

  immutable(IHomSet) set() immutable {
    return category().homSet(source(), target());
  }

  immutable(IObject) source() immutable {
    return zeroSet;
  }

  immutable(IObject) target() immutable {
    return elem.set();
  }

  immutable(ICategory) category() immutable {
    return meet([Pol, target().category()]);
  }

  string symbol() immutable {
    return "Elem(" ~ elem.symbol() ~ ")";
  }

  string latex() immutable {
    return "\\text{Elem}_{" ~ elem.latex() ~ "}";
  }

  bool containsSymbol(immutable IElement s) immutable {
    return this.isEqual(s) || elem.containsSymbol(s);
  }

  immutable(IMorphism) extractElement(immutable IElement x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if (!elem.containsSymbol(x)) {
      return constantMap(x.set(), this);
    }
    else {
      return compose(makeElementMap(elem.set()), elem.extractElement(x)).removeIdentities();

    }
  }

  ulong toHash() immutable {
    import hash;

    return computeHash(elem, "ElementMap");
  }
}
