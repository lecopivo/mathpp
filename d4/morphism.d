import category;

import std.format;
import std.conv;
import std.array;

//  __  __              _    _
// |  \/  |___ _ _ _ __| |_ (_)____ __
// | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|

immutable class Morphism : IMorphism {

  ICategory cat;

  IObject src;
  IObject trg;

  string sym;
  string tex;

  this(immutable ICategory _category, immutable IObject _source,
      immutable IObject _target, string _symbol, string _latex = "") {

    // string msg = "hovno";
    // const(char) [] er = "" ~ format!"efho %s"(msg);
    // assert(false, er);

    assert(_category.isObject(_source),
        "" ~ format!"The source object: `%s` is not in the category: `%s`"(_source, _category));
    assert(_category.isObject(_target),
        "" ~ format!"The target object: `%s` is not in the category: `%s`"(_target, _category));

    cat = _category;

    src = _source;
    trg = _target;

    sym = _symbol;
    tex = _latex == "" ? _symbol : _latex;
  }

  immutable(IElement) opCall(immutable IElement elem) immutable {
    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    return evaluate(this, elem);
  }

  immutable(IHomSet) set() immutable {
    return category().homSet(source(), target());
  }

  immutable(IObject) source() immutable {
    return src;
  }

  immutable(IObject) target() immutable {
    return trg;
  }

  immutable(ICategory) category() immutable {
    return cat;
  }

  bool containsSymbol(immutable IElement s) immutable {
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

    return computeHash(cat, src, trg, sym, tex, "Morphism");
  }

  immutable(IMorphism) extractElement(immutable IElement x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else {
      return constantMap(x.set(), this);
    }
  }

}


//   ___       __  __              _    _
//  / _ \ _ __|  \/  |___ _ _ _ __| |_ (_)____ __
// | (_) | '_ \ |\/| / _ \ '_| '_ \ ' \| (_-< '  \
//  \___/| .__/_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//       |_|                 |_|


abstract immutable class OpMorphism(string _opName) : IOpMorphism {

  IMorphism[] morph;

  this(immutable IMorphism[] _morph) {
    morph = _morph;
  }

  // immutable(IElement) opCall(immutable IElement elem) immutable

  immutable(IHomSet) set() immutable {
    return category().homSet(source(), target());
  }

  // immutable(IObject) source() immutable

  // immutable(IObject) target() immutable 

  // immutable(ICategory) category() immutable

  string opName() immutable {
    return _opName;
  }

  // implement
  //string operation() immutable;

  // implement
  //string latexOperation() immutable;

  ulong size() immutable {
    return morph.length;
  }

  immutable(IMorphism)[] args() immutable {
    return morph;
  }

  immutable(IMorphism) opIndex(ulong I) immutable {
    return morph[I];
  }

  bool containsSymbol(immutable(IElement) s) immutable {
    import std.algorithm;

    return this.isEqual(s) || any!(m => m.containsSymbol(s))(morph);
  }

  string symbol() immutable {
    import std.algorithm;

    return "(" ~ map!(m => m.symbol())(morph).joiner(operation()).to!string ~ ")";
  }

  string latex() immutable {
    import std.algorithm;

    return "\\left( " ~ map!(m => m.latex())(morph)
      .joiner(" " ~ latexOperation() ~ " ").to!string ~ " \\right)";
  }

  ulong toHash() immutable {
    import hash;

    return computeHash(morph, symbol(), opName(), "OpMorphism");
  }
}

//   ___        ___      _ _
//  / _ \ _ __ / __|__ _| | |___ _ _
// | (_) | '_ \ (__/ _` | | / -_) '_|
//  \___/| .__/\___\__,_|_|_\___|_|
//       |_|

abstract immutable class OpCaller(string opName) : IMorphism {

  IHomSet[] homSet;
  IHomSet resultHomSet;

  this(immutable IHomSet[] _homSet, immutable IHomSet _resultHomSet) {
    homSet = _homSet;
    resultHomSet = _resultHomSet;
  }

  // immutable(IElement) opCall(immutable IElement elem) immutable

  immutable(IHomSet) set() immutable {
    return category().homSet(source(), target());
  }

  immutable(IProductObject) source() immutable {
    return productObject(homSet);
  }

  immutable(IObject) target() immutable {
    return resultHomSet;
  }

  // immutable(ICategory) category() immutable

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

  //string symbol() immutable 

  // string latex() immutable

  ulong toHash() immutable {
    import hash;

    return computeHash(symbol(), opName, "OpCaller");
  }
}

