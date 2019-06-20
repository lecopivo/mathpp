import interfaces;
import category;
import base;
import hash;
import checks;

import std.algorithm;
import std.array;
import std.conv;
import std.format;

immutable class ComposedMorphism : IComposedMorphism {

  ICategory cat;

  IMorphism[] morph;

  this(immutable IMorphism[] _morph) {

    cat = meet(map!(m => m.category())(_morph).array);
    morph = _morph;

    assert(morph.length > 1,
        "Making composed morphism with less then two morphisms does not make sense!");
    assert(morph.areComposableIn(cat), format!"Morphisms are not composable in `%s`!"(cat));
  }

  immutable(IHomSet) set() immutable{
    return category().homSet(source(),target());
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
    return cat;
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
    return computeHash(cat, morph, "ComposedMorphism");
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
