import category;

import checks;
import hash;

import std.format;

immutable class CatObject : IObject {

  ICategory cat;

  string sym;
  string tex;

  this(immutable ICategory _category, string _symbol, string _latex = "") {    
    cat = _category;

    sym = _symbol;
    tex = _latex == "" ? _symbol : _latex;
  }

  bool isElement(immutable IElement elem) immutable{
    return elem.set().isSubsetOf(this);
  }

  bool isSubsetOf(immutable IObject set) immutable{
    return set.isEqual(this);
  }

  immutable(ICategory) category() immutable {
    return cat;
  }

  string symbol() immutable {
    return sym;
  }

  string latex() immutable {
    return tex;
  }

  ulong toHash() immutable {
    return computeHash(cat, sym, tex, "DifferentiableMap");
  }
}

