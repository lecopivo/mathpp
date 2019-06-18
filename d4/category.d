import interfaces;
import catobject;
import morphism;
import base;
import checks;

import std.variant;
import std.format;
import std.algorithm;

//   ___      _                           __  __         _
//  / __|__ _| |_ ___ __ _ ___ _ _ _  _  |  \/  |___ ___| |_
// | (__/ _` |  _/ -_) _` / _ \ '_| || | | |\/| / -_) -_)  _|
//  \___\__,_|\__\___\__, \___/_|  \_, | |_|  |_\___\___|\__|
//                   |___/         |__/

immutable(ICategory) meet(immutable ICategory cat1, immutable ICategory cat2) {

  if (cast(immutable VecCategory)(cat1) && cast(immutable VecCategory)(cat2)) {

    return Vec;

  }
  else if (cast(immutable DiffCategory)(cat1) && cast(immutable DiffCategory)(cat2)) {

    auto d1 = cast(immutable DiffCategory)(cat1);
    auto d2 = cast(immutable DiffCategory)(cat2);

    return Diff(min(d1.order(), d2.order()));

  }
  else {

    assert(cast(immutable SetCategory)(cat1), format!"Encountered unknown category: %s"(cat1));
    assert(cast(immutable SetCategory)(cat2), format!"Encountered unknown category: %s"(cat2));

    return Set;
  }
}

immutable(ICategory) meet(immutable ICategory[] cat) {
  if (cat.length == 1)
    return cat[0];
  else
    return meet(cat[0], meet(cat[1 .. $]));
}

//////////////////////////////////////////////////////////////////
// Instantiated categories

immutable auto Set = new immutable SetCategory;
immutable auto Smooth = Diff(float.infinity);
immutable auto Vec = new immutable VecCategory;

immutable(DiffCategory) Diff(float order) {
  return new immutable DiffCategory(order);
}

//  ___      _
// / __| ___| |_
// \__ \/ -_)  _|
// |___/\___|\__|

immutable class SetCategory : ICategory {

  string arrow() immutable {
    return "→";
  }

  string latexArrow(string over = "") immutable {
    return "\\xrightarrow_{" ~ over ~ "} ";
  }

  bool hasHomSet() immutable {
    return true;
  }

  bool hasInitialObject() immutable {
    return true;
  }

  bool hasTerminalObject() immutable {
    return true;
  }

  bool hasTensorProduct() immutable {
    return true;
  }

  bool hasProduct() immutable {
    return true;
  }

  bool hasSum() immutable {
    return false;
  }

  immutable(IObject) initalObject() immutable {
    return emptySet;
  }

  immutable(IObject) terminalObject() immutable {
    return zeroSet;
  }

  immutable(IMorphism) initialMorphism(immutable IObject obj) immutable {
    assert(obj.isIn(this), format!"Object is not in `%s`!"(this));
    return new immutable Morphism(meet(obj.category(), Smooth),
        initialObject(), obj, "{}", "\\{\\}");
  }

  immutable(IMorphism) terminalMorphism(immutable IObject obj) immutable {
    assert(obj.isIn(this), format!"Object is not in `%s`!"(this));
    return new immutable Morphism(meet(obj.category(), Vec), obj, terminalObject(), "0", "0");
  }

  immutable(IProductObject) productObject(immutable IObject[] obj) immutable {
    assert(obj.allIn(this), format!"Objects are not in `%s`!"(this));
    return new immutable CartesianProductObject(this, obj);
  }

  immutable(ISumObject) sumObject(immutable IObject[] obj) immutable {
    assert(false, "Sum in is not implemented!");
    //return new immutable DisjointUnionObject(this, obj);
    return null;
  }

  immutable(IProductMorphism) product(immutable IMorphism[] morph) immutable {
    assert(morph.allIn(this), format!"Morphisms are not in `%s`!"(this));
    return new immutable CartesianProductMorphism(this, obj);
  }

  immutable(ISumMorphism) sum(immutable IMorphism[] morph) immutable {
    assert(false, "Sum in Set is not implemented!");
    //return new immutable DisjointUnionMorphism(this, morph);
    return null;
  }
}

//  ___  _  __  __
// |   \(_)/ _|/ _|
// | |) | |  _|  _|
// |___/|_|_| |_|

immutable class DiffCategory : SetCategory {

  float ord;

  this(float _ord) {
    ord = _ord;
  }

  override string arrow() immutable {
    return "↦";
  }

  override string latexArrow(string over = "") immutable {
    import std.conv;

    string o = ord == float.infinity ? "\\infty" : to!string(cast(int)(ord));
    return format!"\\xmapsto[%s]_{%s}"(ord, over);
  }

  float order() immutable {
    return ord;
  }

}

// __   __
// \ \ / /__ __
//  \ V / -_) _|
//   \_/\___\__|

immutable class VecCategory : DiffCategory {

  this() {
    super(ulong.max);
  }

  override string arrow() immutable {
    return "⇀";
  }

  override string latexArrow(string over = "") immutable {
    import std.conv;

    return format!"\\xrightharpoonup{%s}"(over);
  }

  override immutable(IObject) initalObject() immutable {
    return zeroSet;
  }

  override immutable(IObject) terminalObject() immutable {
    return zeroSet;
  }
}
