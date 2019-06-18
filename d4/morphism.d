import base;
import interfaces;
import category;
import hash;

immutable class Morphism : IMorphism {

  ICategory cat;

  IObject src;
  IObject trg;

  string sym;
  string tex;

  this(immutable ICategory _category, immutable IObject _source,
      immutable IObject _target, string _symbol, string _latex = "") {

    assert(_category.isObject(_source), format!"The source object: `%s` is not in the category: `%s`"(_category, _source));
    assert(_category.isObject(_target), format!"The target object: `%s` is not in the category: `%s`"(_category, _source));
    
    cat = _category;
    
    src = _source;
    trg = _target;

    sym = _symbol;
    tex = _latex == "" ? _symbol : _latex;
  }
  
  immutable(IObject) source() immutable{
    return src;
  }
  
  immutable(IObject) target() immutable{
    return trg;
  }
  
  immutable(ICategory) category() immutable{
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
    return computeHash(cat, src, trg, sym, tex, "DifferentiableMap");
  }
}
