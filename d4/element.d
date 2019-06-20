import category;

immutable class Element : IElement {

  IObject obj;

  string sym;
  string tex;

  this(immutable IObject _obj, string _symbol, string _latex = "") {
    obj = _obj;
    sym = _symbol;
    tex = _latex == "" ? _symbol : _latex;
  }

  immutable(IObject) set() immutable {
    return obj;
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s);
  }

  string symbol() immutable {
    return sym;
  }

  string latex() immutable {
    return tex;
  }

  ulong toHash() immutable {
    import hash;

    return computeHash(obj, sym, tex, "Element");
  }
}
