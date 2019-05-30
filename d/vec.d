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

  //  ___    _         _   _ _
  // |_ _|__| |___ _ _| |_(_) |_ _  _
  //  | |/ _` / -_) ' \  _| |  _| || |
  // |___\__,_\___|_||_\__|_|\__|\_, |
  //                             |__/

  immutable struct Identity(Obj) if (is_object!(Obj)) {

    this(Obj _obj) {
      obj = _obj;
    }

    alias Category = Vec;
    alias Source = Obj;
    alias Target = Obj;

    Source source() {
      return obj;
    }

    Target target() {
      return obj;
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return x;
    }

    static string symbol() {
      return "1";
    }

    Obj obj;
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

    static string symbol() {
      return "0";
    }

    alias Category = Vec!(Scalar);
    alias Source = Src;
    alias Target = Trg;

    Source src;
    Target trg;
  }

  static auto zero_morphism(Src, Trg)(Src src, Trg trg) {
    return make_morphism(ZeroMorphism!(Src, Trg)(src, trg));
  }

  //   ___                     _   _
  //  / _ \ _ __  ___ _ _ __ _| |_(_)___ _ _  ___
  // | (_) | '_ \/ -_) '_/ _` |  _| / _ \ ' \(_-<
  //  \___/| .__/\___|_| \__,_|\__|_\___/_||_/__/
  //       |_|

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

    F f;
    G g;
  }

  //    _             _      _    _ _ _   _
  //  _| |_   ___    /_\  __| |__| (_) |_(_)___ _ _
  // |_   _| |___|  / _ \/ _` / _` | |  _| / _ \ ' \
  //   |_|         /_/ \_\__,_\__,_|_|\__|_\___/_||_|

  static bool is_morphism_op_valid(string op, F, G)() if (op == "+" || op == "-") {
    return is_morphism!(F) && is_morphism!(G) && is(F.Source == G.Source) && is(F.Target == G
        .Target);
  }

  immutable struct MorphismOp(string op, F, G)
      if ((op == "+" && is_morphism_op_valid!("+", F, G)) || (op == "-"
        && is_morphism_op_valid!("-", F, G))) {
    this(F _f, G _g) {
      f = _f;
      g = _g;
    }

    alias Category = Vec;
    alias Source = F.Source;
    alias Target = F.Target;

    Source source() {
      return f.source();
    }

    Target target() {
      return f.target();
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      static if (op == "+") /* addition */ {
          return f(x) + g(x);
        }
      else {
        return f(x) - g(x);
      }
    }

    F f;
    G g;
  }

  //      ___          _            ___             _         _
  //     / __| __ __ _| |__ _ _ _  | _ \_ _ ___  __| |_  _ __| |_
  //  _  \__ \/ _/ _` | / _` | '_| |  _/ '_/ _ \/ _` | || / _|  _|
  // (_) |___/\__\__,_|_\__,_|_|   |_| |_| \___/\__,_|\_,_\__|\__|

  static bool is_morphism_op_valid(string op, F, G)() if (op == "·") {
    return (is_morphism!(F) && is(G == Scalar)) || (is(F == Scalar) && is_morphism!(G));
  }

  immutable struct MorphismOp(string op, F, G)
      if (op == "·" && is_morphism_op_valid!("·", F, G)) {
    this(F _f, G _g) {
      f = _f;
      g = _g;
    }

    alias Category = Vec;
    static if (is(G == Scalar)) {
      alias Source = F.Source;
      alias Target = F.Target;
    }
    else {
      alias Source = G.Source;
      alias Target = G.Target;
    }

    Source source() {
      static if (is(G == Scalar)) {
        return f.source();
      }
      else {
        return g.source();
      }
    }

    Target target() {
      static if (is(G == Scalar)) {
        return f.target();
      }
      else {
        return g.target();
      }
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      static if (is(G == Scalar)) {
        return f(x) * g;
      }
      else {
        return g * f(x);
      }
    }

    F f;
    G g;
  }

  //  _  _           ___      _
  // | || |___ _ __ / __| ___| |_
  // | __ / _ \ '  \\__ \/ -_)  _|
  // |_||_\___/_|_|_|___/\___|\__|

  static bool is_object_op_valid(string op, ObjX, ObjY)() if (op == "→") {
    return is_object!(ObjX) && is_object!(ObjY);
  }

  immutable struct ObjectOp(string op, ObjX, ObjY)
      if (op == "→" && is_object_op_valid!("→", ObjX, ObjY)) {

    this(ObjX _objx, ObjY _objy) {
      objx = _objx;
      objy = _objy;
    }

    static bool is_element(Elem)() {
      return is_morphism!(Elem) && is(Elem.Source == ObjX) && is(Elem.Target == ObjY);
    }

    auto zero() {
      return zero_morphism(objx, objy);
    }

    // auto symbol(){
    //   return "Hom(" ~ objx.symbol() ~ "," ~ objy.symbol() ~ ")";
    // }

    alias Category = Vec;
    alias Source = ObjX;
    alias Target = ObjY;

    Source source() {
      return objx;
    }

    Target target() {
      return objy;
    }

    ObjX objx;
    ObjY objy;
  }

  // Hom Functor 
  immutable struct Hom {

    alias Source = Vec!(Scalar);
    alias Target = Vec!(Scalar);

    static immutable is_bifunctor = true;

    static auto opCall(X, Y)(X x, Y y)
        if ((is_object!(X) && (is_object!(Y) || is(Y == string)))
          || ((is_object!(X) || is(X == string)) && is_object!(Y))) {
      // We call the bifunctor with two objects
      static if (is_object!(X) && is_object!(Y)) {
        // Return HomSet
        return make_object(ObjectOp!("→", X, Y)(x, y));
      }
      else {
        static assert("Functors Hom[-,Y] and Hom[X,-] need implementation");
      }
    }

    static auto fmap(MorphF, MorphG)(MorphF f, MorphG g) {

      auto source = this(f.target(), g.source());
      auto target = this(f.source(), g.target());

      struct sandwich {
        this(MorphF _f, MorphG _g) {
          f = _f;
          g = _g;
        }

        auto opCall(X)(X x) {
          return compose(f, compose(x, g));
        }

        MorphF f;
        MorphG g;
      }

      return make_vec_morphism(source, target, sandwich(f, g));
    }
  }

  //  ___  _            _     ___
  // |   \(_)_ _ ___ __| |_  / __|_  _ _ __
  // | |) | | '_/ -_) _|  _| \__ \ || | '  \
  // |___/|_|_| \___\__|\__| |___/\_,_|_|_|_|

  static bool is_object_op_valid(string op, X, Y)() if (op == "⊕") {
    return is_object!(X) && is_object!(Y);
  }

  static bool is_morphism_op_valid(string op, F, G)() if (op == "⊕") {
    return is_morphism!(F) && is_morphism!(G);
  }

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

  struct Pair(X, Y) {

    this(X _x, Y _y) {
      x = _x;
      y = _y;
    }

    auto opBinary(string op, RX, RY)(SumElement!(RX, RY) rhs) const 
        if (op == "+" || op == "-") {
      mixing("return make_pair(x" ~ op ~ "rhs.x, y" ~ op ~ "rhs.y);");
    }

    auto opBinary(string op)(Scalar s) const if (op == "*") {
      return make_pair(s * x, s * y);
    }

    auto opBinaryRight(string op)(Scalar s) if (op == "*") {
      return make_pair(s * x, s * y);
    }

    X x;
    Y y;
  }

  static Pair!(X, Y) make_pair(X, Y)(X x, Y y) {
    return Pair!(X, Y)(x, y);
  }

  // Object Operation

  immutable struct ObjectOp(string op, ObjX, ObjY)
      if (op == "⊕" && is_object_op_valid!("⊕", ObjX, ObjY)) {

    this(ObjX _objx, ObjY _objy) {
      objx = _objx;
      objy = _objy;
    }

    static bool is_element(Obj)() {
      return false;
    }

    static bool is_element(Obj : Pair!(X, Y), X, Y)() {
      return ObjX.is_element!(X) && ObjY.is_element!(Y);
    }

    auto zero() {
      return make_pair(objx.zero(), objy.zero());
    }

    alias Category = Vec;
    alias Left = ObjX;
    alias Right = ObjY;

    ObjX objx;
    ObjY objy;
  }

  // Morphism Operation

  immutable struct MorphismOp(string op, MorphF, MorphG)
      if (op == "⊕" && is_morphism_op_valid!("⊕", MorphF, MorphG)) {
    this(MorphF _f, MorphG _g) {
      f = _f;
      g = _g;
    }

    import std.traits;

    alias Category = Vec;
    alias Source = ReturnType!(Sum.opCall!(MorphF.Source, MorphG.Source));
    alias Target = ReturnType!(Sum.opCall!(MorphF.Target, MorphG.Target));

    Source source() {
      return Sum(f.source(), g.source());
    }

    Target target() {
      return Sum(f.target(), g.target());
    }

    auto opCall(X)(X x) if (Source.is_element!(X)) {
      return make_pair(f(x.x), g(x.y));
    }

    MorphF f;
    MorphG g;
  }

  static auto operation(string op, MorphF, MorphG)(MorphF f, MorphG g)
      if (is_morphism_op_valid!(op, MorphF, MorphG)) {
    return make_morphism(MorphismOp!(op, MorphF, MorphG)(f, g));
  }
}
