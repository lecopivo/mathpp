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

  //  ___    _         _   _ _
  // |_ _|__| |___ _ _| |_(_) |_ _  _
  //  | |/ _` / -_) ' \  _| |  _| || |
  // |___\__,_\___|_||_\__|_|\__|\_, |
  //                             |__/

  // we can reuse linear identity map

  static auto identity(Obj)(Obj obj) if (is_object_impl!(Obj)) {
    return Morphism!(Vec!(Scalar).Identity!(Obj))(Identity!(Obj)(obj));
  }

  //  ____              __  __              _    _
  // |_  /___ _ _ ___  |  \/  |___ _ _ _ __| |_ (_)____ __
  //  / // -_) '_/ _ \ | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  // /___\___|_| \___/ |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                                  |_|

  static auto zero_morphism(Src, Trg)(Src src, Trg trg) {
    return Vec!(Scalar)(src, trg);
  }

  //   ___             _            _     __  __              _    _
  //  / __|___ _ _  __| |_ __ _ _ _| |_  |  \/  |___ _ _ _ __| |_ (_)____ __
  // | (__/ _ \ ' \(_-<  _/ _` | ' \  _| | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  //  \___\___/_||_/__/\__\__,_|_||_\__| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                                                    |_|

  immutable struct Constant(Src, Trg, Val) {

    alias Category = Diff!(Vec!(Scalar));
    alias Source = Src;
    alias Target = Trg;

    Source src;
    Target trg;
    Val val;

    this(Src _src, Trg _trg, Val _val) {
      src = _src;
      trg = _trg;
      val = _val;
    }

    Source source() {
      return src;
    }

    Target target() {
      return trg;
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return val;
    }

    auto tangent_map(this T)() {
      return Product(this, Vec!(Scalar).zero_morphism(src, trg));
    }
  }

  static auto constant_morphism(Src, Trg, Val)(Src src, Trg trg, Val val) {
    return make_morphism(Constant!(Src, Trg, Val)(src, trg, val));
  }

  //   ___                     _   _
  //  / _ \ _ __  ___ _ _ __ _| |_(_)___ _ _  ___
  // | (_) | '_ \/ -_) '_/ _` |  _| / _ \ ' \(_-<
  //  \___/| .__/\___|_| \__,_|\__|_\___/_||_/__/
  //       |_|

  static auto operation(string op, Morph...)(Morph morph)
      if (is_morphism_op_valid!(op, Morph)) {
    return make_morphism(MorphismOp!(op, Morph)(morph));
  }

  static auto compose(Morph...)(Morph morph)
      if (is_morphism_op_valid!("∘", Morph)) {
    return operation!("∘")(morph);
  }

  //  _    ___                        _ _   _
  // | |  / __|___ _ __  _ __  ___ __(_) |_(_)___ _ _
  // | | | (__/ _ \ '  \| '_ \/ _ (_-< |  _| / _ \ ' \
  // | |  \___\___/_|_|_| .__/\___/__/_|\__|_\___/_||_|
  // |_|                |_|

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "∘") {
    import checks;

    return are_composable!(Diff!Scalar, Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "∘" && is_morphism_op_valid!("∘", F, G)) {

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
      return mixin("morph[I](".expand!(N, ""), "x", ")".expand!(N, ""));
    }
  }

  //  _  _           ___      _
  // | || |___ _ __ / __| ___| |_
  // | __ / _ \ '  \\__ \/ -_)  _|
  // |_||_\___/_|_|_|___/\___|\__|

  immutable struct ComposeFromRight(Morph) {

    Morph morph;

    this(Morph _morph) {
      morph = _morph;
    }

    auto opCall(MorphG)(MorphG morphG) if (are_composable!(Morph, MorphG)) {
      return compose(morph, morphG);
    }
  }

  immutable struct ComposeFromLeft(Morph) {

    Morph morph;

    this(Morph _morph) {
      morph = _morph;
    }

    auto opCall(MorphG)(MorphG morphG) if (are_composable!(MorphG, Morph)) {
      return compose(morphG, morph);
    }
  }

  // Functor: Hom(A,-),
  // A == SrcObj
  // f : B→B'
  // Hom(A,f) == (f∘) : (A→B)→(A→B')
  //
  // https://en.wikipedia.org/wiki/Hom_functor#Formal_definition
  immutable struct HomR(SrcObj) {

    alias Source = Diff!(Scalar);
    alias Target = Diff!(Scalar);

    SrcObj srcObj;

    this(SrcObj _srcObj) {
      srcObj = _srcObj;
    }

    auto opCall(TrgObj)(TrgObj trgObj)
        if (is_object_op_valid!("→", SrcObj, TrgObj)) {
      return Hom(srcObj, trgObj);
    }

    auto fmap(Morph)(Morph morph) {

      // Hom(A,-) is covariant
      auto source = this(morph.source());
      auto target = this(morph.target());

      return morphism(source, target, ComposeFromRight!(Morph)(morph));
    }
  }

  // Functor: Hom(-,B),
  // B == TrgObj
  // h : A→A'
  // Hom(h,B) == (∘h) : Hom(A,B) → Hom(A',B)
  //
  // https://en.wikipedia.org/wiki/Hom_functor#Formal_definition
  immutable struct HomL(TrgObj) {

    alias Source = Diff!(Scalar);
    alias Target = Diff!(Scalar);

    TrgObj trgObj;

    this(TrgObj _trgObj) {
      trgObj = _trgObj;
    }

    auto opCall(SrcObj)(SrcObj trgObj)
        if (is_object_op_valid!("→", SrcObj, TrgObj)) {
      return Hom(srcObj, trgObj);
    }

    auto fmap(Morph)(Morph morph) {

      // Hom(-,B) is contravariant
      auto source = this(morph.target());
      auto target = this(morph.source());

      return morphism(source, target, ComposeFromLeft!(Morph)(morph));
    }
  }

  immutable struct Hom {

    alias Source = Diff!(Scalar);
    alias Target = Diff!(Scalar);

    static auto opCall(SrcObj, TrgObj)(SrcObj srcObj, TrgObj trgObj)
        if (is_object_op_valid!("→", SrcObj, TrgObj)) {
      return make_object(ObjectOp!("→", SrcObj, TrgObj)(srcObj, trgObj));
    }

    static auto fmap(MorphF, MorphH)(MorphF morphF, MorphH morphH) {

      // This is basically an implementation of the lower left branch of the commutative diagram at:
      // https://en.wikipedia.org/wiki/Hom_functor#Formal_definition
      alias ObjA = MorphH.Target;
      auto objA = morphH.target();
      auto HomAf = HomR!(ObjA)(objA).fmap(morphF);

      alias ObjBB = MorphF.Target;
      auto objBB = morphF.target();
      auto HomhBB = HomL!(ObjBB)(objBB).fmap(morphH);

      return compose(HomhBB, HomAf);
    }
  }

  static bool is_object_op_valid(string op, Obj...)() if (op == "→") {

    return allSatisfy!(is_object, Obj) && Obj.length == 2;
  }

  // Implementation of HomSet

  immutable struct ObjectOp(string op, Obj...)
      if (op == "→" && is_object_op_valid!("→", Obj)) {

    alias Category = Diff!(Scalar);
    alias Source = Obj[0];
    alias Target = Obj[1];
    alias Arg = Obj;

    this(Obj _obj) {
      obj = _obj;
    }

    Source source() {
      return obj[0];
    }

    Target target() {
      return obj[1];
    }

    auto arg(int I)() {
      return obj[I];
    }

    static bool is_element(Elem)() {
      return is_morphism!(Elem) && is(Elem.Source == Obj[0]) && is(Elem.Target == Obj[1]);
    }

    auto zero() {
      return zero_morphism(obj[0], obj[1]);
    }
  }

  // static bool is_morphism_op_valid(string op, Morph...)() if (op == "→") {

  //   return allSatisfy!(is_morphism, Morph);
  // }

  // immutable struct MorphismOp(string op, Morph...)
  //     if (op == "→" && is_morphism_op_valid!("→", Morph)) {

  // }

  //  _____                       ___             _         _
  // |_   _|__ _ _  ___ ___ _ _  | _ \_ _ ___  __| |_  _ __| |_
  //   | |/ -_) ' \(_-</ _ \ '_| |  _/ '_/ _ \/ _` | || / _|  _|
  //   |_|\___|_||_/__/\___/_|   |_| |_| \___/\__,_|\_,_\__|\__|

  // We mainly consider `Product` as a limit and not as a bi-functor

  immutable struct Product {

    alias Source = Diff!(Scalar);
    alias Target = Diff!(Scalar);

    static auto opCall(Obj...)(Obj obj) if (is_object_op_valid!("⊗", Obj)) {
      return make_object(ObjectOp!("⊗", Obj)(obj));
    }

    static auto lmap(Morph...)(Morph morph) if (is_morphism_op_valid!("⊗", Morph)) {
      return make_morphism(MorphismOp!("⊕", Morph)(morph));
    }

    static auto fmap(Morph...)(Morph morph) {
      const int N = Morph.length;
      auto source = mixin("this(", "morph[I].source()".expand!(N), ")");
      return mixin("lmap(", "compose(morph[i], source.projection!(I))".expand!(N), ")");
    }
  }

  // Object Operation

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

    auto projection(int I)() {
      return morphism!(x => x[I])(make_object(this), obj[I]);
    }

    auto zero() {
      import algebraictuple;

      return mixin("algebraicTuple(", expand!(Obj.length, "obj[I].zero()"), ")");
    }
  }

  // Morphism Operation

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "⊗") {
    return (Morph.length >= 2) && has_same_source!(Diff!(Scalar), Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "⊗" && is_morphism_op_valid!("⊗", Morph)) {

    alias Category = Vec!(double);
    alias Source = Morph[0];
    alias Target = ReturnType!(Product.opCall!(staticMap!(TargetOf, Morph)));
    alias Arg = Morph;

    Morph morph;

    this(Morph _morph) {
      morph = _morph;
    }

    Source source() {
      return morph[0].source();
    }

    Target target() {
      const int N = Morph.length;
      return mixin("Product(", expand!(N, "morph[I].target()"), ")");
    }

    auto arg(int I)() {
      return morph[I];
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      import algebraictuple;

      const int N = Morph.length;
      return mixin("algebraicTuple(", "morph[I](x)".expand!(N), ")");
    }
  }

  //   ___                  _
  //  / __|  _ _ _ _ _ _  _(_)_ _  __ _
  // | (_| || | '_| '_| || | | ' \/ _` |
  //  \___\_,_|_| |_|  \_, |_|_||_\__, |
  //                   |__/       |___/

  // static bool is_object_op_valid(string op, Obj...)() if (op == "λ") {
  //   return Obj.length == 1 && allSatisfy!(is_object, Obj);
  // }

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "λ") {
    return Morph.length == 1 && allSatisfy!(is_morphism, Morph)
      && is_product_object!(Morph.Source, 2);
  }

  immutable struct Bind(Morph, X) {

    Morph morph;
    X x;

    this(Morph _morph, X _x) {
      morph = _morph;
      x = _x;
    }

    auto opCall(Y)(Y y) {
      return morph(algebraicTuple(x, y));
    }
  }

  immutable struct Curry(Morph) {

    Morph morph;

    this(Morph _morph) {
      morph = _morph;
    }

    auto opCall(X)(X x) {
      return morphism(morph.source().arg!(1), morph.target(), Bind!(Morph, X)(morph, x));
    }
  }

  // curry should be full blown morphism
  auto curry(Morph)(Morph morph) {
    auto source = morph.source().arg!(0);
    auto target = Hom(morph.source().arg!(1), morph.target());
    return morphism(source, target, Curry!(Morph)(morph));
  }

  //  _   _
  // | | | |_ _  __ _  _ _ _ _ _ _  _
  // | |_| | ' \/ _| || | '_| '_| || |
  //  \___/|_||_\__|\_,_|_| |_|  \_, |
  //                             |__/

  immutable struct Uncurry(Morph) {

    this(Morph _morph) {
      morph = _morph;
    }

    auto opCall(X)(X x) {
      return morph(x[0])(x[1]);
    }
  }

  auto uncurry(Morph)(Morph morph) {
    return morphism(Product(morph.source(), morph.target().source()),
        morph.target().target(), Uncurry!(Morph)(morph));
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

  immutable struct TangentMap {

    alias Source = Diff!(Scalar);
    alias Target = Diff!(Scalar);

    static auto opCall(Obj)(Obj obj) if (is_object_op_valid!("T", Obj)) {
      return Product(obj, obj);
    }

    static auto fmap(Morph)(Morph morph) if (is_morphism_op_valid!("T", Morph)) {

       is(Morph : Morphism!(Impl), Impl);

      // Linear map
      static if (Vec!(Scalar).is_morphism!(Morph)) {
        ////////////////////////////////////////////
        return Product.fmap(morph, morph);
      }
      else static if (is_operation_morphism!(Morph)) {
        //////////////////////////////////////////////
        const string op = morphism_operation!(Morph);

        // Product
        static if (op == "⊗") {
          /////////////////////

          return compose(Transpose, Product.lmap(TangentMap.fmap(morph.arg!(0),
              morph.arg!(1))), Tranpose);
        } // Addition
        else static if (op == "+") {
          //////////////////////////

          return operation("+", TangentMap.fmap(morph.arg!(0)), TangentMap.fmap(morph.arg!(1)));
        }
        else static if (op == "∘") {
          //////////////////////////
          return operation("∘", TangentMap.fmap(morph.arg!(0)),
              TangentMap.fmap(morph.arg!(1)));
        } // Unknown
        else {
          static assert(false, "Unknow operation!");
          return false;
        }
      }
      else static if (is(Impl : Constant!(X), X)) {
        ///////////////////////////////////////////

      }
      else static if (is(Impl : ComposeFromRight!(MorphF), MorphF)) {
        /////////////////////////////////////////////////////////////
        // The morhism is of the form
        // (f∘) : (A→B)→(A→B')

        // Extract object A, call it SrcObj
        alias SrcObj = Morph.Source.Arg[0];
        auto srcObj = morph.source().arg!(0);

        // Initialize covariant Functor Hom(A,-)
        auto homR = HomR!(SrcObj)(srcObj);

        // The source of the tangent map is: T(A→B) = (A→B)⊗(A→B)
        auto Tsource = TangentMap(morph.source());

        // The function `f` is stored inside of 
        auto f = morph.morph;

        // f1 = ((f∘)∘π0) 
        auto f1 = compose(homR.fmap(f), Tsource.projection!(0));

        // Tf
        auto Tmorph = TangentMap(f);
        // (π0⊗π1)
        auto pi0_otimes_pi1 = Product.lmap(Tsource.projection(0), Tsource.projection(1));
        // ((Tf)∘)
        auto Tmorph_o = homR.fmap(TangentMap(f));
        // (π1∘)
        auto pi1_o = homR.fmap(Tmorph.target().projection(1));

        // f2 = (π1∘)∘((Tf)∘)∘(π0⊗π1)
        auto f2 = compose(pi1_o, Tmorph_o, pi0_otimes_pi1);

        return Product.lmap(f1, f2);
      }
      else static if (is(Impl : ComposeFromLeft!(MorphH), MorphH)) {
        ////////////////////////////////////////////////////////////

      }
      else static if (is(Impl : Curry!(MorphF), MorphF)) {
        ///////////////////////////////////////////////////

      }
      else static if (is(Impl : Bind!(MorphF), MorphF)) {
        ///////////////////////////////////////////////////

      }
      else static if (is(Impl : Uncurry!(MorphF), MorphF)) {
        ///////////////////////////////////////////////////

      }
    }
  }

  static bool is_object_op_valid(string op, Obj...)() if (op == "T") {
    return Obj.length == 1 && allSatisfy!(is_object, Obj);
  }

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "T") {
    return Morph.length == 1 && allSatisfy!(is_morphism, Morph);
  }

  // |
  // ⊗
  // T

  // mayber `curry` or does this come from somewhere else? Currying is probably natural if one has tensor products, there fore it should follow from the tensor product
}
