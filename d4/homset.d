import interfaces;
import category;
import base;
import hash;
import checks;

import std.algorithm;
import std.array;
import std.conv;
import std.format;

immutable class HomSet : IHomSet {

  ICategory cat;
  ICategory morphCat;

  IObject src;
  IObject trg;

  this(immutable ICategory _morphismCategory, immutable IObject _source, immutable IObject _target) {
    
    assert(_source.isIn(_morphismCategory), "" ~ format!"The source `%s` is not in the morphism category `%s`"(_source, _morphismCategory));
    assert(_target.isIn(_morphismCategory), "" ~ format!"The target `%s` is not in the morphism category `%s`"(_target, _morphismCategory));

    cat = _target.isIn(Vec) ? Vec : Set;
    morphCat = _morphismCategory;

    src = _source;
    trg = _target;
  }

  bool isElement(immutable IElement elem) {
    return this.isEqual(elem.set());
  }

  immutable(ICategory) morphismCategory() immutable {
    return morphCat;
  }

  immutable(IObject) source() immutable {
    return src;
  }

  immutable(IObject) target() immutable {
    return trg;
  }

  bool isElement(immutable IMorphism morph) immutable {
    return morph.source().isEqual(source()) && morph.target()
      .isEqual(target()) && morph.isIn(morphismCategory());
  }

  immutable(ICategory) category() immutable {
    return cat;
  }

  string symbol() immutable {
    return "(" ~ src.symbol() ~ " " ~ morphCat.arrow() ~ " " ~ trg.symbol() ~ ")";
  }

  string latex() immutable {
    return "\\left( " ~ src.latex() ~ " " ~ morphCat.latexArrow() ~ " " ~ trg.latex() ~ " \\right)";
  }

  ulong toHash() immutable {
    return computeHash(cat, morphCat, src, trg, "HomSet");
  }
}
