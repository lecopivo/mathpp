public import base;
public import checks;

public import interfaces;
public import catobject;
public import morphism;
public import specialmorphisms;
public import specialobjects;

public import eval;
public import element;
public import homset;
public import composedmorphism;
public import cartesianproduct;

public import basicsimplify;

public import catio;

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
  else if (cast(immutable PolCategory)(cat1) && cast(immutable PolCategory)(cat2)) {

    return Pol;

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
immutable auto Pol = new immutable PolCategory;
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
    return "\\xrightarrow{" ~ over ~ "} ";
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

  immutable(IInitialObject) initialObject() immutable {
    return emptySet;
  }

  immutable(ITerminalObject) terminalObject() immutable {
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
    return new immutable CartesianProductObject(obj);
  }

  immutable(ISumObject) sumObject(immutable IObject[] obj) immutable {
    assert(false, "Sum in is not implemented!");
    //return new immutable DisjointUnionObject(this, obj);
    return null;
  }

  immutable(IProductMorphism) product(immutable IMorphism[] morph) immutable {
    assert(morph.allIn(this), "" ~ format!"Morphisms are not in `%s`!"(this.symbol()));
    return new immutable CartesianProductMorphism(morph);
  }

  immutable(IOpMorphism) sum(immutable IMorphism[] morph) immutable {
    assert(false, "Sum in Set is not implemented!");
    //return new immutable DisjointUnionMorphism(this, morph);
    return null;
  }

  string symbol() immutable {
    return "Set";
  }

  string latex() immutable {
    return "\\mathbf{Set}";
  }

  ulong toHash() immutable {
    import hash;

    return computeHash("Set", "Category");
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
    return format!"\\xmapsto[%s]{%s}"(o, over);
  }

  float order() immutable {
    return ord;
  }

  override string symbol() immutable {
    if (ord == float.infinity) {
      return "Diff[∞]";
    }
    else {
      return format!"Diff[%d]"(cast(int) ord);
    }
  }

  override string latex() immutable {
    import std.conv;

    string o = ord == float.infinity ? "\\infty" : to!string(cast(int)(ord));
    return format!"\\mathbf{Diff}_{%s}"(o);
  }

  override ulong toHash() immutable {
    import hash;

    return computeHash(ord, "Diff", "Category");
  }

}

//  ___     _
// | _ \___| |
// |  _/ _ \ |
// |_| \___/_|

immutable class PolCategory : DiffCategory {

  this() {
    super(float.infinity);
  }

  override string arrow() immutable {
    return "↪";
  }

  override string latexArrow(string over = "") immutable {
    import std.conv;

    return format!"\\xhookrightarrow[]{%s}"(over);
  }

  override string symbol() immutable {
    return "Pol";
  }

  override string latex() immutable {
    return "\\mathbf{Pol}";
  }

  override ulong toHash() immutable {
    import hash;

    return computeHash("Pol", "Category");
  }
}

// __   __
// \ \ / /__ __
//  \ V / -_) _|
//   \_/\___\__|

immutable class VecCategory : DiffCategory {

  this() {
    super(float.infinity);
  }

  override string arrow() immutable {
    return "⇀";
  }

  override string latexArrow(string over = "") immutable {
    import std.conv;

    return format!"\\xrightharpoonup[]{%s}"(over);
  }

  override immutable(IInitialObject) initialObject() immutable {
    return zeroSet;
  }

  override immutable(ITerminalObject) terminalObject() immutable {
    return zeroSet;
  }

  override string symbol() immutable {
    return "Vec";
  }

  override string latex() immutable {
    return "\\mathbf{Vec}";
  }

  override ulong toHash() immutable {
    import hash;

    return computeHash("Vec", "Category");
  }

}
