import nonsense;

//   ___      _
//  / __|__ _| |_ ___ __ _ ___ _ _ _  _
// | (__/ _` |  _/ -_) _` / _ \ '_| || |
//  \___\__,_|\__\___\__, \___/_|  \_, |
//                   |___/         |__/

abstract immutable class Category : ISymbolic {

  // Checks
  final bool isObject(immutable CObject obj) immutable {
    return obj.isIn(this); //meet([this, obj.category()]).isEqual(this);
  }

  bool isMorphism(immutable Morphism morph) immutable {
    return morph.isIn(this); //meet([this, morph.category()]).isEqual(this);
  }

  bool isSubCategoryOf(immutable Category cat) immutable;

  // Other symbolic things
  string arrow() immutable;
  string latexArrow(string over = "") immutable;

  // ISymbolic - I have to add it here again for some reason :(
  string symbol() immutable;
  string latex() immutable;
  ulong toHash() immutable;

  final bool isEqual(immutable Category s) immutable {
    return toHash() == s.toHash();
  }
}

//////////////////////////////////////////////////////////////////
// Instantiated categories

immutable auto Set = new immutable SetCategory;
immutable auto Smooth = Diff(float.infinity);
immutable auto Pol = new immutable PolCategory;
immutable auto Vec = new immutable VecCategory;

/**
 * Diff does that
 * Params:
 *   order = order of differentiability
 */
immutable(DiffCategory) Diff(float order) {
  return new immutable DiffCategory(order);
}

//  ___      _
// / __| ___| |_
// \__ \/ -_)  _|
// |___/\___|\__|

immutable class SetCategory : Category {

  override bool isSubCategoryOf(immutable Category cat) immutable{
    if(cast(immutable SetCategory)(cat)){
      return true;
    }else{
      return false;
    }
  }

  override string arrow() immutable {
    return "→";
  }

  override string latexArrow(string over = "") immutable {
    return "\\xrightarrow{" ~ over ~ "} ";
  }

  override string symbol() immutable {
    return "Set";
  }

  override string latex() immutable {
    return "\\mathbf{Set}";
  }

  override ulong toHash() immutable {
    import hash;

    return computeHash("Set", "Category");
  }
}

//  ___  _  __  __
// |   \(_)/ _|/ _|
// | |) | |  _|  _|
// |___/|_|_| |_|

immutable class DiffCategory : Category {
  float ord;

  this(float _ord) {
    ord = _ord;
  }

  override bool isSubCategoryOf(immutable Category cat) immutable{
    if(auto diff = cast(immutable DiffCategory)(cat)){
      return order() >= diff.order();
    }else{
      return Set.isSubCategoryOf(cat);
    }
  }

  override string arrow() immutable {
    return "↦";
  }

  override string latexArrow(string over = "") immutable {

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

immutable class PolCategory : Category {

  override bool isSubCategoryOf(immutable Category cat) immutable{
    if(cast(immutable PolCategory)(cat)){
      return true;
    }else{
      return Smooth.isSubCategoryOf(cat);
    }
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

immutable class VecCategory : Category {

  override bool isSubCategoryOf(immutable Category cat) immutable{
    if(cast(immutable VecCategory)(cat)){
      return true;
    }else{
      return Pol.isSubCategoryOf(cat);
    }
  }

  override string arrow() immutable {
    return "⇀";
  }

  override string latexArrow(string over = "") immutable {
    import std.conv;

    return format!"\\xrightharpoonup[]{%s}"(over);
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
