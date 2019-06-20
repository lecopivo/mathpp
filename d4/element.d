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

  immutable(IMorphism) extractElement(immutable IElement x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else {
      return constantMap(x.set(), this);
    }
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

abstract immutable class OpElement(string _opName) : IOpElement {

  IElement[] elem;

  this(immutable IElement[] _elem) {
    elem = _elem;
  }

  immutable(IObject) set() immutable {
    import std.algorithm;
    import std.array;

    return Set.productObject(map!(e => e.set())(elem).array);
  }

  string opName() immutable {
    return _opName;
  }

  //string operation() immutable;

  //string latexOperation() immutable;

  ulong size() immutable {
    return elem.length;
  }

  immutable(IElement)[] args() immutable {
    return elem;
  }

  immutable(IElement) opIndex(ulong I) immutable {
    return elem[I];
  }

  // ---------------------------- //

  bool containsSymbol(immutable IExpression s) immutable {
    import std.algorithm;

    return this.isEqual(s) || any!(e => e.containsSymbol(s))(elem);
  }

  string symbol() immutable {
    import std.algorithm;
    import std.conv;

    return "(" ~ map!(e => e.symbol())(elem).joiner(operation()).to!string ~ ")";
  }

  string latex() immutable {
    import std.algorithm;
    import std.conv;

    return "\\left( " ~ map!(e => e.latex())(elem).joiner(latexOperation()).to!string ~ " \\right)";
  }

  ulong toHash() immutable {
    import hash;

    return computeHash(elem, opName, symbol(), "OpElement");
  }

}
