import nonsense;

//  _  _           ___      _
// | || |___ _ __ / __| ___| |_
// | __ / _ \ '  \\__ \/ -_)  _|
// |_||_\___/_|_|_|___/\___|\__|

immutable(HomSet) homSet(immutable Category morphismCategory,
    immutable CObject source, immutable CObject target) {
  return new immutable HomSet(morphismCategory, source, target);
}

immutable class HomSet : CObject {

  Category cat;
  Category morphCat;

  CObject src;
  CObject trg;

  this(immutable Category _morphismCategory, immutable CObject _source, immutable CObject _target) {
    import std.format;

    assert(_source.isIn(_morphismCategory),
        "" ~ format!"The source `%s` is not in the morphism category `%s`"(_source,
          _morphismCategory));
    assert(_target.isIn(_morphismCategory),
        "" ~ format!"The target `%s` is not in the morphism category `%s`"(_target,
          _morphismCategory));

    cat = _target.isIn(Vec) ? Vec : Set;
    morphCat = _morphismCategory;
    
    // !Hack!
    

    src = _source;
    trg = _target;
  }

  override immutable(Category) category() immutable {
    if (target().isIn(Vec)) {
      return Vec;
    }
    else {
      return Set;
    }
  }

  override bool isSubsetOf(immutable CObject set) immutable {
    if (auto homSet = cast(immutable HomSet)(set)) {
      return source().isEqual(homSet.source()) && target().isEqual(homSet.target())
        && morphismCategory().isSubCategoryOf(homSet.morphismCategory());
    }else{
      return false;
    }
  }

  immutable(Category) morphismCategory() immutable {
    return morphCat;
  }

  immutable(CObject) source() immutable {
    return src;
  }

  immutable(CObject) target() immutable {
    return trg;
  }


  // Symbolic
  override string symbol() immutable{
    return "(" ~ source.symbol() ~ morphismCategory().arrow() ~ target.symbol() ~")";
  }
  override string latex() immutable{
    return "\\left( "~ source.latex() ~ morphismCategory().latexArrow() ~ target.latex() ~"\\right)";
  }

  override ulong toHash() immutable{
    return computeHash(cat,morphCat, src, trg,"ComposeWith");
  }
}
