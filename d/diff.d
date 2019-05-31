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

    // auto tangent_map(this T)() {
    //    return Product(make_morphism(this), Vec!(Scalar).zero_morphism(src, trg));
    // }
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
    }

    auto tangent_map() {
      //  m[0].tangent_map() | ... | m[$-1].tangetn_map()
      return compose(myMap!(m => m.tangetn_map())(morph));
    }
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
      return Product(morph[0].source(), morph[1].source());
    }

    Target target() {
      return Product(morph[0].target(), morph[1].target());
    }

    auto arg(int I)() {
      return morph[I];
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) 
    {
      /* Do a test that g(x) is element of F.Source and that f(g(x)) is element of Target */
      return Vec!(Scalar).make_pair(f(x.x), g(x.y));
    }

    auto tangent_map() {
      return 0; //TangentMap(f), TangentMap(g));
    }
  }

  // |
  // ⊗
  // T

  // mayber `curry` or does this come from somewhere else? Currying is probably natural if one has tensor products, there fore it should follow from the tensor product
}
