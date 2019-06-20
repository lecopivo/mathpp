import category;

import std.algorithm;
import std.array;
import std.conv;
import std.format;

immutable class CartesianProductObject : IProductObject {

  IObject[] obj;

  this(immutable IObject[] _obj) {
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
    return meet(map!(o => o.category())(obj).array);
  }

  string symbol() immutable {
    return "(" ~ map!(o => o.symbol())(obj).joiner("✕").to!string ~ ")";
  }

  string latex() immutable {
    return "\\left( " ~ map!(o => o.latex())(obj).joiner(" \\times ").to!string ~ " \\right)";
  }

  ulong toHash() immutable {
    import hash;

    return computeHash(obj, "CartesianProductObject");
  }
}

immutable class CartesianProductMorphism : IProductMorphism {

  IMorphism[] morph;

  this(immutable IMorphism[] _morph) {

    auto cat = meet(map!(m => m.category())(_morph).array);
    morph = _morph;

    assert(morph.length > 1,
        "Making product morphism with less then two morphisms does not make sense!");
    assert(cat.hasProduct(), format!"The category `%s` does not have products!"(cat));
    assert(morph.allSameSource(), "Morphisms do not share the same source!");
  }

  immutable(IHomSet) set() immutable{
    return category().homSet(source(),target());
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
    return morph[0].source();
  }

  immutable(IProductObject) target() immutable {
    return Set.productObject(map!(m => m.target())(morph).array);
  }

  immutable(ICategory) category() immutable {
    return meet(map!(m => m.category())(morph).array);
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

    return computeHash(morph, "CartesianProductMorphism");
  }
}

immutable class CartesianProductElement : IOpElement{

  IElement[] elem;

  this(immutable IElement[] _elem){
    elem = _elem;
  }

  immutable(IProductObject) set() immutable{
    return Set.productObject(map!(e=>e.set())(elem).array);
  }

    string operation() immutable {
    return "✕";
  }

  string latexOperation() immutable {
    return "\\times";
  }

  int size() immutable {
    return cast(int) elem.length;
  }
  
  immutable(IElement)[] args() immutable{
    return elem;
  }

  immutable(IElement) opIndex(int I) immutable {
    return elem[I];
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s) || any!(e => e.containsSymbol(s))(elem);
  }

  string symbol() immutable {
    return "(" ~ map!(e => e.symbol())(elem).joiner(",").to!string ~ ")";
  }

  string latex() immutable {
    return "\\left( " ~ map!(e => e.latex())(elem).joiner(" , ").to!string ~ " \\right)";
  }

  ulong toHash() immutable {
    import hash;

    return computeHash(elem, "CartesianProductElement");
  }
}
