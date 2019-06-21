import category;

import std.algorithm;
import std.array;
import std.conv;
import std.format;

//  ___ _                   _
// | __| |___ _ __  ___ _ _| |_
// | _|| / -_) '  \/ -_) ' \  _|
// |___|_\___|_|_|_\___|_||_\__|

immutable class CartesianProductElement : OpElement!"CartesianProduct" {

  this(immutable IElement[] _elem) {
    super(_elem);
  }

  immutable(IObject) set() immutable {
    import std.algorithm;
    import std.array;

    return productObject(map!(e => e.set())(elem).array);
  }

  string operation() immutable {
    return ",";
  }

  string latexOperation() immutable {
    return " , ";
  }

  // bool containsSymbol(immutable IExpression s) immutable {
  //   return this.isEqual(s) || any!(e => e.containsSymbol(s))(elem);
  // }

  immutable(IMorphism) extractElement(immutable IElement x) immutable {
    if (this.isEqual(x)) {
      return set().identity();
    }
    else if (!containsSymbol(x)) {
      return constantMap(x.set(), this);
    }
    else {
      auto morphs = map!(e => e.extractElement(x))(elem).array;
      return product(morphs);
    }
  }
}

//   ___              _         ___ _                   _
//  / __|_ _ ___ __ _| |_ ___  | __| |___ _ __  ___ _ _| |_
// | (__| '_/ -_) _` |  _/ -_) | _|| / -_) '  \/ -_) ' \  _|
//  \___|_| \___\__,_|\__\___| |___|_\___|_|_|_\___|_||_\__|

immutable(CartesianProductElement) cList(Xs...)(Xs xs) if (Xs.length >= 1) {

  static if (Xs.length == 1 && is(Xs[0] == immutable(IElement)[])) {
    return new immutable CartesianProductElement(xs);
  }
  else {
    //   static assert(false, "Proble");
    // }

    immutable(IElement)[] elem;
    static foreach (x; xs) {
      assert(cast(immutable IElement)(x), "Input is not of type IElement!");
      elem ~= cast(immutable IElement)(x);
    }

    return new immutable CartesianProductElement(elem);
  }
}

immutable(CartesianProductMorphism) product(Xs...)(Xs xs) if (Xs.length >= 1) {

  static if (Xs.length == 1 && is(Xs[0] == immutable(IMorphism)[])) {
    return new immutable CartesianProductMorphism(xs);
  }
  else {

    immutable(IMorphism)[] morphs;
    static foreach (x; xs) {
      assert(cast(immutable IMorphism)(x), "Input is not of type IMorphism!");
      morphs ~= cast(immutable IMorphism)(x);
    }

    return new immutable CartesianProductMorphism(morphs);
  }
}

immutable(IProductObject) productObject(Xs...)(Xs xs) if (Xs.length >= 1) {

  static if (Xs.length == 1) {
    return new immutable CartesianProductObject(xs);
  }
  else {

    immutable(IObject)[] objs;
    static foreach (x; xs) {
      assert(cast(immutable IObject)(x), "Input is not of type IObject!");
      objs ~= cast(immutable IObject)(x);
    }

    return new immutable CartesianProductObject(objs);
  }
}

//   ___  _     _        _
//  / _ \| |__ (_)___ __| |_
// | (_) | '_ \| / -_) _|  _|
//  \___/|_.__// \___\__|\__|
//           |__/

immutable class CartesianProductObject : IProductObject {

  IObject[] obj;

  this(immutable IObject[] _obj) {
    obj = _obj;
  }

  bool isElement(immutable IElement elem) immutable {
    return elem.set().isSubsetOf(this);
  }

  bool isSubsetOf(immutable IObject set) immutable {
    if (set.isEqual(this))
      return true;

    if (auto pset = cast(immutable IProductObject)(set)) {
      bool result = true;
      foreach (i, o; obj)
        result &= o.isSubsetOf(pset[i]);
      return result;
    }
    else {
      return false;
    }
  }

  string opName() immutable {
    return "CartesianProduct";
  }

  string operation() immutable {
    return "✕";
  }

  string latexOperation() immutable {
    return "\\times";
  }

  immutable(IMorphism) projection(ulong I) immutable {
    return new immutable Projection(this, I);
  }

  ulong size() immutable {
    return obj.length;
  }

  immutable(IObject)[] args() immutable {
    return obj;
  }

  immutable(IObject) opIndex(ulong I) immutable {
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

//  __  __              _    _
// |  \/  |___ _ _ _ __| |_ (_)____ __
// | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|

immutable class CartesianProductMorphism : OpMorphism!"CartesianProduct", IProductMorphism {

  this(immutable IMorphism[] _morph) {

    super(_morph);

    auto cat = category();

    assert(morph.length > 1,
        "Making product morphism with less then two morphisms does not make sense!");
    assert(cat.hasProduct(), format!"The category `%s` does not have products!"(cat));
    assert(morph.allSameSource(), "Morphisms do not share the same source!");
  }

  immutable(IElement) opCall(immutable IElement elem) immutable {
    immutable(IElement)[] results = map!(m => m(elem))(morph).array;
    //auto results = map!(m => m(elem))(morph).array;
    return cList(results);
  }

  // ----------------- //

  // this should not be here, but dmd complains
  override immutable(IHomSet) set() immutable {
    return category().homSet(source(), target());
  }

  immutable(IObject) source() immutable {
    return morph[0].source();
  }

  immutable(IProductObject) target() immutable {
    return Set.productObject(map!(m => m.target())(morph).array);
  }

  immutable(ICategory) category() immutable {
    assert(morph.length!=0);
    return meet(map!(m => m.category())(morph).array);
  }

  // ----------------- //

  string operation() immutable {
    return "✕";
  }

  string latexOperation() immutable {
    return "\\times";
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
      return compose(new immutable Prod(homSets), prod);
    }
  }
}

//  ___             _
// | _ \_ _ ___  __| |
// |  _/ '_/ _ \/ _` |
// |_| |_| \___/\__,_|

immutable class Prod : OpCaller!"CartesianProduct" {

  this(immutable IHomSet[] _homSet) {

    auto resultCategory = meet(map!(h => h.morphismCategory())(_homSet).array);
    auto src = _homSet[0].source();
    auto trg = productObject(map!(h => h.target())(_homSet).array);

    super(_homSet, resultCategory.homSet(src, trg));

    // check if sources and targets align
    for (int i = 1; i < homSet.length - 1; i++) {
      assert(homSet[0].source().isEqual(homSet[i].source()),
          "" ~ format!"The source set of `%s` does not match the source set of `%s`"(homSet[0],
            homSet[i]));
    }
  }

  immutable(IMorphism) opCall(immutable IElement elem) immutable {
    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    const ulong N = source().size();
    immutable(IMorphism)[] morphs;
    foreach (i; 0 .. N)
      morphs ~= cast(immutable IMorphism)(source.projection(i)(elem));

    return new immutable CartesianProductMorphism(morphs);
  }

  immutable(ICategory) category() immutable {
    return meet(Smooth ~ map!(h => h.category())(homSet).array);
  }

  string symbol() immutable {
    return "Prod";
  }

  string latex() immutable {
    return "\\text{Prod}";
  }
}
