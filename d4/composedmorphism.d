import category;

import std.algorithm;
import std.array;
import std.conv;
import std.format;

immutable class ComposedMorphism : OpMorphism!"Composition", IComposedMorphism {

  this(immutable IMorphism[] _morph) {

    super(_morph);

    auto cat = meet(map!(m => m.category())(morph).array);

    assert(morph.length > 1,
        "Making composed morphism with less then two morphisms does not make sense!");
    assert(morph.areComposableIn(cat), format!"Morphisms are not composable in `%s`!"(cat));
  }

  immutable(IElement) opCall(immutable IElement elem) immutable {

    immutable(IElement)[] e;
    e ~= elem;
    const ulong N = morph.length;
    foreach (i; 0 .. N) {
      e ~= morph[N - i - 1](e[i]);
    }

    return e[N];
  }

  // ----------------- //

  immutable(IObject) source() immutable {
    return morph[$ - 1].source();
  }

  immutable(IObject) target() immutable {
    return morph[0].target();
  }

  immutable(ICategory) category() immutable {
    return meet(map!(m => m.category())(morph).array);
  }

  // ----------------- //

  string operation() immutable {
    return "∘";
  }

  string latexOperation() immutable {
    return "\\circ";
  }

  // this should not be here, but dmd complains
  override bool containsSymbol(immutable(IExpression) s) immutable {
    import std.algorithm;

    return this.isEqual(s) || any!(m => m.containsSymbol(s))(morph);
  }
}

immutable class Hom : OpCaller!"Composition" {

  this(immutable IHomSet[] _homSet) {

    auto resultCategory = meet(map!(h => h.morphismCategory())(_homSet).array);
    auto src = _homSet[$-1].source();
    auto trg = _homSet[0].target();

    super(_homSet, resultCategory.homSet(src,trg));

    // check if sources and targets align
    for (int i = 0; i < homSet.length - 1; i++) {
      assert(homSet[i].source().isEqual(homSet[i + 1].target()),
          "" ~ format!"The target set of `%s` does not match the source set of `%s`"(homSet[i + 1],
            homSet[i]));
    }
  }

  immutable(IMorphism) opCall(immutable IElement elem) immutable {
    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    auto e = cast(immutable IOpElement)(elem);
    auto morphs = map!(a => cast(immutable IMorphism)(a))(e.args).array;

    return new immutable ComposedMorphism(morphs);
  }

  immutable(ICategory) category() immutable {
    return meet(Smooth ~ map!(h => h.category())(homSet).array);
  }

  string symbol() immutable {
    return "hom";
  }

  string latex() immutable {
    return "\\text{hom}";
  }
}
