immutable struct Diff(Scalar) {

  import base;
  import vec;

  //  ___       ___  _     _        _
  // |_ _|___  / _ \| |__ (_)___ __| |_
  //  | |(_-< | (_) | '_ \| / -_) _|  _|
  // |___/__/  \___/|_.__// \___\__|\__|
  //                    |__/

  static bool is_object_impl(Obj, bool fail_if_false = false)() {

    import std.traits;

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
    import std.traits;
    import vec;

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

    this(Src _src, Trg _trg, Val _val) {
      src = _src;
      trg = _trg;
      val = _val;
    }

    alias Category = Diff!(Vec!(Scalar));
    alias Source = Src;
    alias Target = Trg;

    Source source() {
      return src;
    }

    Target target() {
      return trg;
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return val;
    }

    // auto tangent_map() {
    //   return TensorProduct(make_morphism(this), Vec!(Scalar).zero_morphism(src, trg));
    // }

    Source src;
    Target trg;
    Val val;
  }

  static auto constant_morphism(Src, Trg, Val)(Src src, Trg trg, Val val) {
    return make_morphism(Constant!(Src, Trg, Val)(src, trg, val));
  }

  //   ___                     _   _
  //  / _ \ _ __  ___ _ _ __ _| |_(_)___ _ _  ___
  // | (_) | '_ \/ -_) '_/ _` |  _| / _ \ ' \(_-<
  //  \___/| .__/\___|_| \__,_|\__|_\___/_||_/__/
  //       |_|

  //  _    ___                        _ _   _
  // | |  / __|___ _ __  _ __  ___ __(_) |_(_)___ _ _
  // | | | (__/ _ \ '  \| '_ \/ _ (_-< |  _| / _ \ ' \
  // | |  \___\___/_|_|_| .__/\___/__/_|\__|_\___/_||_|
  // |_|                |_|

  static bool is_morphism_op_valid(string op, F, G)() if (op == "|") {
    return is_morphism!(F) && is_morphism!(G) && is(F.Source == G.Target);
  }

  immutable struct MorphismOp(string op, F, G)
      if (op == "|" && is_morphism_op_valid!("|", F, G)) {

    this(F _f, G _g) {
      f = _f;
      g = _g;
    }

    alias Category = Vec;
    alias Source = G.Source;
    alias Target = F.Target;

    Source source() {
      return g.source();
    }

    Target target() {
      return f.target();
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      /* Do a test that g(x) is element of F.Source and that f(g(x)) is element of Target */
      return f(g(x));
    }

    auto tangent_map() {
      return compose(TangentMap(f), TangentMap(g));
    }

    F f;
    G g;
  }

  //  _____                       ___             _         _
  // |_   _|__ _ _  ___ ___ _ _  | _ \_ _ ___  __| |_  _ __| |_
  //   | |/ -_) ' \(_-</ _ \ '_| |  _/ '_/ _ \/ _` | || / _|  _|
  //   |_|\___|_||_/__/\___/_|   |_| |_| \___/\__,_|\_,_\__|\__|

  static bool is_object_op_valid(string op, Obj...)()
      if (op == "⊗" && Obj.length == 2) {
    bool result = true;
    static foreach (i; 0 .. Obj.length)
      result &= is_object!(Obj[i]);
    return result;
  }

  static bool is_morphism_op_valid(string op, Morph...)()
      if (op == "⊗" && Morph.length == 2) {
    bool result = true;
    static foreach (i; 0 .. Morph.length)
      result &= is_morphism!(Morph[i]);
    return result;
  }

  // Functor

  immutable struct Product {

    // alias Source = Diff!(Vec!(Scalar));
    // alias Target = Diff!(Vec!(Scalar));

    static auto opCall(Obj...)(Obj obj) if (is_object_op_valid!("⊗", Obj)) {
      //      return Vec!(Scalar).Sum(obj);
      return make_object(ObjectOp!("⊗",Obj)(obj));
    }

    /**
     * Map generated by Product if understood as a multi-functor
     */
    static auto fmap(Morph...)(Morph morph) if (is_morphism_op_valid!("⊗", Morph)) {
      auto impl = MorphismOp!("⊗", Morph)(morph);
      return make_morphism(impl);
    }

  }

  immutable struct ObjectOp(string op, Obj...)
      if (op == "⊗" && is_object_op_valid!("⊗", Obj)) {

    this(Obj obj) {
      internal = Vec!(Scalar).Sum(obj);
    }

    alias Category = Diff!(Vec!(Scalar));
    alias Arg = Obj;
    alias internal this;

    auto arg(int I)() if(I<2){
      static if(I==0)
	return internal.objx;
      else
	return internal.objy;
    }

    Object!(Vec!(Scalar).ObjectOp!("⊕",Obj)) internal;
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

  immutable struct MorphismOp(string op, Morph...)
  //if (op == "⊗" && is_morphism_op_valid!("⊗", Morph))
  {
    import std.traits;

    this(Morph _morph) {
      morph = _morph;
      f = _morph[0];
      g = _morph[1];
    }

    alias Category = Vec!(double);
    alias Source = ReturnType!(Product.opCall!(Morph[0].Source,Morph[1].Source));
    alias Target = ReturnType!(Product.opCall!(Morph[0].Target,Morph[1].Target));
    alias Arg = Morph;

    Source source() {
      return Product(morph[0].source(), morph[1].source());
    }

    Target target() {
      return Product(morph[0].target(), morph[1].target());
    }

    auto arg(int I)(){
      return morph[I];
    }

    auto opCall(X)(X x) //if (Source.is_element!(X)) {
    {
      /* Do a test that g(x) is element of F.Source and that f(g(x)) is element of Target */
      return Vec!(Scalar).make_pair(f(x.x), g(x.y));
    }

    // auto tangent_map() {
    //   return compose(TangentMap(f), TangentMap(g));
    // }
    
    Morph morph;
    Morph[0] f;
    Morph[1] g;
  }

  // |
  // ⊗
  // T

  // mayber `curry` or does this come from somewhere else? Currying is probably natural if one has tensor products, there fore it should follow from the tensor product
}
