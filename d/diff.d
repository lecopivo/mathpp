immutable struct Diff(Scalar) {

  import std.traits;

  import base;
  import vec;

  //  ___       ___  _     _        _
  // |_ _|___  / _ \| |__ (_)___ __| |_
  //  | |(_-< | (_) | '_ \| / -_) _|  _|
  // |___/__/  \___/|_.__// \___\__|\__|
  //                    |__/

  static bool is_object_impl(Obj, bool fail_if_false = false)() {

    const bool is_Vec_object = Vec!(Scalar).is_object_impl!(Obj, fail_if_false);

    return is_Vec_object;
  }

  static bool is_object(Obj, bool fail_if_false = false)() {
    return is_object_impl!(Obj, fail_if_false) && is(Obj : Object!(Impl), Impl);
  }

  //  ___      __  __              _    _
  // |_ _|___ |  \/  |___ _ _ _ __| |_ (_)____ __
  //  | |(_-< | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  // |___/__/ |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                         |_|

  static bool is_morphism_impl(Morph, bool fail_if_false = false)() {

    const bool is_Vec_morphism = Vec!(Scalar).is_morphism_impl!(Morph, fail_if_false);

    // There are two options:
    // The morhism implements its own `grad`
    // It is a morphism in Vec

    return is_Vec_morphism;
  }

  static bool is_morphism(Morph, bool fail_if_false = false)() {
    return is_morphism_impl!(Morph, fail_if_false) && is(Morph : Morphism!(Impl), Impl);
  }

  //  ___              _      _    ___  _     _        _
  // / __|_ __  ___ __(_)__ _| |  / _ \| |__ (_)___ __| |_ ___
  // \__ \ '_ \/ -_) _| / _` | | | (_) | '_ \| / -_) _|  _(_-<
  // |___/ .__/\___\__|_\__,_|_|  \___/|_.__// \___\__|\__/__/
  //     |_|                               |__/

  static auto make_homset(Src, Trg)(Src src, Trg trg) {
    return make_object(HomSet!(Src, Trg)(src, trg));
  }

  static auto make_prod_object(Obj...)(Obj obj) {
    return make_object(ObjectOp!("⊗", Obj)(obj));
  }

  //  _  _           ___      _
  // | || |___ _ __ / __| ___| |_
  // | __ / _ \ '  \\__ \/ -_)  _|
  // |_||_\___/_|_|_|___/\___|\__|

  immutable struct HomSet(Src, Trg) {

    alias Category = Diff!(Scalar);
    alias Source = Src;
    alias Target = Trg;

    Source src;
    Target trg;

    this(Src _src, Trg _trg) {
      src = _src;
      trg = _trg;
    }

    Source source() {
      return src;
    }

    Target target() {
      return trg;
    }

    static bool is_element(Elem)() {
      return is_morphism!(Elem) && is(Elem.Source == Source) && is(Elem.Target == Target);
    }

    auto zero() {
      return constant_morphism(src, trg, trg.zero());
    }

    string symbol() {
      return "(" ~ src.symbol() ~ "→" ~ trg.symbol() ~ ")";
    }

    string latex() {
      return "\\left( " ~ src.latex() ~ "\\rightarrow " ~ trg.latex() ~ "\\right) ";
    }
  }

  //  ___             _         _      ___  _     _        _
  // | _ \_ _ ___  __| |_  _ __| |_   / _ \| |__ (_)___ __| |_
  // |  _/ '_/ _ \/ _` | || / _|  _| | (_) | '_ \| / -_) _|  _|
  // |_| |_| \___/\__,_|\_,_\__|\__|  \___/|_.__// \___\__|\__|
  //                                           |__/

  static bool is_object_op_valid(string op, Obj...)() if (op == "⊗") {
    enum N = Obj.length;
    return mixin("is_object!(Obj[I])".expand(N, "&&")) && Obj.length >= 2;
  }

  immutable struct ObjectOp(string op, Obj...)
      if (op == "⊗" && is_object_op_valid!("⊗", Obj)) {

    alias Category = Diff!(Scalar);
    alias Arg = Obj;

    Obj obj;

    private enum N = Obj.length;

    this(Obj _obj) {
      obj = _obj;
    }

    auto arg(int I)() {
      return obj[I];
    }

    static bool is_element(Elem)() {
      import algebraictuple;

      static if (!is(Elem : AlgebraicTuple!(X), X...)) {
        return false;
      }

      static if (X.length != Obj.length) {
        return false;
      }

      return mixin("Obj[I].is_element!(X[I])".expand(N, "&&"));
    }

    // auto projection(int I)() {
    //   return morphism!(x => x[I])(make_object(this), obj[I]);
    // }

    auto zero() {
      import algebraictuple;

      return mixin("algebraicTuple(", "obj[I].zero()".expand(N), ")");
    }

    string symbol() {
      return "(" ~ mixin("obj[I].symbol()".expand(N, "~ \"⊗\"  ~")) ~ ")";
    }

    string latex() {
      return " \\left( " ~ mixin("obj[I].latex()".expand(N, "~ \" \\\\otimes  \"  ~"))
        ~ " \\right) ";
    }
  }

  //  ___              _      _   __  __         _    _
  // / __|_ __  ___ __(_)__ _| | |  \/  |___ _ _| |_ (_)____ __  ___
  // \__ \ '_ \/ -_) _| / _` | | | |\/| / _ \ '_| ' \| (_-< '  \(_-<
  // |___/ .__/\___\__|_\__,_|_| |_|  |_\___/_| |_||_|_/__/_|_|_/__/
  //     |_|

  // Small Trinity

  static auto identity(Obj)(Obj obj) if (is_object_impl!(Obj)) {
    return make_morphism(Identity!(Obj)(obj));
  }

  static auto constant(ObjX, ObjY)(ObjX objX, ObjY objY) {
    return make_morphism(Constant!(ObjX, ObjY)(objX, objY));
  }

  static auto projection(int I, Obj...)(Obj obj) {
    return make_morphism(Projection!(I, Obj)(obj));
  }

  // Big Trinity

  static auto hom(ObjX, ObjY, ObjZ)(ObjX objX, ObjY objY, ObjZ objZ) {
    return make_morphism(Hom!(ObjX, ObjY, ObjZ)(objX, objY, objZ));
  }

  static auto prod(ObjX, ObjY, ObjZ)(ObjX objX, ObjY objY, ObjZ objZ) {
    return make_morphism(Prod!(ObjX, ObjY, ObjZ)(objX, objY, objZ));
  }

  static auto eval(ObjX, ObjY)(ObjX objX, ObjY objY) {
    return make_morphism(Eval!(ObjX, ObjY)(objX, objY));
  }

  // Hidden Trinity

  static auto constant_morphism(Src, Trg, Elem)(Src src, Trg trg, Elem elem) {
    return make_morphism(ConstantMorphism!(Src, Trg, Elem)(src, trg, elem));
  }

  static auto compose(Morph...)(Morph morph)
      if (is_morphism_op_valid!("∘", Morph)) {
    return operation!("∘")(morph);
  }

  static auto product_morphism(Morph...)(Morph morph)
      if (is_morphism_op_valid!("⊗", Morph)) {
    return operation!("⊗")(morph);
  }

  // General operation

  static auto operation(string op, Morph...)(Morph morph)
      if (is_morphism_op_valid!(op, Morph)) {
    return make_morphism(MorphismOp!(op, Morph)(morph));
  }

  //  ___          _            _   __  __              _    _
  // |   \ ___ _ _(_)_ _____ __| | |  \/  |___ _ _ _ __| |_ (_)____ __
  // | |) / -_) '_| \ V / -_) _` | | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  // |___/\___|_| |_|\_/\___\__,_| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                                              |_|

  static auto transpose(ObjX, ObjY)(ObjX objX, ObjY objY) {
    return product_morphism(projection!(1)(objX, objY), projection!(0)(objX, objY));
  }

  static auto diagonal(Obj)(Obj obj) {
    return product_morphism(identity(obj), identity(obj));
  }

  static auto pair(ObjX, ObjY)(ObjX objX, ObjY objY) {

    auto homYY = make_homset(objY, objY);
    auto idY = identity(objY);

    auto xi1 = product_morphism(constant(objX, objY), constant_morphism(objX, homYY, idY));
    auto pr = prod(objY, objX, objY);

    return compose(pr, xi1);
  }

  static auto pairT(ObjX, ObjY)(ObjX objX, ObjY objY) {

    auto homYY = make_homset(objY, objY);
    auto idY = identity(objY);

    auto xi1 = product_morphism(constant_morphism(objX, homYY, idY), constant(objX, objY));
    auto pr = prod(objY, objY, objX);

    return compose(pr, xi1);
  }

  // hom(X,-)
  static auto homR(ObjX, ObjY, ObjZ)(ObjX objX, ObjY objY, ObjZ objZ) {

    auto homXY = make_homset(objX, objY);
    auto homYZ = make_homset(objY, objZ);
    auto homXZ = make_homset(objX, objZ);
    auto homHom = make_homset(make_prod_object(homXY, homYZ), homXZ);

    auto xi1 = product_morphism(pairT(homYZ, homXY), constant_morphism(homYZ,
        homHom, hom(objX, objY, objZ)));
    auto xi2 = hom(homXY, make_prod_object(homXY, homYZ), homXZ);

    return compose(xi2, xi1);
  }

  // hom(-,Z)
  static auto homL(ObjX, ObjY, ObjZ)(ObjX objX, ObjY objY, ObjZ objZ) {

    auto homXY = make_homset(objX, objY);
    auto homYZ = make_homset(objY, objZ);
    auto homXZ = make_homset(objX, objZ);
    auto homHom = make_homset(make_prod_object(homXY, homYZ), homXZ);

    auto xi1 = product_morphism(pair(homXY, homYZ), constant_morphism(homXY,
        homHom, hom(objX, objY, objZ)));
    auto xi2 = hom(homYZ, make_prod_object(homXY, homYZ), homXZ);

    return compose(xi2, xi1);
  }

  // hom(X,f)==f∘  or  hom(g,Z)==∘g
  static auto hom(ObjOrMorph1, ObjOrMorph2)(ObjOrMorph1 om1, ObjOrMorph2 om2)
      if ((is_object!(ObjOrMorph1) && is_morphism!(ObjOrMorph2))
        || (is_object!(ObjOrMorph2) && is_morphism!(ObjOrMorph1))) {

    static if (is_object!(ObjOrMorph1)) {
      return homR(om1, om2.source(), om2.target())(om2);
    }
    else {
      return homL(om1.source(), om1.target(), om2)(om1);
    }
  }

  static auto curry(ObjX, ObjY, ObjZ)(ObjX objX, ObjY objY, ObjZ objZ) {
    auto xi1 = homR(objY, make_prod_object(objX, objY), objZ);
    auto xi2 = hom(pair(objX, objY), make_homset(objY, objZ));

    return compose(xi2, xi1);
  }

  static auto curry(Morph)(Morph morph) {
    return curry(morph.source().arg!(0), morph.source().arg!(1), morph.target())(morph);
  }

  // -⊗Z 
  static auto prodL(ObjX, ObjY, ObjZ)(ObjX objX, ObjY objY, ObjZ objZ) {
    return curry(prod(objX, objY, objZ));
  }

  // Y⊗- 
  static auto prodR(ObjX, ObjY, ObjZ)(ObjX objX, ObjY objY, ObjZ objZ) {
    
    auto homXY = make_homset(objX,objY);
    auto homXZ = make_homset(objX,objZ);
    
    return curry(compose(prod(objX, objZ, objY), transpose(homXY,homXZ)));
    //return prod(objX, objY, objZ);
  }

  // f⊗Z or Y⊗g --- (f⊗Z)(g) = f⊗g or (Y⊗g)(f)=f⊗g
  static auto prod(ObjOrMorph1, ObjOrMorph2)(ObjOrMorph1 om1, ObjOrMorph2 om2)
      if ((is_object!(ObjOrMorph1) && is_morphism!(ObjOrMorph2))
        || (is_object!(ObjOrMorph2) && is_morphism!(ObjOrMorph1))) {

    static if (is_object!(ObjOrMorph1)) {
      return prodR(om2.source(), om2.target(), om1)(om2);
    }
    else {
      return prodL(om1.source(), om2, om1.target())(om1);
    }
  }

  static auto uncurry(ObjX, ObjY, ObjZ)(ObjX objX, ObjY objY, ObjZ objZ) {

    auto prodXY = make_prod_object(objX, objY);
    auto homYZ = make_homset(objY, objZ);

    auto xi1 = hom(projection!(0)(objX, objY), homYZ);
    auto xi2 = prod(homYZ, projection!(1)(objX,objY));
    auto xi3 = hom(prodXY, eval(objY, objZ));

    // import std.stdio;
    
    // writeln("Transpose");
    // writeln(transpose(objX,objY).source().symbol(), "\n");
    // writeln(transpose(objX,objY).target().symbol(), "\n");
    
    // writeln("Prod");
    // writeln(prod(objX,objY,objZ).source().symbol(), "\n");
    // writeln(prod(objX,objY,objZ).target().symbol(), "\n");
    
    // writeln("Prod L");
    // writeln(prodL(objX,objY,objZ).source().symbol(), "\n");
    // writeln(prodL(objX,objY,objZ).target().symbol(), "\n");
    
    // writeln("Prod R");
    // writeln(prodR(objX,objY,objZ).source().symbol(), "\n");
    // writeln(prodR(objX,objY,objZ).target().symbol(), "\n");

	    
    
    // writeln(xi1.target().symbol(), "\n");
    // writeln(xi2.source().symbol(), "\n");
    // writeln(xi2.target().symbol(), "\n");
    // writeln(xi3.source().symbol(), "\n");

    return compose(xi3, xi2, xi1);
  }

  static auto uncurry(Morph)(Morph morph) {
    return uncurry(morph.source(), morph.target().source(), morph.target().target())(morph);
  }

  //  ___    _         _   _ _
  // |_ _|__| |___ _ _| |_(_) |_ _  _
  //  | |/ _` / -_) ' \  _| |  _| || |
  // |___\__,_\___|_||_\__|_|\__|\_, |
  //                             |__/

  immutable struct Identity(Obj) if (is_object!(Obj)) {

    alias Category = Diff!(Scalar);
    alias Source = Obj;
    alias Target = Obj;

    Obj obj;

    this(Obj _obj) {
      obj = _obj;
    }

    Source source() {
      return obj;
    }

    Target target() {
      return obj;
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return x;
    }

    string symbol() {
      return "id";
    }

    string latex() {
      return "\\text{id}_{" ~ obj.latex() ~ "}";
    }
  }

  //   ___             _            _
  //  / __|___ _ _  __| |_ __ _ _ _| |_
  // | (__/ _ \ ' \(_-<  _/ _` | ' \  _|
  //  \___\___/_||_/__/\__\__,_|_||_\__|

  immutable struct Constant(ObjX, ObjY) {

    alias Category = Diff!(Scalar);
    alias Source = ObjX;
    alias Target = ReturnType!(make_homset!(ObjY, ObjX));

    ObjX objX;
    ObjY objY;

    this(ObjX _objX, ObjY _objY) {
      objX = _objX;
      objY = _objY;
    }

    Source source() {
      return objX;
    }

    Target target() {
      return make_homset(objY, objX);
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return constant_morphism(objY, objX, x);
    }

    string symbol() {
      return "const";
    }

    string latex() {
      return "\\text{const}_{" ~ objY.latex() ~ "}";
    }
  }

  //  ___          _        _   _
  // | _ \_ _ ___ (_)___ __| |_(_)___ _ _
  // |  _/ '_/ _ \| / -_) _|  _| / _ \ ' \
  // |_| |_| \___// \___\__|\__|_\___/_||_|
  //            |__/

  immutable struct Projection(int I, Obj...) {

    alias Category = Diff!(Scalar);
    alias Source = ReturnType!(make_prod_object!(Obj));
    alias Target = Obj[I];

    Source src;

    this(Obj obj) {
      src = make_prod_object(obj);
    }

    Source source() {
      return src;
    }

    Target target() {
      return src.arg!(I);
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return x[I];
    }

    string symbol() {
      import std.conv;

      return "π" ~ to!string(I);
    }

    string latex() {
      import std.conv;

      return "\\pi_{" ~ to!string(I) ~ "}";
    }
  }

  //  _  _
  // | || |___ _ __
  // | __ / _ \ '  \
  // |_||_\___/_|_|_|

  immutable struct Hom(ObjX, ObjY, ObjZ) {

    private alias HomXY = ReturnType!(make_homset!(ObjX, ObjY));
    private alias HomYZ = ReturnType!(make_homset!(ObjY, ObjZ));
    private alias HomXZ = ReturnType!(make_homset!(ObjX, ObjZ));

    alias Category = Diff!(Scalar);
    alias Source = ReturnType!(make_prod_object!(HomXY, HomYZ));
    alias Target = HomXZ;

    Source src;
    Target trg;

    this(ObjX objX, ObjY objY, ObjZ objZ) {
      auto homXY = make_homset(objX, objY);
      auto homYZ = make_homset(objY, objZ);
      auto homXZ = make_homset(objX, objZ);

      src = make_prod_object(homXY, homYZ);
      trg = homXZ;
    }

    Source source() {
      return src;
    }

    Target target() {
      return trg;
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return compose(x[1], x[0]);
    }

    string symbol() {
      return "hom";
    }

    string latex() {
      //return "\\text{hom}_{" ~ src.latex() ~ "," ~ trg.latex() ~ "}";
      return "\\text{hom}";
    }
  }

  //  ___             _
  // | _ \_ _ ___  __| |
  // |  _/ '_/ _ \/ _` |
  // |_| |_| \___/\__,_|

  immutable struct Prod(ObjX, ObjY, ObjZ) {
    private alias HomXY = ReturnType!(make_homset!(ObjX, ObjY));
    private alias HomXZ = ReturnType!(make_homset!(ObjX, ObjZ));
    private alias ProdYZ = ReturnType!(make_prod_object!(ObjY, ObjZ));

    alias Category = Diff!(Scalar);
    alias Source = ReturnType!(make_prod_object!(HomXY, HomXZ));
    alias Target = ReturnType!(make_homset!(ObjX, ProdYZ));

    Source src;
    Target trg;

    this(ObjX objX, ObjY objY, ObjZ objZ) {
      auto homXY = make_homset(objX, objY);
      auto homXZ = make_homset(objX, objZ);
      auto prodYZ = make_prod_object(objY, objZ);

      src = make_prod_object(homXY, homXZ);
      trg = make_homset(objX, prodYZ);
    }

    Source source() {
      return src;
    }

    Target target() {
      return trg;
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return product_morphism(x.expand);
    }

    string symbol() {
      return "Prod";
    }

    string latex() {
      return "\\text{Prod}";
    }
  }

  //  ___          _
  // | __|_ ____ _| |
  // | _|\ V / _` | |
  // |___|\_/\__,_|_|

  immutable struct Eval(ObjX, ObjY) {
    private alias HomXY = ReturnType!(make_homset!(ObjX, ObjY));

    alias Category = Diff!(Scalar);
    alias Source = ReturnType!(make_prod_object!(HomXY, ObjX));
    alias Target = ObjY;

    Source src;
    Target trg;

    this(ObjX objX, ObjY objY) {
      auto homXY = make_homset(objX, objY);

      src = make_prod_object(homXY, objX);
      trg = objY;
    }

    Source source() {
      return src;
    }

    Target target() {
      return trg;
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return x[0](x[1]);
    }

    string symbol() {
      return "Eval";
    }

    string latex() {
      return "\\text{Eval}";
    }
  }

  //   ___             _            _     __  __              _    _
  //  / __|___ _ _  __| |_ __ _ _ _| |_  |  \/  |___ _ _ _ __| |_ (_)____ __
  // | (__/ _ \ ' \(_-<  _/ _` | ' \  _| | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  //  \___\___/_||_/__/\__\__,_|_||_\__| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                                                    |_|

  immutable struct ConstantMorphism(Src, Trg, Elem) {

    alias Category = Diff!(Scalar);
    alias Source = Src;
    alias Target = Trg;

    Source src;
    Target trg;
    Elem elem;

    this(Src _src, Trg _trg, Elem _elem) {
      src = _src;
      trg = _trg;
      elem = _elem;
    }

    Source source() {
      return src;
    }

    Target target() {
      return trg;
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return elem;
    }

    string symbol() {
      return "const(" ~ elem.symbol() ~ ")";
    }

    string latex() {
      return "\\text{const}_{" ~ src.latex() ~ "}\\left( " ~ elem.latex() ~ " \\right) ";
    }
  }

  //   ___                                _   __  __         _    _
  //  / __|___ _ __  _ __  ___ ___ ___ __| | |  \/  |___ _ _| |_ (_)____ __
  // | (__/ _ \ '  \| '_ \/ _ (_-</ -_) _` | | |\/| / _ \ '_| ' \| (_-< '  \
  //  \___\___/_|_|_| .__/\___/__/\___\__,_| |_|  |_\___/_| |_||_|_/__/_|_|_|
  //                |_|

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "∘") {
    import checks;

    return are_composable!(Diff!Scalar, Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "∘" && is_morphism_op_valid!("∘", Morph)) {

    alias Category = Diff!Scalar;
    alias Source = Morph[$ - 1].Source;
    alias Target = Morph[0].Target;
    alias Arg = Morph;

    Morph morph;

    private enum N = Morph.length;

    this(Morph _morph) {
      morph = _morph;
    }

    Source source() {
      return morph[$ - 1].source();
    }

    Target target() {
      return morph[0].target();
    }

    auto arg(int I)() {
      return morph[I];
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {

      const int N = Morph.length;
      // return morphi[0](...morph[N-1](x))...)
      return mixin("morph[I](".expand(N, ""), "x", ")".expand(N, ""));
    }

    string symbol() {
      return "(" ~ mixin("morph[I].symbol()".expand(N, "~ \"∘\"  ~")) ~ ")";
    }

    string latex() {
      return " \\left( " ~ mixin("morph[I].latex()".expand(N, "~ \" \\\\circ  \"  ~"))
        ~ " \\right) ";
    }

  }

  //  ___             _         _     __  __         _    _
  // | _ \_ _ ___  __| |_  _ __| |_  |  \/  |___ _ _| |_ (_)____ __
  // |  _/ '_/ _ \/ _` | || / _|  _| | |\/| / _ \ '_| ' \| (_-< '  \
  // |_| |_| \___/\__,_|\_,_\__|\__| |_|  |_\___/_| |_||_|_/__/_|_|_|

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "⊗") {
    import checks;

    return (Morph.length >= 2) && has_same_source!(Diff!(Scalar), Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "⊗" && is_morphism_op_valid!("⊗", Morph)) {

    private static const int N = Morph.length;

    alias Category = Diff!(double);
    alias Source = Morph[0].Source;
    alias Target = ReturnType!(mixin("make_prod_object!(", "Morph[I].Target".expand(N), ")"));
    alias Arg = Morph;

    Morph morph;

    this(Morph _morph) {
      morph = _morph;
    }

    Source source() {
      return morph[0].source();
    }

    Target target() {
      return mixin("make_prod_object(", "morph[I].target()".expand(N), ")");
    }

    auto arg(int I)() {
      return morph[I];
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      import algebraictuple;

      return mixin("algebraicTuple(", "morph[I](x)".expand(N), ")");
    }

    string symbol() {
      return "(" ~ mixin("morph[I].symbol()".expand(N, "~ \"⊗\"  ~")) ~ ")";
    }

    string latex() {
      return " \\left( " ~ mixin("morph[I].latex()".expand(N,
          "~ \" \\\\otimes  \"  ~")) ~ " \\right) ";
    }

  }

  //  ___          _      ___ _            _ _  __
  // | _ ) __ _ __(_)__  / __(_)_ __  _ __| (_)/ _|_  _
  // | _ \/ _` (_-< / _| \__ \ | '  \| '_ \ | |  _| || |
  // |___/\__,_/__/_\__| |___/_|_|_|_| .__/_|_|_|  \_, |
  //                                 |_|           |__/

  static auto basicSimplify(Morph)(Morph morph) if (is_morphism!(Morph)) {
    // import std.stdio;
    // writeln(morph.symbol());

    static if (is(Morph : Morphism!(MorphismOp!("∘", M)), M...)) {

      static if (M.length == 2) {

        static if (is(M[0] : Morphism!(Identity!(Args)), Args...)) {
          return basicSimplify(morph.arg!(1));
        }
        else static if (is(M[1] : Morphism!(Identity!(Args)), Args...)) {
          return basicSimplify(morph.arg!(0));
        }
        else static if (is(M[0] : Morphism!(ConstantMorphism!(Args)), Args...)) {
          return basicSimplify(constant_morphism(morph.arg!(1).source(),
              morph.arg!(0).target(), morph.arg!(0).elem));
        }
        else {
          return morph;
        }
      }
      else {
        import std.stdio;

        writeln("Simplification of a composition of more then two morphisms is not supported!");
      }
    }
    else {

      return morph;
    }
  }

  //  _____                       _     __  __
  // |_   _|_ _ _ _  __ _ ___ _ _| |_  |  \/  |__ _ _ __
  //   | |/ _` | ' \/ _` / -_) ' \  _| | |\/| / _` | '_ \
  //   |_|\__,_|_||_\__, \___|_||_\__| |_|  |_\__,_| .__/
  //                |___/                          |_|

  // Need to write special tangent map for:
  //
  // Linear functions
  // Operations: ⊗, +, |
  // Special morphisms: 
  //        1. Constant
  //        2. ComposeFromRight, ComposeFromLeft
  //        3. Curry, Bind, Uncurry

  // Functor 

  // immutable struct TangentMap {

  //   alias Source = Diff!(Scalar);
  //   alias Target = Diff!(Scalar);

  //   static auto opCall(Obj)(Obj obj) if (is_object_op_valid!("T", Obj)) {
  //     return Product(obj, obj);
  //   }

  //   static auto fmap(Morph)(Morph morph) if (is_morphism_op_valid!("T", Morph)) {

  //      is(Morph : Morphism!(Impl), Impl);

  //     // Linear map
  //     static if (Vec!(Scalar).is_morphism!(Morph)) {
  //       ////////////////////////////////////////////
  //       return Product.fmap(morph, morph);
  //     }
  //     else static if (is_operation_morphism!(Morph)) {
  //       //////////////////////////////////////////////
  //       const string op = morphism_operation!(Morph);

  //       // Product
  //       static if (op == "⊗") {
  //         /////////////////////

  //         return compose(Transpose, Product.lmap(TangentMap.fmap(morph.arg!(0),
  //             morph.arg!(1))), Tranpose);
  //       } // Addition
  //       else static if (op == "+") {
  //         //////////////////////////

  //         return operation("+", TangentMap.fmap(morph.arg!(0)), TangentMap.fmap(morph.arg!(1)));
  //       }
  //       else static if (op == "∘") {
  //         //////////////////////////
  //         return operation("∘", TangentMap.fmap(morph.arg!(0)),
  //             TangentMap.fmap(morph.arg!(1)));
  //       } // Unknown
  //       else {
  //         static assert(false, "Unknow operation!");
  //         return false;
  //       }
  //     }
  //     else static if (is(Impl : Constant!(X), X)) {
  //       ///////////////////////////////////////////

  //     }
  //     else static if (is(Impl : ComposeFromRight!(MorphF), MorphF)) {
  //       /////////////////////////////////////////////////////////////
  //       // The morhism is of the form
  //       // (f∘) : (A→B)→(A→B')

  //       // Extract object A, call it SrcObj
  //       alias SrcObj = Morph.Source.Arg[0];
  //       auto srcObj = morph.source().arg!(0);

  //       // Initialize covariant Functor Hom(A,-)
  //       auto homR = HomR!(SrcObj)(srcObj);

  //       // The source of the tangent map is: T(A→B) = (A→B)⊗(A→B)
  //       auto Tsource = TangentMap(morph.source());

  //       // The function `f` is stored inside of 
  //       auto f = morph.morph;

  //       // f1 = ((f∘)∘π0) 
  //       auto f1 = compose(homR.fmap(f), Tsource.projection!(0));

  //       // Tf
  //       auto Tmorph = TangentMap(f);
  //       // (π0⊗π1)
  //       auto pi0_otimes_pi1 = Product.lmap(Tsource.projection(0), Tsource.projection(1));
  //       // ((Tf)∘)
  //       auto Tmorph_o = homR.fmap(TangentMap(f));
  //       // (π1∘)
  //       auto pi1_o = homR.fmap(Tmorph.target().projection(1));

  //       // f2 = (π1∘)∘((Tf)∘)∘(π0⊗π1)
  //       auto f2 = compose(pi1_o, Tmorph_o, pi0_otimes_pi1);

  //       return Product.lmap(f1, f2);
  //     }
  //     else static if (is(Impl : ComposeFromLeft!(MorphH), MorphH)) {
  //       ////////////////////////////////////////////////////////////

  //     }
  //     else static if (is(Impl : Curry!(MorphF), MorphF)) {
  //       ///////////////////////////////////////////////////

  //     }
  //     else static if (is(Impl : Bind!(MorphF), MorphF)) {
  //       ///////////////////////////////////////////////////

  //     }
  //     else static if (is(Impl : Uncurry!(MorphF), MorphF)) {
  //       ///////////////////////////////////////////////////

  //     }
  //   }
  // }

}

unittest {

  import std.stdio;
  import vec;
  import matrix;
  import algebraictuple;

  enum D = Diff!(double)();

  // Initialize vector spaces
  enum R2 = VectorSpace!(double, 2, 1, "V", "V");
  enum R22 = VectorSpace!(double, 2, 2, "L", "L");

  enum VX = VectorSpace!(double, 2, 1, "X", "X");
  enum VY = VectorSpace!(double, 2, 1, "Y", "Y");
  enum VZ = VectorSpace!(double, 2, 1, "Z", "Z");

  // Test if they are objects
  static assert(D.is_object!(typeof(R2)));
  static assert(D.is_object!(typeof(R22)));

  // Initialize few elements
  enum u1 = Matrix!(double, 2, 1)([1, 0]);
  enum u2 = Matrix!(double, 2, 1)([0, 1]);
  enum A1 = Matrix!(double, 2, 2)([0, -1, 1, 0]);
  enum A2 = Matrix!(double, 2, 2)([2, 0, 0, 0.5]);

  // Thest if they are really elements
  static assert(R2.is_element!(typeof(u1)));
  static assert(R2.is_element!(typeof(u2)));
  static assert(R22.is_element!(typeof(A1)));

  // -----------------------------------------------//
  // Homset
  enum homR2R2 = D.make_homset(R2, R2);
  enum homXY = D.make_homset(VX, VY);
  enum homYZ = D.make_homset(VY, VZ);
  enum a1 = Vec!(double).morphism(R2, R2, matMul(A1));
  enum a2 = Vec!(double).morphism(R2, R2, matMul(A2));
  enum g = Vec!(double).morphism(VX, VY, matMul(A1));
  enum f = Vec!(double).morphism(VY, VZ, matMul(A2));

  static assert(homR2R2.is_element!(typeof(a1)));
  static assert(homR2R2.is_element!(typeof(a2)));
  static assert(homXY.is_element!(typeof(g)));
  static assert(homYZ.is_element!(typeof(f)));

  // -----------------------------------------------//
  // Product Space
  enum R2R2 = D.make_prod_object(R2, R2);
  enum u11 = algebraicTuple(u1, u1);
  enum u12 = algebraicTuple(u1, u2);

  static assert(R2R2.is_element!(typeof(u11)));
  static assert(R2R2.is_element!(typeof(u12)));

  // -----------------------------------------------//
  // Identity morphisms
  enum idR2 = D.identity(R2);
  enum idR22 = D.identity(R22);

  // Are they morphisms?
  static assert(D.is_morphism!(typeof(idR2)));
  static assert(D.is_morphism!(typeof(idR22)));

  // Are they really identity morphisms?
  static assert(u1 == idR2(u1));
  static assert(u2 == idR2(u2));
  static assert(A1 == idR22(A1));

  // ----------------------------------------------//
  // Constant Morphism
  enum constant = D.constant(R2, R22);
  enum const_u1 = constant(u1);

  // Test constantness
  static assert(u1 == const_u1(A1));
  static assert(u1 == const_u1(A2));

  // ----------------------------------------------//
  // Projection
  enum pi1 = D.projection!(0)(R2, R2);
  enum pi2 = D.projection!(1)(R2, R2);

  static assert(u1 == pi1(u12));
  static assert(u2 == pi2(u12));

  // ---------------------------------------------//
  // Hom
  enum hom = D.hom(R2, R2, R2);
  enum a12 = hom(algebraicTuple(a1, a2));

  static assert(a2(a1(u1)) == a12(u1));
  static assert(a2(a1(u2)) == a12(u2));

  // ---------------------------------------------//
  // Product
  enum prod = D.prod(R2, R2, R2);
  enum a1_a2 = prod(algebraicTuple(a1, a2));

  static assert(algebraicTuple(a1(u1), a2(u1)) == a1_a2(u1));

  // --------------------------------------------//
  // Eval
  enum eval = D.eval(R2, R2);

  static assert(a1(u1) == eval(algebraicTuple(a1, u1)));
  static assert(a2(u1) == eval(algebraicTuple(a2, u1)));

  //auto a12 = D.MorphismOp!("∘", typeof(a1), typeof(a2))(a1,a2);

  // --------------------------------------------//
  // Pair
  auto pair = D.pair(R2, R22);
  auto pairT = D.pairT(R2, R22);

  static assert(pair(u1)(A1) == algebraicTuple(u1, A1));
  static assert(pairT(u1)(A1) == algebraicTuple(A1, u1));

  // --------------------------------------------//
  // Left and right hom functors
  auto homR = D.homR(R2, R2, R2);
  auto homL = D.homL(R2, R2, R2);

  static assert(homR(a1)(a2)(u1) == a1(a2(u1)));
  static assert(homL(a1)(a2)(u1) == a2(a1(u1)));

  auto a1o = D.hom(R2, a1);
  auto oa1 = D.hom(a1, R2);

  static assert(a1o(a2)(u1) == a1(a2(u1)));
  static assert(oa1(a2)(u1) == a2(a1(u1)));

  // -------------------------------------------//
  // Currying
  auto curry = D.curry(VX, VY, VZ);

  writeln(curry.symbol());
  writeln(" ");
  writeln(D.curry(D.projection!(0)(VX, VY)).latex());
  writeln(D.curry(D.projection!(0)(VX, VY))(u1).latex());
  writeln(D.curry(D.projection!(1)(VX, VY)).latex());
  writeln(D.curry(D.projection!(1)(VX, VY))(u1).latex());
  writeln(" ");
  writeln(D.compose(D.constant(VZ, VY)(u1), g).symbol());

  enum idX = D.identity(VX);
  enum idY = D.identity(VY);
  enum idZ = D.identity(VZ);

  //D.basicSimplify(a1o(a2));
  auto F = D.compose(idZ, D.compose(f, idY));
  auto G = D.compose(D.constant_morphism(VY, VZ, u1), D.compose(idY, D.compose(g, idX)));
  writeln("F:        ", F.symbol());
  writeln("simpl(F): ", D.basicSimplify(F).symbol());
  writeln("G:        ", G.symbol());
  writeln("simpl(G): ", D.basicSimplify(G).symbol());
  writeln();
  writeln("Curry:        " ,curry.symbol());
  writeln("simpl(Curry): ", D.basicSimplify(curry).symbol());

  auto uncurry_curry = D.compose(D.uncurry(VX,VY,VZ),D.curry(VX,VY,VZ));
  auto curry_uncurry = D.compose(D.curry(VX,VY,VZ),D.uncurry(VX,VY,VZ));
  writeln("Uncurry∘Curry: ", uncurry_curry.symbol());
  writeln("Curry∘Uncurry: ", curry_uncurry.symbol());
  

  writeln("Pair");
  writeln(D.pair(VX, VY).symbol());
  writeln("Uncurried pair");
  writeln(D.uncurry(D.pair(VX, VY)).symbol(), "\n");  
  
  
  auto pp = D.uncurry(D.pair(VX, VY));
  writeln("$$\n"~pp.latex()~"\n$$", "\n");
  
  auto c_u1 = D.compose(D.projection!(0)(VX,VY), D.pair(VX,VY)(u1));
  writeln(c_u1.symbol());

  writeln("Hello Diff Test!");
}
