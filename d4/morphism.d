import category;

import std.format;
import std.conv;
import std.array;

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

  immutable(IElement) opCall(immutable IElement elem) immutable{
    assert(source().isElement(elem),
	   "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    auto eval = new immutable Eval(set());
    return eval(cList([this, elem]));
  }

  immutable(IHomSet) set() immutable{
    return category().homSet(source(),target());
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

    return computeHash(cat, src, trg, sym, tex, "Morphism");
  }
}


abstract class OpMorphism(string opName) : IOpMorphism{

  IMorphism[] morph;

  this(immutable IMorphism[] _morph){
    morph = _morph;
  }

  // immutable(IElement) opCall(immutable IElement elem) immutable

  // immutable(IObject) source() immutable

  // immutable(IObject) target() immutable 

  // immutable(ICategory) category() immutable

  string opName() immutable{
    return opName;
  }

  // implement
  //string operation() immutable;

  // implement
  //string latexOperation() immutable;

  int size() immutable{
    return morph.length;
  }
  
  immutable(IMorphism)[] args() immutable{
    return morph;
  }
  
  immutable(IMorphism) opIndex(int I) immutable{
    return morph[I];
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s) || any!(m => m.containsSymbol(s))(morph);
  }
  
  string symbol() immutable {
    return "(" ~ map!(m => m.symbol())(morph).joiner(operation()).to!string ~ ")";
  }

  string latex() immutable {
    return "\\left( " ~ map!(m => m.latex())(morph)
      .joiner(" " ~ latexOperation() ~ " ").to!string ~ " \\right)";
  }

  ulong toHash() immutable {
    import hash;
    return computeHash(morph, opName(), "OpMorphism");
  }
}
