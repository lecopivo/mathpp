import std.stdio;
import std.traits;

bool is_category(C, bool fail_if_false = false)()
{
  /* Defines composition and identity morphism */

  const bool defines__is_object_impl = std.traits.hasMember!(C, "is_object_impl");
  const bool is_immutable = is(ImmutableOf!(C) == C);

  static if (fail_if_false)
  {
    import std.format;

    static assert(defines__is_object_impl,
        format!("The category of type `%s` does not define function `is_object_impl(Obj)()`!")(
          std.traits.fullyQualifiedName!(C)));
    static assert(is_immutable,
        format!("The category of type `%s` is not immutable!")(std.traits.fullyQualifiedName!(C)));
  }

  return defines__is_object_impl && is_immutable;
}

// Is D subcategory of C?
bool is_sub_category(D, C, bool fail_if_false = false)()
{
  // Do some proper checking of categories
  return is_category!(D, fail_if_false);
}

//  --------
bool is_functor();

immutable struct Object(Impl)
    if (is(Impl.Category) && is_category!(Impl.Category) && Impl.Category.is_object_impl!(Impl))
{
  this(Impl _impl)
  {
    impl = _impl;
  }

  alias impl this;

  Impl impl;
}

immutable struct Morphism(Impl)
    if (is(Impl.Category) && is_category!(Impl.Category) && Impl.Category.is_morphism_impl!(Impl))
{
  this(Impl _impl)
  {
    impl = _impl;
  }

  alias impl this;

  Impl impl;
}

bool is_object(Obj)()
{
  return is(Obj : Object!(Impl), Impl);
}

bool is_morphism(Morph)()
{
  return is(Morph : Morphism!(Impl), Impl);
}

//   ___      _
//  / __|__ _| |_
// | (__/ _` |  _|
//  \___\__,_|\__|

immutable struct Cat
{

  static bool is_object_impl(Obj, bool fail_if_false = false)()
  {
    const bool defines__Category = is(Obj.Category);
    const bool is_immutable = is(ImmutableOf!(Obj) == Obj);

    bool result = true;
    result &= defines__Category && is_immutable;

    static if (defines__Category)
    {
      result &= is_category!(Obj.Category);
      result &= is_sub_category!(Obj.Category, Cat);
    }

    static if (fail_if_false)
    {
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

  static bool is_object(Obj, bool fail_if_false = false)()
  {
    return is_object_impl!(Obj, fail_if_false) && is(Obj : Object!(Impl), Impl);
  }

  static bool is_morphism_impl(Morph, bool fail_if_false = false)()
  {

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

    static if (fail_if_false)
    {
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

  static bool is_morphism(Morph, fail_if_false)()
  {
    return is_morphism_impl!(Morph, fail_if_false) && is(Morph : Morphism!(Impl), Impl);
  }

  immutable struct MorphismOp(string op, MorphF, MorphG)
      if (op == "|" && is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
        && is(MorphF.Source == MorphG.Target))
  {
    this(MorphF _f, MorphG _g)
    {
      f = _f;
      g = _g;
    }

    alias Category = Cat;
    alias Source = MorphG.Source;
    alias Target = MorphF.Target;

    Source source()
    {
      return g.source();
    }

    Target target()
    {
      return f.target();
    }

    MorphF f;
    MorphG g;
  }

  static auto op(string op, MorphF, MorphG)(MorphF f, MorphG g)
      if (op == "|" && is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
        && is(MorphF.Source == MorphG.Target))
  {
    return Morphism!(MorphismOp!("|", MorphF, MorphG))(MorphismOp!("|", MorphF, MorphG)(f, g));
  }

  static auto compose(MorphF, MorphG)(MorphF f, MorphG g)
      if (is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
        && is(MorphF.Source == MorphG.Target))
  {
    return op!"|"(f, g);
  }

  immutable struct Identity(Obj)
  {

    this(Obj _obj)
    {
      obj = _obj;
    }

    alias Category = Cat;
    alias Source = Obj;
    alias Target = Obj;

    Source source()
    {
      return obj;
    }

    Target target()
    {
      return obj;
    }

    Obj obj;
  }

  static auto identity(Obj)(Obj obj) if (is_object_impl!(Obj))
  {
    return Identity!(Obj)(obj);
  }
}

//  ___      _
// / __| ___| |_
// \__ \/ -_)  _|
// |___/\___|\__|

immutable struct Set
{

  static bool is_object_impl(Obj, bool fail_if_false = false)()
  {

    const bool is_Cat_object = Cat.is_object_impl!(Obj, fail_if_false);
    const bool defines__is_element = std.traits.hasMember!(Obj, "is_element");

    bool result = is_Cat_object && defines__is_element;
    static if (is_Cat_object)
    {
      result &= is_sub_category!(Obj.Category, Set, fail_if_false);
    }

    static if (fail_if_false)
    {
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

  static bool is_object(Obj, bool fail_if_false = false)()
  {
    return is_object_impl!(Obj, fail_if_false) && is(Obj : Object!(Impl), Impl);
  }

  static bool is_morphism_impl(Morph, bool fail_if_false = false)()
  {

    const bool is_Cat_morphism = Cat.is_morphism_impl!(Morph, fail_if_false);
    const bool is_function = true; // I do not know how to test this :( 
    // Neither of the two following work 
    // std.traits.isFunction!(Morph); 
    // is(Morph == function)

    bool result = is_Cat_morphism && is_function;
    static if (is_Cat_morphism)
    {
      result &= is_object!(Morph.Source, fail_if_false);
      result &= is_object!(Morph.Target, fail_if_false);
    }

    static if (fail_if_false)
    {
      import std.format;

      static assert(is_function,
          format!"The morphism of type `%s` is not a callable function!"(
            std.traits.fullyQualifiedName!Morph));
    }

    return result;
  }

  static bool is_morphism(Morph, fail_if_false)()
  {
    return is_morphism_impl!(Morph, fail_if_false) && is(Morph : Morphism!(Impl), Impl);
  }

  immutable struct MorphismOp(string op, MorphF, MorphG)
      if (op == "|" && is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
        && is(MorphF.Source == MorphG.Target))
  {
    this(MorphF _f, MorphG _g)
    {
      f = _f;
      g = _g;
    }

    alias Category = Cat;
    alias Source = MorphG.Source;
    alias Target = MorphF.Target;

    Source source()
    {
      return g.source();
    }

    Target target()
    {
      return f.target();
    }

    auto opCall(X)(X x) if (Source.is_element!(X))
    {
      /* Do a test that g(x) is element of MorphF.Source and that f(g(x)) is element of Target */
      return f(g(x));
    }

    MorphF f;
    MorphG g;
  }

  static auto op(string op, MorphF, MorphG)(MorphF f, MorphG g)
      if (op == "|" && is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
        && is(MorphF.Source == MorphG.Target))
  {
    return Morphism!(MorphismOp!("|", MorphF, MorphG))(MorphismOp!("|", MorphF, MorphG)(f, g));
  }

  static auto compose(MorphF, MorphG)(MorphF f, MorphG g)
      if (is_morphism!(MorphF) && is_morphism!(MorphG)
        && is(MorphF.Source == MorphG.Target))
  {
    return op!"|"(f, g);
  }

  immutable struct Identity(Obj)
  {

    this(Obj _obj)
    {
      obj = _obj;
    }

    alias Category = Cat;
    alias Source = Obj;
    alias Target = Obj;

    Source source()
    {
      return obj;
    }

    Target target()
    {
      return obj;
    }

    auto opCall(X)(X x) if (Source.is_element!(X))
    {
      return x;
    }

    Obj obj;
  }

  static auto identity(Obj)(Obj obj) if (is_object_impl!(Obj))
  {
    return Morphism!(Identity!(Obj))(Identity!(Obj)(obj));
  }
}

// __   __
// \ \ / /__ __
//  \ V / -_) _|
//   \_/\___\__|

// immutable struct Vec
// {

//   static bool is_object_impl(Obj, bool fail_if_false = false)()
//   {

//     const bool is_Set_object = Set.is_object_impl!(Obj, fail_if_false);
//     const bool is_pure_vector_space = std.traits.hasMember!(Obj,
//         "is_vector_space") && Obj.is_vector_space;

//     const bool is_homset_to_vector_space = is_homset!(Obj);

//     bool result = is_Cat_object && defines__is_element;
//     static if (is_Cat_object)
//     {
//       result &= is_sub_category!(Obj.Category, Set, fail_if_false);
//     }

//     static if (fail_if_false)
//     {
//       import std.format;

//       static assert(defines__is_element,
//           format!("The object of type `%s` does not define `is_element`!")(
//             std.traits.fullyQualifiedName!Obj));
//       static assert(is_sub_category!(Obj.Category, Set), format!(
//           "The object of type `%s` defines a category of type %s that is however is not a subcategory of `Set`!")(
//           std.traits.fullyQualifiedName!Obj, std.traits.fullyQualifiedName!Obj.Category));
//     }

//     return result;
//   }

//   static bool is_morphism_impl(Morph, bool fail_if_false = false)()
//   {

//     const bool is_Cat_morphism = Cat.is_morphism_impl!(Morph, fail_if_false);
//     const bool is_function = true; // I do not know how to test this :( 
//     // Neither of the two following work 
//     // std.traits.isFunction!(Morph); 
//     // is(Morph == function)

//     bool result = is_Cat_morphism && is_function;
//     static if (is_Cat_morphism)
//     {
//       result &= is_object_impl!(Morph.Source, fail_if_false);
//       result &= is_object_impl!(Morph.Target, fail_if_false);
//     }

//     static if (fail_if_false)
//     {
//       import std.format;

//       static assert(is_function,
//           format!"The morphism of type `%s` is not a callable function!"(
//             std.traits.fullyQualifiedName!Morph));
//     }

//     return result;
//   }

//   immutable struct MorphismOp(string op, MorphF, MorphG)
//       if (op == "|" && is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
//         && is(MorphF.Source == MorphG.Target))
//   {
//     this(MorphF _f, MorphG _g)
//     {
//       f = _f;
//       g = _g;
//     }

//     alias Category = Cat;
//     alias Source = MorphG.Source;
//     alias Target = MorphF.Target;

//     Source source()
//     {
//       return g.source();
//     }

//     Target target()
//     {
//       return f.target();
//     }

//     auto opCall(X)(X x) if (Source.is_element!(X))
//     {
//       /* Do a test that g(x) is element of MorphF.Source and that f(g(x)) is element of Target */
//       return f(g(x));
//     }

//     MorphF f;
//     MorphG g;
//   }

//   static auto op(string op, MorphF, MorphG)(MorphF f, MorphG g)
//       if (op == "|" && is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
//         && is(MorphF.Source == MorphG.Target))
//   {
//     return MorphismOp!("|", MorphF, MorphG)(f, g);
//   }

//   static auto compose(MorphF, MorphG)(MorphF f, MorphG g)
//       if (is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
//         && is(MorphF.Source == MorphG.Target))
//   {
//     return op!"|"(f, g);
//   }

//   immutable struct Identity(Obj)
//   {

//     this(Obj _obj)
//     {
//       obj = _obj;
//     }

//     alias Category = Cat;
//     alias Source = Obj;
//     alias Target = Obj;

//     Source source()
//     {
//       return obj;
//     }

//     Target target()
//     {
//       return obj;
//     }

//     auto opCall(X)(X x) if (Source.is_element!(X))
//     {
//       return x;
//     }

//     Obj obj;
//   }

//   static auto identity(Obj)(Obj obj) if (is_object_impl!(Obj))
//   {
//     return Morphism!(Identity!(Obj))(Identity!(Obj)(obj));
//   }
// }

immutable struct A
{
  alias Category = Cat;

  static void foo()
  {
    writeln("A.foo");
  }
}

immutable struct B
{
  alias Category = float;
  alias a this;

  static void foo()
  {
    writeln("B.foo");
  }

  A a;
}

immutable struct M
{

  alias Category = Cat;
  alias Source = A;
  alias Target = A;

  Source source;
  Target target;
}

immutable struct TypeObject(T)
{
  alias Category = Set;

  static bool is_element(Elem)()
  {
    return is(Elem == T);
  }
}

int main()
{
  //////////////
  // Test Cat //
  //////////////

  static assert(is_category!(A.Category));
  static assert(!is_category!(B.Category));
  static assert(Cat.is_object_impl!(Object!A));
  static assert(!Cat.is_object_impl!(B));
  static assert(Cat.is_morphism_impl!(Morphism!(Cat.Identity!(A))));

  //////////////
  // Test Set //
  //////////////

  // initialize few things
  Object!(TypeObject!int) obj_int;
  Object!(TypeObject!int) obj_float;
  auto id = Set.identity(obj_int);
  //auto idid = Set.compose(id, id);
  //auto b = idid(42);

  // object
  static assert(Cat.is_object!(Object!(TypeObject!int)));
  static assert(Set.is_object!(Object!(TypeObject!int)));
  static assert(!Set.is_object!(A));

  // morphisms 
  Set.is_morphism!(Morphism!(Cat.Identity!(A)));
  // static assert(!Set.is_morphism!(Morphism!(Cat.Identity!(A))));
  // static assert(Set.is_morphism!(Morphism!(Set.Identity!(Object!(TypeObject!int)))));
  //static assert(Set.is_morphism_impl!(Morphism!(typeof(idid))));

  /////////////////

  A.foo();
  B.foo();
  writefln("A.Category = %s\nB.Category = %s", std.traits.fullyQualifiedName!(A.Category),
      std.traits.fullyQualifiedName!(B.Category));

  return 0;
}
