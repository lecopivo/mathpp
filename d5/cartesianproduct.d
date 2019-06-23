import nonsense;

immutable(CObject) product(immutable CObject objX, immutable CObject objY) {
  return new immutable CartesianProductObject(objX, objY);
}

immutable(Morphism) product(immutable Morphism f, immutable Morphism g) {
  return new immutable CartesianProductMorphism(f, g);
}


//  ___             _         _      ___  _     _        _
// | _ \_ _ ___  __| |_  _ __| |_   / _ \| |__ (_)___ __| |_
// |  _/ '_/ _ \/ _` | || / _|  _| | (_) | '_ \| / -_) _|  _|
// |_| |_| \___/\__,_|\_,_\__|\__|  \___/|_.__// \___\__|\__|
//                                           |__/

immutable class CartesianProductObject : SymbolicObject, IProductObject {

  CObject[2] obj;

  this(immutable CObject objX, immutable CObject objY) {
    obj = [objX, objY];

    auto cat = meet(objX.category, objY.category);

    auto sym = "(" ~ objX.symbol() ~ operation() ~ objY.symbol() ~ ")";
    auto tex = "\\left( " ~ objX.latex() ~ " " ~ latexOperation() ~ " " ~ objY.latex() ~ " \\right)";

    super(cat, sym, tex);
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

  ulong size() immutable {
    return 2;
  }

  immutable(CObject) opIndex(ulong I) immutable {
    return obj[I];
  }
}

//  ___             _         _     __  __              _    _
// | _ \_ _ ___  __| |_  _ __| |_  |  \/  |___ _ _ _ __| |_ (_)____ __
// |  _/ '_/ _ \/ _` | || / _|  _| | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_| |_| \___/\__,_|\_,_\__|\__| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                                                |_|

immutable class CartesianProductMorphism : SymbolicMorphism, IProductMorphism {

  Morphism[2] morph;

  this(immutable Morphism f, immutable Morphism g) {

    morph = [f, g];

    assert(f.source().isEqual(g.source()),
        "" ~ format!"Morphism `%s` and `%s` do not share the same source!"(f.fsymbol, g.fsymbol));

    auto cat = meet(f.category, g.category);

    auto src = f.source;
    auto trg = product(f.target, g.target);

    auto sym = "(" ~ f.symbol ~ operation() ~ g.symbol ~ ")";
    auto tex = "\\left( " ~ f.latex() ~ " " ~ latexOperation() ~ " " ~ g.latex() ~ " \\right)";

    super(cat, src, trg, sym, tex);
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

  ulong size() immutable {
    return 2;
  }

  immutable(Morphism) opIndex(ulong I) immutable {
    return morph[I];
  }

}
