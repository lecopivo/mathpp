import category;

import checks;
import hash;

import std.format;

immutable class EmptySet : CatObject, IInitialObject {
  this() {
    super(Smooth, "∅", "\\emptyset");
  }
  
  // This has to be here for some reason - DMD is stupid, LDC does not require this
  override immutable(ICategory) category() immutable{
    return Smooth;
  }

  immutable(IMorphism) initialMorphism(immutable IObject obj) immutable {
    return new immutable Morphism(meet([Smooth, obj.category()]), this, obj,
        "∅", format!"\\emptyset_{%s}"(obj.latex()));
  }
}

immutable class ZeroSet : CatObject, IInitialObject, ITerminalObject {
  this() {
    super(Smooth, "{∅}", "\\{\\emptyset\\}");
  }
  
  // This has to be here for some reason - DMD is stupid, LDC does not require this
  override immutable(ICategory) category() immutable{
    return Smooth;
  }

  immutable(IMorphism) initialMorphism(immutable IObject obj) immutable {
    assert(obj.isIn(Vec),
        "" ~ format!"Zero set is initial object only in Vec category, however the object `%s` is in category `%s`!"(obj,
          obj.category()));
    return new immutable Morphism(Vec, this, obj, "0", format!"0_{%s}"(obj.latex()));
  }

  immutable(IMorphism) terminalMorphism(immutable IObject obj) immutable {
    return new immutable Morphism(meet([Vec, obj.category()]), obj, this, "0",
        format!"0_{%s}"(obj.latex()));
  }
}

immutable class NaturalNumbers : CatObject {

  this() {
    super(Set, "ℕ", "\\mathbb{N}");
  }
}

immutable class IntegerNumbers : CatObject {

  this() {
    super(Set, "ℤ", "\\mathbb{Z}");
  }
}

immutable class RealNumbers : CatObject {

  this() {
    super(Vec, "ℝ", "\\mathbb{R}");
  }
}

immutable class ComplexNumbers : CatObject {

  this() {
    super(Vec, "ℂ", "\\mathbb{C}");
  }
}

immutable auto emptySet = new immutable EmptySet;
immutable auto zeroSet = new immutable ZeroSet;

immutable auto naturalNumbers = new immutable NaturalNumbers;
immutable auto integerNumbers = new immutable IntegerNumbers;
immutable auto realNumbers = new immutable RealNumbers;
immutable auto complexNumbers = new immutable ComplexNumbers;
