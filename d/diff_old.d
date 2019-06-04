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

      auto call(int I, Y)(Y y) {

        static if (I == 0) {
          return y;
        }
        else {
          static assert(morph[I - 1].Source.is_element!(Y), "Invalid implementation of a moprhism! Element in not in the source set. TODO: Give more info in this message!");
          return call!(I - 1)(morph[I - 1](y));
        }
      }

      return call!(Morph.length)(x);
      
      // // Alternative: return morph[N-1](...morph[0](x)...);
      // return mixin(expand!(Morph.length, "morph[Morph.length-(I+1)](", "I",
      //     ""), "x", expand!(Morph.length, ")", "I", ""));
    }

    auto tangent_map() {
      // The following expands to:
      // return compose(m[0].tangent_map(), ... ,m[$-1].tangent_map())
      return mixin("compose(", expand!(Morph.length, "TangentMap.fmap(morph[I])"), ")");
      // return compose(myMap!(m => m.tangetn_map())(morph));
    }
  }

  //  _  _           ___      _
  // | || |___ _ __ / __| ___| |_
  // | __ / _ \ '  \\__ \/ -_)  _|
  // |_||_\___/_|_|_|___/\___|\__|

  immutable struct ComposeFromRight(SrcObj, Morph) {

    alias Category = Diff!(Scalar);
    alias Source = ReturnType!(Hom.opCall!(SrcObj, Morph.Source));
    alias Target = ReturnType!(Hom.opCall!(SrcObj, Morph.Target));

    HomR!(SrcObj) homR;
    Morph morph;

    this(SrcObj _srcObj, Morph _morph) {
      homR = HomR!(SrcObj)(_srcObj);
      morph = _morph;
    }

    Source source() {
      return homR(morph.source());
    }

    Target target() {
      return homR(morph.target());
    }

    auto opCall(MorphG)(MorphG morphG) if (are_composable!(Morph, MorphG)) {
      return compose(morph, morphG);
    }

    auto tangent_map() {
      auto Tsource = TangentMap(source());

      // f == morph

      // f1 = ((f∘)∘π0) 
      auto f1 = compose(homR.fmap(morph), Tsource.projection!(0));

      // Tf
      auto Tmorph = TangentMap(morph);
      // (π0⊗π1)
      auto pi0_otimes_pi1 = Product.fmap(Tsource.projection(0), Tsource.projection(1));
      // ((Tf)∘)
      auto Tmorph_o = homR.fmap(TangentMap(morph));
      // (π1∘)
      auto pi1_o = homR.fmap(Tmorph.target().projection(1));

      // f2 = (π1∘)∘((Tf)∘)∘(π0⊗π1)
      auto f2 = compose(pi1_o, Tmorph_o, pi0_otimes_pi1);

      return Product.fmap(f1, f2);
    }
  }

  immutable struct ComposeFromLeft(TrgObj, Morph) {

    alias Category = Diff!(Scalar);
    alias Source = ReturnType!(Hom.opCall!(Morph.Target, TrgObj));
    alias Target = ReturnType!(Hom.opCall!(Morph.Source, TrgObj));

    HomL!(TrgObj) homL;
    Morph morph;

    this(TrgObj _trgObj, Morph _morph) {
      homL = HomL!(TrgObj)(_trgObj);
      morph = _morph;
    }

    Source source() {
      return homL(morph.target());
    }

    Target target() {
      return homL(morph.source());
    }

    auto opCall(MorphG)(MorphG morphG) if (are_composable!(MorphG, Morph)) {
      return compose(morphG, morph);
    }

    auto tangent_map() {
      auto Tsource = TangentMap(source());

      // h == morph

      // (∘h)∘π0
      auto f1 = compose(homL.fmap(morph), Tsource.projection(0));
      // (∘h)∘π1
      auto f2 = compose(homL.fmap(morph), Tsource.projection(1));

      // ((∘h)∘π0)⊗((∘h)∘π1)
      return Product.fmap(f1, f2);
    }
  }

  // Functor: Hom(A,-)
  immutable struct HomR(SrcObj) {

    alias Source = Diff!(Scalar);
    alias Target = Diff!(Scalar);

    SrcObj srcObj;

    this(SrcObj _srcObj) {
      srcObj = _srcObj;
    }

    auto opCall(TrgObj)(TrgObj trgObj)
        if (is_object_op_valid!("→", SrcObj, TrgObj)) {
      return make_object(ObjectOp!("→", SrcObj, TrgObj)(srcObj, trgObj));
    }

    auto fmap(Morph)(Morph morph) {

      auto source = this(morph.source());
      auto target = this(morph.target());

      return morphism(source, target, ComposeFromRight!(Morph)(morph));
    }

  }

  immutable struct HomR {

    alias Source = Diff!(Scalar);
    alias Target = Diff!(Scalar);

    static auto opCall(X, Y)(X x, Y y) if (is_object_op_valid!("→", X, Y)) {
      return make_object(ObjectOp!("→", X, Y)(x, y));
    }

    static auto fmap(MorphF, MorphG)(MorphF f, MorphG g)
        if (is_morphism_op_valid("→", MorphF, MorphG)) {

      auto source = this(f.target(), g.source());
      auto target = this(f.source(), g.target());

      return morphism!(h => compose(f, h, g))(source, target, sandwich(f, g));
    }

  }

  static bool is_object_op_valid(string op, Obj...)() if (op == "→") {

    return allSatisfy!(is_object, Obj) && Obj.length == 2;
  }

  immutable struct ObjectOp(string op, Obj...)
      if (op == "→" && is_object_op_valid!("→", Obj)) {

    alias Category = Diff!(Scalar);
    // alias Source = Obj[0];
    // alias Target = Obj[1];
    alias Arg = Obj;

    this(Obj _obj) {
      obj = _obj;
    }

    // Source source() {
    //   return obj[0];
    // }

    // Target target() {
    //   return obj[1];
    // }

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

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "⊗") {

    return allSatisfy!(is_morphism, Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "⊗" && is_morphism_op_valid!("⊗", Morph)) {

  }

  //  _____                       ___             _         _
  // |_   _|__ _ _  ___ ___ _ _  | _ \_ _ ___  __| |_  _ __| |_
  //   | |/ -_) ' \(_-</ _ \ '_| |  _/ '_/ _ \/ _` | || / _|  _|
  //   |_|\___|_||_/__/\___/_|   |_| |_| \___/\__,_|\_,_\__|\__|

  // Functor

  immutable struct Product {

    alias Source = Diff!(Scalar);
    alias Target = Diff!(Scalar);
    static auto opCall(Obj...)(Obj obj) if (is_object_op_valid!("⊗", Obj)) {
      return make_object(ObjectOp!("⊗", Obj)(obj));
    }

    static auto fmap(Morph...)(Morph morph) if (is_morphism_op_valid!("⊗", Morph)) {
      return make_morphism(MorphismOp!("⊕", Morph)(morph));
    }
  }

  // Object Operation

  static bool is_object_op_valid(string op, Obj...)() if (op == "⊗") {

    return allSatisfy!(is_object, Obj) && Obj.length >= 2;
  }

  immutable struct ObjectOp(string op, Obj...)
      if (op == "⊗" && is_object_op_valid!("⊗", Obj)) {

    alias Category = Vec;
    alias impl this;

    ReturnType!(Vec!(Scalar).Sum.opCall!(Obj)) impl;

    this(Obj obj) {
      impl = Vec!(Scalar).Sum(obj);
    }
  }

  // immutable struct Transpose(Obj) {

  //   // This morphism realized the isomorphism: ((A⊗B)⊗(C⊗D)) ~ ((A⊗C)⊗(B⊗D))
  //   alias A = Obj.Left.Left;
  //   alias B = Obj.Left.Right;
  //   alias C = Obj.Right.Left;
  //   alias D = Obj.Right.Right;

  //   alias AC = ReturnType!(Product.opCall!(A, C));
  //   alias BD = ReturnType!(Product.opCall!(A, C));

  //   alias Source = Obj;
  //   alias Target = ReturnType!(Sum.opCall!(MorphF.Source, MorphG.Source));

  // }

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "⊗") {

    return allSatisfy!(is_morphism, Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "⊗" && is_morphism_op_valid!("⊗", Morph)) {

    alias Category = Vec!(double);
    alias Source = ReturnType!(Product.opCall!(staticMap!(SourceOf, Morph)));
    alias Target = ReturnType!(Product.opCall!(staticMap!(TargetOf, Morph)));
    alias Arg = Morph;

    Morph morph;

    this(Morph _morph) {
      morph = _morph;
      f = _morph[0];
      g = _morph[1];
    }

    Source source() {
      const int N = Morph.length;
      return mixin("Product(", expand!(N, "morph[I].source()"), ")");
    }

    Target target() {
      const int N = Morph.length;
      return mixin("Product(", expand!(N, "morph[I].target()"), ")");
    }

    auto arg(int I)() {
      return morph[I];
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      const int N = Morph.length;
      return mixin("Vec!(Scalar).make_sum_element(", expand!(N, "morph[I](x[I])"), ")");
    }

    auto tangent_map() {
      const int N = Morph.length;
      // define transpose, i.e. (X1⊗Y1)⊗...⊗(XN⊗YN) ~ (X1⊗...⊗XN)⊗(Y1⊗...⊗YN)
      // return compose(transpose, mixin("Product.fmap(", expand!(N,
      //     "TangentMap.fmap(morph[I])"), ")"), transpose);
      return mixin("Product.fmap(", expand!(N, "TangentMap.fmap(morph[I])"), ")");
    }
  }

  //  _____                       _     __  __
  // |_   _|_ _ _ _  __ _ ___ _ _| |_  |  \/  |__ _ _ __
  //   | |/ _` | ' \/ _` / -_) ' \  _| | |\/| / _` | '_ \
  //   |_|\__,_|_||_\__, \___|_||_\__| |_|  |_\__,_| .__/
  //                |___/                          |_|

  // Functor 

  immutable struct TangentMap {

    alias Source = Diff!(Scalar);
    alias Target = Diff!(Scalar);

    static auto opCall(Obj...)(Obj obj) if (is_object_op_valid!("T", Obj)) {
      return Product(obj, obj);
    }

    static auto fmap(Morph...)(Morph morph) if (is_morphism_op_valid!("T", Morph)) {

      // If the morphism is a linear map, then its tangent map is just a product with it self
      static if (Vec!(Scalar).is_morphism!(Morph)) {
        return Product.fmap(morph, morph);
      }
      // Otherwise the morphism has to implent its own version of `tangent_map`
      else {
        static assert(__traits(hasMember, Morph, "tangent_map"),
            "The morphism does not implement `tangent_map`!");
        return morph.tangent_map();
      }
    }
  }

  static bool is_object_op_valid(string op, Obj...)() if (op == "T") {
    return Obj.length == 1 && allSatisfy!(is_object, Obj);
  }

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "T") {
    return Morph.length == 1 && allSatisfy!(is_morphism, Morph);
  }

  //   ___                  _
  //  / __|  _ _ _ _ _ _  _(_)_ _  __ _
  // | (_| || | '_| '_| || | | ' \/ _` |
  //  \___\_,_|_| |_|  \_, |_|_||_\__, |
  //                   |__/       |___/

  // Curry a function

  immutable struct Isomorphism(SourceExpr, TargetExpr)
      if (SourceExpr == "((X⊗Y)→Z)" && TargetExpr == "(X→(Y→Z))") {

    bool isValid(Obj)() {

    }

    immutable struct CurriedCall(Morph, X) {

      Morph morph;
      X x;

      this(Morph _morph, X _x) {
        morph = _morph;
        x = _x;
      }

      auto opCall(Y)(Y y) {
        return morph(Vec!(Scalar).make_sum_element(x, y));
      }
    }

    immutable struct Curry(Morph) {
      // Maybe this should be an operation "λ"

      Morph morph;

      this(Morph _morph) {
        morph = _morph;
      }

      auto opCall(X)(X x) {

        auto objY = morph.target().arg(0);
        auto objZ = morph.target().arg(1);
        return morphism(objY, objZ, CurryCall!(Morph, X)(morph, x));
      }
    }

    immutable struct Impl {

      auto opCall(Morph)(Morph morph) {
        // f : ((X⊗Y)→Z)
        // f.source() == (X⊗Y)
        // f.source().projection(0) : (X⊗Y)→X
        // f.source().projection(0).target() == X
        auto objX = morph.source().arg(0); // maybe: morph.source().projection(0).target()
        auto objY = morph.source().arg(1); // maybe: morph.source().projection(1).target()
        auto objZ = morph.target();
        return morphism(objX, Hom(objY, objZ), Curry!(Morph)(morph));
      }

      auto tangent_map() {
        // ???? WTF this should be?
      }
    }

    // Given an object of the form "((X⊗Y)→Z)" spit out an morhism from "((X⊗Y)→Z)" to "(X→(Y→Z))" which is isomorphism!
    auto opCall(Obj)(Obj obj) {

      auto objX = obj.arg(0).arg(0);
      auto objY = obj.arg(0).arg(1);
      auto objZ = obj.arg(1);

      return morphism(objX, Hom(objY, objZ), Impl.init);
    }
  }

  // |
  // ⊗
  // T

  // mayber `curry` or does this come from somewhere else? Currying is probably natural if one has tensor products, there fore it should follow from the tensor product
}
