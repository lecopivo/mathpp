//  ___      _
// / __| ___| |_
// \__ \/ -_)  _|
// |___/\___|\__|

immutable struct Set {
  import base;
  import cat;

  //  ___       ___  _     _        _
  // |_ _|___  / _ \| |__ (_)___ __| |_
  //  | |(_-< | (_) | '_ \| / -_) _|  _|
  // |___/__/  \___/|_.__// \___\__|\__|
  //                    |__/

  static bool is_object_impl(Obj, bool fail_if_false = false)() {
    import std.traits;

    const bool is_Cat_object = Cat.is_object_impl!(Obj, fail_if_false);

    // Check if the function is static and accepts no arguments
    const bool defines__is_element = std.traits.hasMember!(Obj, "is_element");

    bool result = is_Cat_object && defines__is_element;
    static if (is_Cat_object) {
      result &= is_sub_category!(Obj.Category, Set, fail_if_false);
    }

    static if (fail_if_false) {
      import std.format;

      static assert(defines__is_element,
          format!("The object of type `%s` does not define `is_element`!")(
            std.traits.fullyQualifiedName!Obj));
      static assert(is_sub_category!(Obj.Category, Set), format!(
          "The object of type `%s` defines a category of type %s that is however is not a subcategory of `Set`!")(
          std.traits.fullyQualifiedName!Obj, std.traits.fullyQualifiedName!Obj.Category));
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

    const bool is_Cat_morphism = Cat.is_morphism_impl!(Morph, fail_if_false);
    const bool is_function = true; // I do not know how to test this :( 
    // Neither of the two following work 
    // std.traits.isFunction!(Morph); 
    // is(Morph == function)

    bool result = is_Cat_morphism && is_function;
    static if (is_Cat_morphism) {
      result &= is_object!(Morph.Source, fail_if_false);
      result &= is_object!(Morph.Target, fail_if_false);
    }

    static if (fail_if_false) {
      import std.format;

      static assert(is_function,
          format!"The morphism of type `%s` is not a callable function!"(
            std.traits.fullyQualifiedName!Morph));
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

    alias Category = Cat;
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

  immutable struct Identity(Obj) {

    alias Category = Cat;
    alias Source = Obj;
    alias Target = Obj;

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

    Obj obj;
  }

  static auto identity(Obj)(Obj obj) if (is_object_impl!(Obj)) {
    return make_morphism(Identity!(Obj)(obj));
  }

  //  _    ___                        _ _   _
  // | |  / __|___ _ __  _ __  ___ __(_) |_(_)___ _ _
  // | | | (__/ _ \ '  \| '_ \/ _ (_-< |  _| / _ \ ' \
  // | |  \___\___/_|_|_| .__/\___/__/_|\__|_\___/_||_|
  // |_|                |_|

  static bool is_morphism_op_valid(string op, Morph...)() if (op == "⚪") {
    import checks;

    return are_composable!(Cat, Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "⚪" && is_morphism_op_valid!(op, Morph)) {

    this(Morph _morph) {
      morph = _morph;
    }

    alias Category = Set;
    alias Source = Morph[$ - 1].Source;
    alias Target = Morph[0].Target;

    Source source() {
      return morph[$ - 1].source();
    }

    Target target() {
      return morph[0].target();
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

  static auto op(string op, Morph...)(Morph morph)
      if (is_morphism_op_valid!("⚪", Morph)) {
    return make_morphism(MorphismOp!("⚪", Morph)(morph));
  }

  static auto compose(Morph...)(Morph morph)
      if (is_morphism_op_valid!("⚪", Morph)) {
    return op!("⚪")(morph);
  }

}

// Things that should pass
unittest {

  import base;
  import checks;

  immutable struct TypeObject(T) {
    alias Category = Set;

    static bool is_element(Elem)() {
      return is(Elem == T);
    }
  }

  // test objects

  auto objInt = make_object(TypeObject!(int)());
  auto objDouble = make_object(TypeObject!(double)());
  auto objString = make_object(TypeObject!(string)());

  alias ObjInt = typeof(objInt);
  alias ObjDouble = typeof(objDouble);
  alias ObjString = typeof(objString);

  static assert(Set.is_object!(ObjInt));
  static assert(Set.is_object_impl!(ObjInt));
  static assert(!Set.is_object!(TypeObject!(int)));

  // test identity

  auto id_int = Set.identity(objInt);
  alias IdInt = typeof(id_int);

  static assert(Set.is_morphism!(IdInt));
  static assert(Set.is_morphism_impl!(Set.Identity!(ObjInt)));
  static assert(!Set.is_morphism!(Set.Identity!(ObjInt)));

  import std.math;
  import std.conv;

  auto m1 = Set.morphism!(x => sqrt(cast(double) x))(objInt, objDouble);
  auto m2 = Set.morphism!(x => to!string(x))(objDouble, objString);

  alias M1 = typeof(m1);
  alias M2 = typeof(m2);

  static assert(Set.is_morphism!(M1));
  static assert(Set.is_morphism!(M2));

  import std.math;

  static assert(abs(m1(2) - 1.41421) < 1e-4);
  assert(m2(3.1415) == "3.1415");

  // test composition

  static assert(are_composable!(Set, IdInt, IdInt, IdInt, IdInt, IdInt));
  static assert(are_composable!(Set, M2, M1, IdInt));
  static assert(!are_composable!(Set, IdInt));
  static assert(!are_composable!(Set, M1, M2));

  auto cm1 = Set.compose(m2, m1);
  auto cm2 = Set.compose(Set.compose(m2, m1), id_int);
  auto cm3 = Set.compose(m2, Set.compose(m1, id_int));

  static assert(is_morphism!(typeof(cm1)));
  static assert(is_morphism!(typeof(cm2)));
  static assert(is_morphism!(typeof(cm3)));
}

// Things that should fail
