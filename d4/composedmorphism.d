import category;

import std.algorithm;
import std.array;
import std.conv;
import std.format;

immutable class ComposedMorphism : IComposedMorphism {

  IMorphism[] morph;

  this(immutable IMorphism[] _morph) {

    auto cat = meet(map!(m => m.category())(_morph).array);
    morph = _morph;

    assert(morph.length > 1,
        "Making composed morphism with less then two morphisms does not make sense!");
    assert(morph.areComposableIn(cat), format!"Morphisms are not composable in `%s`!"(cat));
  }

  immutable(IElement) opCall(immutable IElement elem) immutable{

    immutable(IElement)[] e;
    e ~= elem;
    const ulong N = morph.length;
    foreach (i; 0 .. N) {
      e ~= morph[N - i - 1](e[i]);
    }

    return e[N];
  }

  immutable(IHomSet) set() immutable{
    return category().homSet(source(),target());
  }

  string opName() immutable{
    return "Composition";
  }

  string operation() immutable {
    return "∘";
  }

  string latexOperation() immutable {
    return "\\circ";
  }

  int size() immutable {
    return cast(int) morph.length;
  }

  immutable(IMorphism)[] args() immutable {
    return morph;
  }

  immutable(IMorphism) opIndex(int I) immutable {
    return morph[I];
  }

  immutable(IObject) source() immutable {
    return morph[$ - 1].source();
  }

  immutable(IObject) target() immutable {
    return morph[0].target();
  }

  immutable(ICategory) category() immutable {
    return meet(map!(m => m.category())(morph).array);
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
    return computeHash( morph, "ComposedMorphism");
  }
}

immutable class Hom : IMorphism {

  ICategory cat;

  IHomSet homSetXY;
  IHomSet homSetYZ;
  IHomSet homSetXZ;

  IProductObject src;

  this(immutable IHomSet _homSetYZ, immutable IHomSet _homSetXY) {

    assert(_homSetXY.target().isEqual(_homSetYZ.source()),
        "" ~ format!"The target set of `%s` does not match the source set of `%s`"(_homSetXY,
          _homSetYZ));

    homSetXY = _homSetXY;
    homSetYZ = _homSetYZ;

    cat = meet([homSetXY.category(), homSetYZ.category(), Smooth]);
    auto morphCategory = meet([
        homSetXY.morphismCategory(), homSetYZ.morphismCategory()
        ]);

    homSetXZ = morphCategory.homSet(homSetXY.source(), homSetYZ.target());

    src = cat.productObject([homSetYZ, homSetXY]);
  }

  immutable(IMorphism) opCall(immutable IElement elem) immutable{
    assert(source().isElement(elem),
	   "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));
    
    auto e = cast(immutable IOpElement)(elem);
    auto f = cast(immutable IMorphism)(e[0]);
    auto g = cast(immutable IMorphism)(e[1]);

    return new immutable ComposedMorphism([f,g]);
  }

  immutable(IHomSet) set() immutable{
    return category().homSet(source(),target());
  }


  immutable(IObject) source() immutable {
    return src;
  }

  immutable(IObject) target() immutable {
    return homSetXZ;
  }

  immutable(ICategory) category() immutable {
    return cat;
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s);
  }

  string symbol() immutable {
    return "hom";
  }

  string latex() immutable {
    return "\\text{hom}";
  }

  ulong toHash() immutable {
    import hash;

    return computeHash(cat, homSetXY, homSetYZ, homSetXZ, src, "Hom");
  }
}
