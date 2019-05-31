//   ___      _
//  / __|__ _| |_
// | (__/ _` |  _|
//  \___\__,_|\__|

immutable struct Cat {

  import base;

  //  ___       ___  _     _        _
  // |_ _|___  / _ \| |__ (_)___ __| |_
  //  | |(_-< | (_) | '_ \| / -_) _|  _|
  // |___/__/  \___/|_.__// \___\__|\__|
  //                    |__/

  static bool is_object_impl(Obj, bool fail_if_false = false)() {
    import std.traits;

    const bool defines__Category = is(Obj.Category);
    const bool is_immutable = is(ImmutableOf!(Obj) == Obj);

    bool result = true;
    result &= defines__Category && is_immutable;

    static if (defines__Category) {
      result &= is_category!(Obj.Category);
      result &= is_sub_category!(Obj.Category, Cat);
    }

    static if (fail_if_false) {
      import std.format;

      static assert(defines__Category,
          format!("The object of type `%s` does not define `alias Category`!")(
            std.traits.fullyQualifiedName!Obj));
      static assert(is_category!(Obj.Category),
          format!"The object of type `%s` defines an invalid Category of type `%s`!"(
            std.traits.fullyQualifiedName!(Obj), std.traits.fullyQualifiedName!(Obj.Category)));
      static assert(is_immutable,
          format!"The object of type `%s` is not immutable! All types representing objects have to be immutable."(
            std.traits.fullyQualifiedName!(Obj)));
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

    const bool defines__Category = is(Morph.Category);
    const bool defines__Source = is(Morph.Source);
    const bool defines__Target = is(Morph.Target);
    const bool defines__source = std.traits.hasMember!(Morph, "source");
    const bool defines__target = std.traits.hasMember!(Morph, "target");
    /* Probably also check that source is of type Source and target of type Target */

    bool result = defines__Category && defines__Source && defines__Target;

    static if (defines__Category)
      result &= is_category!(Morph.Category);
    static if (defines__Source)
      result &= is_object_impl!(Morph.Source);
    static if (defines__Target)
      result &= is_object_impl!(Morph.Target);

    static if (fail_if_false) {
      import std.format;

      static assert(defines__Category,
          format!"The morphism of type `%s` does not define `alias Category`!"(
            std.traits.fullyQualifiedName!Morph));
      static assert(defines__Source,
          format!"The morphism of type `%s` does not define `alias Source`!"(
            std.traits.fullyQualifiedName!Morph));
      static assert(defines__Target,
          format!"The morphism of type `%s` does not define `alias Target`!"(
            std.traits.fullyQualifiedName!Morph));

      static assert(is_category!(Morph.Category),
          "The morphism of type `%s` defines an invalid Category of type `%s`!"(
            std.traits.fullyQualifiedName!Morph, std.traits.fullyQualifiedName!Morph.Category));
      static assert(is_object_impl!(Morph.Source), "The morphism of type `%s` defines an invalid Source of type `%s`!"(
          std.traits.fullyQualifiedName!Morph, std.traits.fullyQualifiedName!Morph.Source));
      static assert(is_object_impl!(Morph.Target), "The morphism of type `%s` defines an invalid Target of type `%s`!"(
          std.traits.fullyQualifiedName!Morph, std.traits.fullyQualifiedName!Morph.Target));

      static assert(defines__source,
          format!"The morphism of type `%s` does not have member `source`!"(
            std.traits.fullyQualifiedName!Morph));
      static assert(defines__target,
          format!"The morphism of type `%s` does not have member `target`!"(
            std.traits.fullyQualifiedName!Morph));
    }

    return result;
  }

  static bool is_morphism(Morph, bool fail_if_false = false)() {
    import base;

    return is_morphism_impl!(Morph, fail_if_false) && is(Morph : Morphism!(Impl), Impl);
  }

  //  __  __              _    _
  // |  \/  |___ _ _ _ __| |_ (_)____ __
  // | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  // |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                |_|

  immutable struct MorphismImpl(Src, Trg) {

    alias Category = Cat;
    alias Source = Src;
    alias Target = Trg;

    Source src;
    Target trg;

    Source source() {
      return src;
    }

    Target target() {
      return trg;
    }
  }

  static auto morphism(Src, Trg)(Src src, Trg trg) {
    return make_morphism(MorphismImpl!(Src, Trg)(src, trg));
  }

  //  ___    _         _   _ _
  // |_ _|__| |___ _ _| |_(_) |_ _  _
  //  | |/ _` / -_) ' \  _| |  _| || |
  // |___\__,_\___|_||_\__|_|\__|\_, |
  //                             |__/

  immutable struct Identity(Obj) {

    this(Obj _obj) {
      obj = _obj;
    }

    alias Category = Cat;
    alias Source = Obj;
    alias Target = Obj;

    Source source() {
      return obj;
    }

    Target target() {
      return obj;
    }

    Obj obj;
  }

  static auto identity(Obj)(Obj obj) if (is_object!(Obj)) {
    return make_morphism(Identity!(Obj)(obj));
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

    return are_composable!(Cat, Morph);
  }

  immutable struct MorphismOp(string op, Morph...)
      if (op == "∘" && is_morphism_op_valid!(op, Morph)) {

    alias Category = Cat;
    alias Source = Morph[$ - 1].Source;
    alias Target = Morph[0].Target;
    alias Arg = Morph;

    Morph morph;

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
  }
}

// Things that should pass
unittest {

  import base;
  import checks;

  immutable struct A {
    alias Category = Cat;
  }

  immutable struct B {
    alias Category = Cat;
  }

  immutable struct C {
    alias Category = Cat;
  }

  // test objects

  auto a = make_object(A());
  auto b = make_object(B());
  auto c = make_object(C());

  alias ObjA = typeof(a);
  alias ObjB = typeof(b);
  alias ObjC = typeof(c);

  static assert(Cat.is_object!(ObjA));
  static assert(Cat.is_object_impl!(A));
  static assert(!Cat.is_object!(A));

  // test identity

  auto id_a = Cat.identity(a);
  alias IdA = typeof(id_a);

  static assert(Cat.is_morphism!(IdA));
  static assert(Cat.is_morphism_impl!(Cat.Identity!(A)));
  static assert(!Cat.is_morphism!(Cat.Identity!(A)));

  // test morphism

  auto m1 = Cat.morphism(a, b);
  auto m2 = Cat.morphism(b, c);

  alias M1 = typeof(m1);
  alias M2 = typeof(m2);

  static assert(Cat.is_morphism!(M1));
  static assert(Cat.is_morphism!(M2));

  // test composition

  static assert(are_composable!(Cat, IdA, IdA, IdA, IdA, IdA));
  static assert(are_composable!(Cat, M2, M1, IdA));
  static assert(!are_composable!(Cat, IdA));
  static assert(!are_composable!(Cat, M1, M2));

  auto cm1 = Cat.compose(m2, m1);
  auto cm2 = Cat.compose(Cat.compose(m2, m1), id_a);
  auto cm3 = Cat.compose(m2, Cat.compose(m1, id_a));

  static assert(is_morphism!(typeof(cm1)));
  static assert(is_morphism!(typeof(cm2)));
  static assert(is_morphism!(typeof(cm3)));
}

// Things that should fail
