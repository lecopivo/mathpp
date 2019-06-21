import category;

import std.algorithm;
import std.array;
import std.conv;
import std.format;

immutable(IComposedMorphism) compose(Xs...)(Xs xs) {

  static if (Xs.length == 1) {
    return new immutable ComposedMorphism(xs);
  }
  else {

    immutable(IMorphism)[] morphs;
    static foreach (x; xs) {
      assert(cast(immutable IMorphism)(x), "Input is not of type IMorphism!");
      morphs ~= cast(immutable IMorphism)(x);
    }

    return new immutable ComposedMorphism(morphs);
  }
}

//  __  __              _    _
// |  \/  |___ _ _ _ __| |_ (_)____ __
// | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|

immutable class ComposedMorphism : OpMorphism!"Composition", IComposedMorphism {

  //  impl;

  // alias impl this;

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

  // this should not be here, but dmd complains
  override immutable(IHomSet) set() immutable {
    return category().homSet(source(), target());
  }

  immutable(IObject) source() immutable {
    return morph[$ - 1].source();
  }

  immutable(IObject) target() immutable {
    return morph[0].target();
  }

  immutable(ICategory) category() immutable {
    assert(morph.length!=0);
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

  immutable(IMorphism) extractElement(immutable IElement x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if (!containsSymbol(x)) {
      return constantMap(x.set(), this);
    }
    else {
      auto morphs = map!(e => e.extractElement(x))(morph).array;
      auto prod = product(morphs);
      auto homSets = map!(o => cast(immutable IHomSet)(o))(prod.target().args).array;
      return compose(new immutable Hom(homSets), prod);
    }
  }
}

//  _  _
// | || |___ _ __
// | __ / _ \ '  \
// |_||_\___/_|_|_|

immutable class Hom : OpCaller!"Composition" {

  this(immutable IHomSet[] _homSet) {

    auto resultCategory = meet(map!(h => h.morphismCategory())(_homSet).array);
    auto src = _homSet[$ - 1].source();
    auto trg = _homSet[0].target();

    super(_homSet, resultCategory.homSet(src, trg));

    // check if sources and targets align
    for (int i = 0; i < homSet.length - 1; i++) {
      assert(homSet[i].source().isEqual(homSet[i + 1].target()),
          "" ~ format!"The target set of `%s` does not match the source set of `%s`"(homSet[i + 1],
            homSet[i]));
    }
  }

  immutable(IMorphism) opCall(immutable IElement elem) immutable {
    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`, it is in `%s`!"(elem,
          source(), elem.set()));

    const ulong N = source().size();
    immutable(IMorphism)[] morphs;
    foreach (i; 0 .. N)
      morphs ~= cast(immutable IMorphism)(source.projection(i)(elem));

    return new immutable ComposedMorphism(morphs);
  }

  //oimmutable(IProductObject) source()

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
