import nonsense;

//   ___  _     _        _
//  / _ \| |__ (_)___ __| |_
// | (_) | '_ \| / -_) _|  _|
//  \___/|_.__// \___\__|\__|
//           |__/

abstract immutable class CObject : ISymbolic {

  immutable(Category) category() immutable;

  bool isSubsetOf(immutable CObject set) immutable;

  string symbol() immutable;
  string latex() immutable;
  ulong toHash() immutable;

  final bool isEqual(immutable CObject s) immutable {
    return toHash() == s.toHash();
  }

}

//  ___            _         _ _       ___  _     _        _
// / __|_  _ _ __ | |__  ___| (_)__   / _ \| |__ (_)___ __| |_
// \__ \ || | '  \| '_ \/ _ \ | / _| | (_) | '_ \| / -_) _|  _|
// |___/\_, |_|_|_|_.__/\___/_|_\__|  \___/|_.__// \___\__|\__|
//      |__/                                   |__/

immutable(CObject) symbolicObject(immutable Category category, string symbol, string latex = "") {
  return new immutable SymbolicObject(category, symbol, latex);
}

immutable class SymbolicObject : CObject {

  Category cat;

  string sym;
  string tex;

  this(immutable Category _category, string _symbol, string _latex = "") {

    cat = _category;
    sym = _symbol;
    tex = _latex;
  }

  override immutable(Category) category() immutable {
    return cat;
  }

  override bool isSubsetOf(immutable CObject set) immutable {
    return set.isEqual(this);
  }

  override string symbol() immutable {
    return sym;
  }

  override string latex() immutable {
    return tex;
  }

  override ulong toHash() immutable {
    return computeHash(cat, sym, tex, "SymbolicObject");
  }
}
