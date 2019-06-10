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
      return constant(src, trg, trg.zero());
    }
  }

  //  ___             _         _      ___  _     _        _
  // | _ \_ _ ___  __| |_  _ __| |_   / _ \| |__ (_)___ __| |_
  // |  _/ '_/ _ \/ _` | || / _|  _| | (_) | '_ \| / -_) _|  _|
  // |_| |_| \___/\__,_|\_,_\__|\__|  \___/|_.__// \___\__|\__|
  //                                           |__/

  static bool is_object_op_valid(string op, Obj...)() if (op == "⊗") {

    return allSatisfy!(is_object, Obj) && Obj.length >= 2;
  }

  immutable struct ObjectOp(string op, Obj...)
      if (op == "⊗" && is_object_op_valid!("⊗", Obj)) {

    alias Category = Diff!(Scalar);
    alias Arg = Obj;

    Obj obj;

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

      return mixin(expand!(X.length, "Obj[I].is_element!(X[I])", "I", "&&"));
    }

    // auto projection(int I)() {
    //   return morphism!(x => x[I])(make_object(this), obj[I]);
    // }

    auto zero() {
      import algebraictuple;

      return mixin("algebraicTuple(", expand!(Obj.length, "obj[I].zero()"), ")");
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
    return make_morhism(Hom!(ObjX, ObjY, ObjZ)(objX, objY, objZ));
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
  }

  //   ___             _            _
  //  / __|___ _ _  __| |_ __ _ _ _| |_
  // | (__/ _ \ ' \(_-<  _/ _` | ' \  _|
  //  \___\___/_||_/__/\__\__,_|_||_\__|

  immutable struct Constant(ObjX, ObjY) {

    alias Category = Diff!(Scalar);
    alias Source = ObjX;
    alias Target = HomSet!(ObjY, ObjX);

    ObjX objX;
    ObjY objY;

    this(ObjX _objX, ObjY _objY) {
      objX = _objX;
      objY = _objY;
    }

    Source source() {
      return src;
    }

    Target target() {
      return make_homset(objY, objX);
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return constant_morphism(objY, objX, x);
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
  }

  //  _  _
  // | || |___ _ __
  // | __ / _ \ '  \
  // |_||_\___/_|_|_|

  immutable struct Hom(ObjX, ObjY, ObjZ) {

    private alias HomXY = ReturnType!(make_homset!(ObjX, ObjY));
    private alias HomYZ = ReturnType!(make_homset!(ObjY, ObjZ));
    private alias HomXZ = ReturnType!(make_homset!(ObjX, ObjZ));

    alias Source = ReturnType!(make_prod_object!(HomXY, HomYZ));
    alias Target = HomXZ;

    Source src;
    Target trg;

    this(ObjX objX, ObjY objY, ObjZ objZ) {
      auto homXY = make_homset(objX, objY);
      auto homYZ = make_homset(objX, objY);
      auto homXZ = make_homset(objX, objY);

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
      return compose(x.arg[1], x.arg[0]);
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

    alias Source = ReturnType!(make_prod_object!(HomXY, HomXY));
    alias Target = ReturnType!(make_homset!(ObjX, ProdYZ));

    Source src;
    Target trg;

    this(ObjX objX, ObjY objY, ObjZ objZ) {
      auto homXY = make_homset(objX, objY);
      auto homXZ = make_homset(objX, objZ);
      auto prodYZ = make_prod_object(objY, objZ);

      src = make_prod_object(homXY, homXZ);
      trg = make_homset(objY, homYZ);
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
  }

  //  ___          _
  // | __|_ ____ _| |
  // | _|\ V / _` | |
  // |___|\_/\__,_|_|

  immutable struct Eval(ObjX, ObjY) {
    private alias HomXY = ReturnType!(make_homset!(ObjX, ObjY));

    alias Source = ReturnType!(make_prod_object!(HomXY, ObjX));
    alias Target = ObjY;

    Source src;
    Target trg;

    this(ObjX objX, ObjY objY, ObjZ objZ) {
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
      return x.arg[0](x.arg[1]);
    }
  }

  //   ___             _            _     __  __              _    _
  //  / __|___ _ _  __| |_ __ _ _ _| |_  |  \/  |___ _ _ _ __| |_ (_)____ __
  // | (__/ _ \ ' \(_-<  _/ _` | ' \  _| | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  //  \___\___/_||_/__/\__\__,_|_||_\__| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                                                    |_|

  immutable struct ConstantMorphism(Src, Trg, Elem) {

    alias Category = Diff!(Scalar);
    alias Source = ObjX;
    alias Target = ObjY;

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

    morph morph;

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
      return mixin("morph[I](".expand!(N, ""), "x", ")".expand!(N, ""));
    }
  }

  //  ___             _         _     __  __         _    _
  // | _ \_ _ ___  __| |_  _ __| |_  |  \/  |___ _ _| |_ (_)____ __
  // |  _/ '_/ _ \/ _` | || / _|  _| | |\/| / _ \ '_| ' \| (_-< '  \
  // |_| |_| \___/\__,_|\_,_\__|\__| |_|  |_\___/_| |_||_|_/__/_|_|_|

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "⊗") {
    return (Morph.length >= 2) && has_same_source!(Diff!(Scalar), Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "⊗" && is_morphism_op_valid!("⊗", Morph)) {

    private static const int N = Morph.length;

    alias Category = Diff!(double);
    alias Source = Morph[0].Source;
    alias Target = ReturnType!(mixin("make_prod_object!(", "Morph[I].Target".expand!N, ")"));
    alias Arg = Morph;

    Morph morph;

    this(Morph _morph) {
      morph = _morph;
    }

    Source source() {
      return morph[0].source();
    }

    Target target() {
      return mixin("make_prod_object(", "morph[I].target()".expand!N, ")");
    }

    auto arg(int I)() {
      return morph[I];
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      import algebraictuple;

      return mixin("algebraicTuple(", "morph[I](x)".expand!N, ")");
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
