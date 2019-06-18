import interfaces;
import category;
import morphism;

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

immutable auto emptySet = new immutable CatObject(Smooth, "∅", "\\emptyset");
immutable auto zeroSet = new immutable CatObject(Vec, "{∅}", "\\{\\emptyset \\}");
