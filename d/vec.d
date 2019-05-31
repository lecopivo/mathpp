// __   __
// \ \ / /__ __
//  \ V / -_) _|
//   \_/\___\__|

immutable struct Vec(Scalar) {

  import base;

  //  ___       ___  _     _        _
  // |_ _|___  / _ \| |__ (_)___ __| |_
  //  | |(_-< | (_) | '_ \| / -_) _|  _|
  // |___/__/  \___/|_.__// \___\__|\__|
  //                    |__/

  static bool is_object_impl(Obj, bool fail_if_false = false)() {
    import std.traits;
    import set;

    const bool is_Set_object = Set.is_object_impl!(Obj, fail_if_false);
    const bool defines__zero = std.traits.hasMember!(Obj, "zero");
    //const bool defines__is_zero = std.traits.hasMember(Obj, "is_zero");

    bool result = is_Set_object && defines__zero;
    static if (is_Set_object) {
      result &= is_sub_category!(Obj.Category, Vec, fail_if_false);
    }

    static if (fail_if_false) {
      import std.format;

      static assert(defines__zero,
          format!("The object of type `%s` does not define `zero()`!")(
            std.traits.fullyQualifiedName!Obj));
    }

    return result;
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
    import set;

    const bool is_Set_morphism = Set.is_morphism_impl!(Morph, fail_if_false);

    bool result = is_Set_morphism;
    static if (is_Set_morphism) {
      result &= is_object!(Morph.Source, fail_if_false);
      result &= is_object!(Morph.Target, fail_if_false);
    }

    return result;
  }

  static bool is_morphism(Morph, bool fail_if_false = false)() {
    return is_morphism_impl!(Morph, fail_if_false) && is(Morph : Morphism!(Impl), Impl);
  }

  //  __  __              _    _
  // |  \/  |___ _ _ _ __| |_ (_)____ __
  // | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  // |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                |_|

  immutable struct MorphismImpl(Src, Trg, Fun) {

    alias Category = Vec!(Scalar);
    alias Source = Src;
    alias Target = Trg;
    alias fun this;

    Source src;
    Target trg;
    Fun fun;

    this(Source _src, Target _trg, Fun _fun) {
      src = _src;
      trg = _trg;
      fun = _fun;
    }

    Source source() {
      return src;
    }

    Target target() {
      return trg;
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      import std.traits;

      static assert(Target.is_element!(ReturnType!(Fun.opCall!(X))),
          "Invalid implementation of morphism! The return value is not an element of Target set");

      return fun(x);
    }
  }

  static auto morphism(Src, Trg, Fun)(Src src, Trg trg, Fun fun) {
    return make_morphism(MorphismImpl!(Src, Trg, Fun)(src, trg, fun));
  }

  static auto morphism(alias Lambda, Src, Trg)(Src src, Trg trg) {
    return morphism(src, trg, FunctionObject!(Lambda).init);
  }

  //  ___    _         _   _ _
  // |_ _|__| |___ _ _| |_(_) |_ _  _
  //  | |/ _` / -_) ' \  _| |  _| || |
  // |___\__,_\___|_||_\__|_|\__|\_, |
  //                             |__/

  immutable struct Identity(Obj) if (is_object!(Obj)) {

    alias Category = Vec!(Scalar);
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

  static auto identity(Obj)(Obj obj) if (is_object_impl!(Obj)) {
    return Morphism!(Identity!(Obj))(Identity!(Obj)(obj));
  }

  //  ____              __  __              _    _
  // |_  /___ _ _ ___  |  \/  |___ _ _ _ __| |_ (_)____ __
  //  / // -_) '_/ _ \ | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  // /___\___|_| \___/ |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                                  |_|

  immutable struct ZeroMorphism(Src, Trg) {

    alias Category = Vec!(Scalar);
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

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return trg.zero();
    }

  }

  static auto zero_morphism(Src, Trg)(Src src, Trg trg) {
    return make_morphism(ZeroMorphism!(Src, Trg)(src, trg));
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
  
  // static bool is_morhism_op_valid(string op, F, G)()
  // {
  //   return false;
  // }

  // static bool is_object_op_valid(string op, X, Y)()
  // {
  //   return false;
  // }

  //  _    ___                        _ _   _
  // | |  / __|___ _ __  _ __  ___ __(_) |_(_)___ _ _
  // | | | (__/ _ \ '  \| '_ \/ _ (_-< |  _| / _ \ ' \
  // | |  \___\___/_|_|_| .__/\___/__/_|\__|_\___/_||_|
  // |_|                |_|

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "∘") {
    import checks;

    return are_composable!(Vec!Scalar, Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "∘" && is_morphism_op_valid!(op, Morph)) {

    this(Morph _morph) {
      morph = _morph;
    }

    alias Category = Vec!(Scalar);
    alias Source = Morph[$ - 1].Source;
    alias Target = Morph[0].Target;
    alias Arg(int I) = Morph[I];

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

    Morph morph;
  }

  //    _             _      _    _ _ _   _
  //  _| |_   ___    /_\  __| |__| (_) |_(_)___ _ _
  // |_   _| |___|  / _ \/ _` / _` | |  _| / _ \ ' \
  //   |_|         /_/ \_\__,_\__,_|_|\__|_\___/_||_|

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "+") {
    import std.meta;
    import checks;

    alias V = Vec!(Scalar);
    return has_same_source!(V, Morph) && has_same_target!(V, Morph) && Morph.length >= 2;
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "+" && is_morphism_op_valid!("+", Morph)) {

    alias Category = Vec;
    alias Source = Morph[0].Source;
    alias Target = Morph[0].Target;
    alias Arg(int I) = Morph[I];

    Morph morph;

    this(Morph _morph) {
      morph = _morph;
    }

    Source source() {
      return morph[0].source();
    }

    Target target() {
      return morph[0].target();
    }

    auto arg(int I)() {
      return morph[I];
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {

      auto call(int I, Y)(Y partialSum) {
        static if (I < Morph.length) {
          import std.conv;

          mixin("return call!(" ~ to!string(I + 1) ~ ")(partialSum" ~ op ~ "morph[I](x));");
        }
        else {
          return partialSum;
        }
      }

      return call!(0)(source().zero());
    }
  }

  //      ___          _            ___             _         _
  //     / __| __ __ _| |__ _ _ _  | _ \_ _ ___  __| |_  _ __| |_
  //  _  \__ \/ _/ _` | / _` | '_| |  _/ '_/ _ \/ _` | || / _|  _|
  // (_) |___/\__\__,_|_\__,_|_|   |_| |_| \___/\__,_|\_,_\__|\__|

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "·") {
    static if (Morph.length == 2)
      return ((is_morphism!(Morph[0]) && is(Morph[1] == Scalar))
          || (is_morphism!(Morph[1]) && is(Morph[0] == Scalar)));
    else
      return false;
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "·" && is_morphism_op_valid!("·", Morph)) {
    this(Morph _morph) {
      morph = _morph;
    }

    alias Category = Vec;
    static foreach (M; Morph) {
      static if (!is(M == Scalar)) {
        alias Source = M.Source;
        alias Target = M.Target;
      }
    }
    alias Arg(int I) = Morph[I];

    Morph morph;

    Source source() {
      static foreach (I, M; Morph) {
        static if (!is(M == Scalar)) {
          return morph[I].source();
        }
      }
    }

    Target target() {
      static foreach (I, M; Morph) {
        static if (!is(M == Scalar)) {
          return morph[I].target();
        }
      }
    }

    auto arg(int I)() {
      return morph[I];
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      static if (is(M[0] == Scalar)) {
        return morph[0] * morph[1](x);
      }
      else {
        return morph[0](x) * morph[1];
      }
    }
  }

  //  _  _           ___      _
  // | || |___ _ __ / __| ___| |_
  // | __ / _ \ '  \\__ \/ -_)  _|
  // |_||_\___/_|_|_|___/\___|\__|

  // Hom Functor 
  immutable struct Hom {

    alias Source = Vec!(Scalar);
    alias Target = Vec!(Scalar);

    static auto opCall(X, Y)(X x, Y y) if (is_object!(X) && is_object!(X)) {
      return make_object(ObjectOp!("→", X, Y)(x, y));
    }

    static auto fmap(MorphF, MorphG)(MorphF f, MorphG g) {

      auto source = this(f.target(), g.source());
      auto target = this(f.source(), g.target());

      return morphism!(h => compose(f, h, g))(source, target, sandwich(f, g));
    }
  }

  // static bool is_morphism_op_valid(string op, Morph...)() if (op == "→") {
  //   static if (Morph.length == 2) {
  //     import std.meta;

  //     return allSatisfy!(is_morphism, Morph) && is(Morph[1].Source == Morph[0].Target);
  //   }
  //   else {
  //     return false;
  //   }
  // }

  static bool is_object_op_valid(string op, Obj...)() if (op == "→") {
    static if (Obj.length == 2) {
      import std.meta;

      return allSatisfy!(is_object, Obj);
    }
    else {
      return false;
    }
  }

  immutable struct ObjectOp(string op, Obj...)
      if (op == "→" && is_object_op_valid!("→", Obj)) {

    alias Category = Vec;
    alias Source = Obj[0];
    alias Target = Obj[1];
    alias Arg(int I) = Obj[I];

    Obj obj;

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

    // auto symbol(){
    //   return "Hom(" ~ objx.symbol() ~ "," ~ objy.symbol() ~ ")";
    // }
  }

  //  ___  _            _     ___
  // |   \(_)_ _ ___ __| |_  / __|_  _ _ __
  // | |) | | '_/ -_) _|  _| \__ \ || | '  \
  // |___/|_|_| \___\__|\__| |___/\_,_|_|_|_|

  // Functor

  immutable struct Sum {

    alias Source = Vec!(Scalar);
    alias Target = Vec!(Scalar);

    static auto opCall(ObjX, ObjY)(ObjX objx, ObjY objy)
        if (is_object_op_valid!("⊕", ObjX, ObjY)) {
      return make_object(ObjectOp!("⊕", ObjX, ObjY)(objx, objy));
    }

    static auto fmap(MorphF, MorphG)(MorphF f, MorphG g)
        if (is_morphism_op_valid!("⊕", MorphF, MorphG)) {
      return make_morphism(MorphismOp!("⊕", MorphF, MorphG)(f, g));
    }
  }

  // Pair

  struct SumElement(X...) {

    X x;

    this(X _x) {
      x = _x;
    }

    auto opBinary(string op, Y...)(SumElement!(Y) y) const 
        if (op == "+" && X.length == Y.length) {

      string call_string() {

        string result = "return make_sum_element(";
        static foreach (I, Z; X) {
          result ~= "x[" ~ I ~ "]" ~ op ~ "y[" ~ I ~ "]";
          static if (I < X.length - 1)
            result ~= ",";
        }
        result ~= ");";
      }

      // return make_sum_element(x[0] + y[0], ...);
      mixing(call_string!());
    }

    auto opBinary(string op)(Scalar s) const if (op == "*") {
      string call_string() {

        string result = "return make_sum_element(";
        static foreach (I, Z; X) {
          result ~= "s * x[" ~ I ~ "]";
          static if (I < X.length - 1)
            result ~= ",";
        }
        result ~= ");";
      }

      mixin(call_string!());
    }

    auto opBinaryRight(string op)(Scalar s) if (op == "*") {
      return opBinary!(op)(s);
    }
  }

  static auto make_sum_element(X...)(X x) {
    return SumElement!(X)(x);
  }

  // Object Operation

  static bool is_object_op_valid(string op, Obj...)() if (op == "⊕") {
    import std.traits;

    return allSatisfy!(is_object, Obj) && Obj.length >= 2;
  }

  immutable struct ObjectOp(string op, Obj...)
      if (op == "⊕" && is_object_op_valid!("⊕", Obj)) {

    alias Category = Vec;
    alias Arg(int I) = Obj[I];

    Obj obj;

    this(Obj _obj) {
      obj = _obj;
    }

    auto arg(int I)() {
      return obj[I];
    }

    static bool is_element(Obj)() {
      return false;
    }

    auto zero() {
      return make_sum_element(myMap!(o => o.zero())(obj).expand);
    }

  }

  // Morphism Operation

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "⊕") {
    import std.traits;

    return allSatisfy!(is_morphism, Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "⊕" && is_morphism_op_valid!("⊕", Morph)) {

    import std.traits;
    import std.meta;

    alias Category = Vec;
    alias Source = ReturnType!(Sum.opCall!(staticMap!(SourceOf, Morph)));
    alias Target = ReturnType!(Sum.opCall!(staticMap!(TargetOf, Morph)));

    Morph morph;

    this(Morph _morph) {
      morph = _morph;
    }

    Source source() {
      // Sum(morph.source()...)
      return Sum(myMap!(m => m.source())(morph).expand);
    }

    Target target() {
      // Sum(morph.target()...)
      return Sum(myMap!(m => m.target())(morph).expand);
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return make_pair(f(x.x), g(x.y));
    }

  }

}
