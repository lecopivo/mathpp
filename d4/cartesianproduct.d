import category;

import std.algorithm;
import std.array;
import std.conv;
import std.format;

immutable class CartesianProductObject : IProductObject {

  ICategory cat;

  IObject[] obj;

  this(immutable IObject[] _obj) {
    cat = meet(map!(o => o.category())(_obj).array);
    obj = _obj;
  }

  string operation() immutable {
    return "✕";
  }

  string latexOperation() immutable {
    return "\\times";
  }

  immutable(IMorphism) projection(int I) immutable {
    return new immutable Projection(this, I);
  }

  int size() immutable {
    return cast(int) obj.length;
  }

  immutable(IObject) opIndex(int I) immutable {
    return obj[I];
  }

  immutable(ICategory) category() immutable {
    return cat;
  }

  string symbol() immutable {
    return "(" ~ map!(o => o.symbol())(obj).joiner("✕").to!string ~ ")";
  }

  string latex() immutable {
    return "\\left( " ~ map!(o => o.latex())(obj).joiner(" \\times ").to!string ~ " \\right)";
  }

  ulong toHash() immutable {
    import hash;

    return computeHash(cat, obj, "CartesianProductObject");
  }
}

immutable class CartesianProductMorphism : IProductMorphism {

  ICategory cat;

  IMorphism[] morph;

  IObject src;
  IProductObject trg;

  this(immutable IMorphism[] _morph) {

    cat = meet(map!(m => m.category())(_morph).array);
    morph = _morph;

    assert(morph.length > 1,
        "Making product morphism with less then two morphisms does not make sense!");
    assert(cat.hasProduct(), format!"The category `%s` does not have products!"(cat));
    assert(morph.allSameSource(), "Morphisms do not share the same source!");

    src = morph[0].source();
    trg = new immutable CartesianProductObject(map!(m => m.target())(morph).array);
  }

  string operation() immutable {
    return "✕";
  }

  string latexOperation() immutable {
    return "\\times";
  }

  int size() immutable {
    return cast(int) morph.length;
  }
  
  immutable(IMorphism)[] args() immutable{
    return morph;
  }

  immutable(IMorphism) opIndex(int I) immutable {
    return morph[I];
  }

  immutable(IObject) source() immutable {
    return src;
  }

  immutable(IProductObject) target() immutable {
    return trg;
  }

  immutable(ICategory) category() immutable {
    return cat;
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s) || any!(m => m.containsSymbol(s))(morph);
  }

  string symbol() immutable {
    return "(" ~ map!(m => m.symbol())(morph).joiner("✕").to!string ~ ")";
  }

  string latex() immutable {
    return "\\left( " ~ map!(m => m.latex())(morph).joiner(" \\times ").to!string ~ " \\right)";
  }

  ulong toHash() immutable {
    import hash;

    return computeHash(cat, morph, src, trg, "CartesianProductMorphism");
  }
}
