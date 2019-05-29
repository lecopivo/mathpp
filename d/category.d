import std.stdio;
import std.array;
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

  string symbol()
  {

    static if (std.traits.hasMember!(Impl, "symbol"))
    {
      return impl.symbol();
    }
    else static if (is(Impl : Template!Args, alias Template, Args...))
    {
      static if(is(typeof(Args[0])==string))
	return "(" ~ impl.objx.symbol() ~ Args[0] ~ impl.objy.symbol() ~ ")";
      else
	return "?";
    }
    else
    {
      return "?";
    }
  }

  alias impl this;

  Impl impl;
}

auto make_object(Impl)(Impl impl)
    if (is(Impl.Category) && is_category!(Impl.Category) && Impl.Category.is_object_impl!(Impl))
{
  return Object!(Impl)(impl);
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

auto make_morphism(Impl)(Impl impl)
    if (is(Impl.Category) && is_category!(Impl.Category) && Impl.Category.is_morphism_impl!(Impl))
{
  return Morphism!(Impl)(impl);
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

  static bool is_morphism(Morph, bool fail_if_false = false)()
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
      if (is_morphism!(MorphF) && is_morphism!(MorphG) && is(MorphF.Source == MorphG.Target))
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

immutable struct Vec(Scalar)
{

  //  ___       ___  _     _        _
  // |_ _|___  / _ \| |__ (_)___ __| |_
  //  | |(_-< | (_) | '_ \| / -_) _|  _|
  // |___/__/  \___/|_.__// \___\__|\__|
  //                    |__/

  static bool is_object_impl(Obj, bool fail_if_false = false)()
  {

    const bool is_Set_object = Set.is_object_impl!(Obj, fail_if_false);
    const bool defines__zero = std.traits.hasMember!(Obj, "zero");
    //const bool defines__is_zero = std.traits.hasMember(Obj, "is_zero");

    bool result = is_Set_object && defines__zero;
    static if (is_Set_object)
    {
      result &= is_sub_category!(Obj.Category, Vec, fail_if_false);
    }

    static if (fail_if_false)
    {
      import std.format;

      static assert(defines__zero,
          format!("The object of type `%s` does not define `zero()`!")(
            std.traits.fullyQualifiedName!Obj));
    }

    return result;
  }

  static bool is_object(Obj, bool fail_if_false = false)()
  {
    return is_object_impl!(Obj, fail_if_false) && is(Obj : Object!(Impl), Impl);
  }

  //  ___      __  __              _    _
  // |_ _|___ |  \/  |___ _ _ _ __| |_ (_)____ __
  //  | |(_-< | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  // |___/__/ |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                         |_|

  static bool is_morphism_impl(Morph, bool fail_if_false = false)()
  {

    const bool is_Set_morphism = Set.is_morphism_impl!(Morph, fail_if_false);

    bool result = is_Set_morphism;
    static if (is_Set_morphism)
    {
      result &= is_object!(Morph.Source, fail_if_false);
      result &= is_object!(Morph.Target, fail_if_false);
    }

    return result;
  }

  static bool is_morphism(Morph, bool fail_if_false = false)()
  {
    return is_morphism_impl!(Morph, fail_if_false) && is(Morph : Morphism!(Impl), Impl);
  }

  //  ___    _         _   _ _
  // |_ _|__| |___ _ _| |_(_) |_ _  _
  //  | |/ _` / -_) ' \  _| |  _| || |
  // |___\__,_\___|_||_\__|_|\__|\_, |
  //                             |__/

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

  //  ____              __  __              _    _
  // |_  /___ _ _ ___  |  \/  |___ _ _ _ __| |_ (_)____ __
  //  / // -_) '_/ _ \ | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
  // /___\___|_| \___/ |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
  //                                  |_|

  immutable struct ZeroMorphism(Src, Trg)
  {

    this(Src _src, Trg _trg)
    {
      src = _src;
      trg = _trg;
    }

    Source source()
    {
      return src;
    }

    Target target()
    {
      return trg;
    }

    auto opCall(X)(X x) if (Source.is_element!(X))
    {
      return trg.zero();
    }

    alias Category = Vec!(Scalar);
    alias Source = Src;
    alias Target = Trg;

    Source src;
    Target trg;
  }

  static auto zero_morphism(Src, Trg)(Src src, Trg trg)
  {
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

  static bool is_morphism_op_valid(string op, F, G)() if (op == "|")
  {
    return is_morphism!(F) && is_morphism!(G) && is(F.Source == G.Target);
  }

  immutable struct MorphismOp(string op, F, G)
      if (op == "|" && is_morphism_op_valid!("|", F, G))
  {

    this(F _f, G _g)
    {
      f = _f;
      g = _g;
    }

    alias Category = Cat;
    alias Source = G.Source;
    alias Target = F.Target;

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

  static bool is_morphism_op_valid(string op, F, G)() if (op == "+" || op == "-")
  {
    return is_morphism!(F) && is_morphism!(G) && is(F.Source == G.Source) && is(F.Target == G
        .Target);
  }

  immutable struct MorphismOp(string op, F, G)
      if ((op == "+" && is_morphism_op_valid!("+", F, G)) || (op == "-"
        && is_morphism_op_valid!("-", F, G)))
  {
    this(F _f, G _g)
    {
      f = _f;
      g = _g;
    }

    alias Category = Cat;
    alias Source = F.Source;
    alias Target = F.Target;

    Source source()
    {
      return f.source();
    }

    Target target()
    {
      return f.target();
    }

    auto opCall(X)(X x) if (Source.is_element!(X))
    {
      static if (op == "+") /* addition */
        {
          return f(x) + g(x);
        }
      else
      {
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

  static bool is_morphism_op_valid(string op, F, G)() if (op == "·")
  {
    return (is_morphism!(F) && is(G == Scalar)) || (is(F == Scalar) && is_morphism!(G));
  }

  immutable struct MorphismOp(string op, F, G)
      if (op == "·" && is_morphism_op_valid!("·", F, G))
  {
    this(F _f, G _g)
    {
      f = _f;
      g = _g;
    }

    alias Category = Cat;
    static if (is(G == Scalar))
    {
      alias Source = F.Source;
      alias Target = F.Target;
    }
    else
    {
      alias Source = G.Source;
      alias Target = G.Target;
    }

    Source source()
    {
      static if (is(G == Scalar))
      {
        return f.source();
      }
      else
      {
        return g.source();
      }
    }

    Target target()
    {
      static if (is(G == Scalar))
      {
        return f.target();
      }
      else
      {
        return g.target();
      }
    }

    auto opCall(X)(X x) if (Source.is_element!(X))
    {
      static if (is(G == Scalar))
      {
        return f(x) * g;
      }
      else
      {
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

  static bool is_object_op_valid(string op, ObjX, ObjY)() if (op == "⇒")
  {
    return is_object!(ObjX) && is_object!(ObjY);
  }

  immutable struct ObjectOp(string op, ObjX, ObjY)
      if (op == "⇒" && is_object_op_valid!("⇒", ObjX, ObjY))
  {

    this(ObjX _objx, ObjY _objy)
    {
      objx = _objx;
      objy = _objy;
    }

    static bool is_element(Elem)()
    {
      return is_morphism!(Elem) && is(Elem.Source == ObjX) && is(Elem.Target == ObjY);
    }

    auto zero()
    {
      return zero_morphism(objx, objy);
    }
    
    auto symbol(){
      return "Hom(" ~ objx.symbol() ~ "," ~ objy.symbol() ~ ")";
    }

    alias Category = Vec;

    ObjX objx;
    ObjY objy;
  }

  // Hom Functor 
  immutable struct Hom
  {

    alias Source = Vec!(Scalar);
    alias Target = Vec!(Scalar);

    static immutable is_bifunctor = true;

    static auto opCall(X, Y)(X x, Y y)
        if ((is_object!(X) && (is_object!(Y) || is(Y == string)))
          || ((is_object!(X) || is(X == string)) && is_object!(Y)))
    {
      // We call the bifunctor with two objects
      static if (is_object!(X) && is_object!(Y))
      {
        // Return HomSet
        return make_object(ObjectOp!("⇒", X, Y)(x, y));
      }
      else
      {
        static assert("Functors Hom[-,Y] and Hom[X,-] need implementation");
      }
    }

    static auto fmap(MorphF, MorphG)(MorphF f, MorphG g)
    {

      auto source = this(f.target(), g.source());
      auto target = this(f.source(), g.target());

      struct sandwich
      {
        this(MorphF _f, MorphG _g)
        {
          f = _f;
          g = _g;
        }

        auto opCall(X)(X x)
        {
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

  static bool is_object_op_valid(string op, X, Y)() if (op == "⊕")
  {
    return is_object!(X) && is_object!(Y);
  }

  static bool is_morphism_op_valid(string op, F, G)() if (op == "⊕")
  {
    return is_morphism!(F) && is_morphism!(G);
  }

  // Functor

  immutable struct Sum
  {

    alias Source = Vec!(Scalar);
    alias Target = Vec!(Scalar);

    static auto opCall(ObjX, ObjY)(ObjX objx, ObjY objy)
        if (is_object_op_valid!("⊕", ObjX, ObjY))
    {
      auto impl = ObjectOp!("⊕", ObjX, ObjY)(objx, objy);
      return Object!(typeof(impl))(impl);
    }

    auto fmap(MorphF, MorphG)(MorphF f, MorphG g)
        if (is_morphism_op_valid!("⊕", MorphF, MorphG))
    {
      auto impl = MorphismOp!("⊕", MorphF, MorphG)(f, g);
      return Morphism!(typeof(impl))(impl);
    }
  }

  // Pair

  struct Pair(X, Y)
  {

    this(X _x, Y _y)
    {
      x = _x;
      y = _y;
    }

    auto opBinary(string op, RX, RY)(SumElement!(RX, RY) rhs) const 
        if (op == "+" || op == "-")
    {
      mixing("return make_sum_element(x" ~ op ~ "rhs.x, y" ~ op ~ "rhs.y);");
    }

    auto opBinary(string op)(Scalar s) const if (op == "*")
    {
      return make_sum_element(s * x, s * y);
    }

    auto opBinaryRight(string op)(Scalar s) if (op == "*")
    {
      return make_sum_element(s * x, s * y);
    }

    X x;
    Y y;
  }

  static Pair!(X, Y) make_sum_element(X, Y)(X x, Y y)
  {
    return Pair!(X, Y)(x, y);
  }

  // Object Operation

  immutable struct ObjectOp(string op, ObjX, ObjY)
      if (op == "⊕" && is_object_op_valid!("⊕", ObjX, ObjY))
  {

    this(ObjX _objx, ObjY _objy)
    {
      objx = _objx;
      objy = _objy;
    }

    static bool is_element(Obj)()
    {
      return false;
    }

    static bool is_element(Obj : Pair!(X, Y), X, Y)()
    {
      return ObjX.is_element!(X) && ObjY.is_element!(Y);
    }

    auto zero()
    {
      return make_sum_element(objx.zero(), objy.zero());
    }

    alias Category = Vec;

    ObjX objx;
    ObjY objy;
  }

  // Morphism Operation

  immutable struct MorphismOp(string op, MorphF, MorphG)
      if (op == "⊕" && is_morphism_op_valid!("⊕", MorphF, MorphG))
  {
    this(MorphF _f, MorphG _g)
    {
      f = _f;
      g = _g;
    }

    alias Category = Cat;
    alias Source = std.traits.ReturnType!(Sum!(MorphF.Source, MorphG.Source));
    alias Target = std.traits.ReturnType!(Sum!(MorphF.Target, MorphG.Target));

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
      return make_sum_elem(f(x.x), g(x.y));
    }

    MorphF f;
    MorphG g;
  }

  static auto op(string op, MorphF, MorphG)(MorphF f, MorphG g)
      if (is_morphism_op_valid!(op, MorphF, MorphG))
  {
    auto impl = (MorphismOp!(op, MorphF, MorphG)(f, g));
    return Morphism!(typeof(impl))(impl);
  }
}

//  __  __      _       _
// |  \/  |__ _| |_ _ _(_)_ __
// | |\/| / _` |  _| '_| \ \ /
// |_|  |_\__,_|\__|_| |_/_\_\

struct Matrix(Real, int N, int M)
{

  this(Real[N * M] vals)
  {
    data = vals;
  }

  static Matrix!(Real, N, M) constant(Real c)
  {
    Matrix!(Real, N, M) result;
    for (int j = 0; j < M; j++)
    {
      for (int i = 0; i < N; i++)
      {
        result[i, j] = c;
      }
    }
    return result;
  }

  ref Real opIndex(int i, int j)
  in
  {
    assert(i >= 0 && i < N && j >= 0 && j < M, "Index out of range!");
  }
  do
  {
    return data[i + N * j];
  }

  Real opIndex(int i, int j) const
  in
  {
    assert(i >= 0 && i < N && j >= 0 && j < M, "Index out of range!");
  }
  do
  {
    return data[i + N * j];
  }

  void opOpAssign(string op)(Matrix!(Real, N, M) rhs) if (op == "+" || op == "-")
  {
    for (int j = 0; j < M; j++)
    {
      for (int i = 0; i < N; i++)
      {
        mixin("this[i,j] " ~ op ~ "= rhs[i,j];");
      }
    }
  }

  void opOpAssign(string op : "*")(Real scalar)
  {
    for (int j = 0; j < M; j++)
    {
      for (int i = 0; i < N; i++)
      {
        this[i, j] *= scalar;
      }
    }
  }

  Matrix!(Real, N, M) opBinary(string op)(Matrix!(Real, N, M) rhs) const 
      if (op == "+" || op == "-")
  {
    Matrix!(Real, N, M) result = this;
    mixin("result " ~ op ~ "= rhs;");
    return result;
  }

  Matrix!(Real, N, L) opBinary(string op, int L)(Matrix!(Real, M, L) rhs)
      if (op == "*")
  {
    Matrix!(Real, N, L) result;
    for (int j = 0; j < L; j++)
    {
      for (int i = 0; i < N; i++)
      {
        result[i, j] = 0;
        for (int k = 0; k < M; k++)
        {
          result[i, j] += this[i, k] * rhs[k, j];
        }
      }
    }
    return result;
  }

  Matrix!(Real, N, M) opBinary(string op)(Real scalar) if (op == "*")
  {
    auto result = this;
    result *= scalar;
    return result;
  }

  Matrix!(Real, N, M) opBinaryRight(string op)(Real scalar) if (op == "*")
  {
    auto result = this;
    result *= scalar;
    return result;
  }

  string toString()
  {
    // Typical implementation to minimize overhead
    // of constructing string
    auto app = appender!string();
    for (int i = 0; i < N; i++)
    {
      for (int j = 0; j < M; j++)
      {
        import std.conv;

        app.put(to!string(this[i, j]));
        if (j < M - 1)
          app.put(" ");
      }
      if (i < N - 1)
        app.put(" \n");
    }
    return app.data;
  }

  Real[N * M] data;
}

//  _____       _
// |_   _|__ __| |_ ___
//   | |/ -_|_-<  _(_-<
//   |_|\___/__/\__/__/

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

immutable struct VectorSpaceImpl(Real, int N, int M)
{

  alias Category = Vec!(Real);

  static bool is_element(Elem)()
  {
    return is(Elem : Matrix!(Real, N, M));
  }

  static Matrix!(Real, N, M) zero()
  {
    return Matrix!(Real, N, M).constant(0.0);
  }

  string symbol() const
  {
    import std.conv;

    return "ℝ(" ~ to!string(N) ~ "," ~ to!string(M) ~ ")";
  }
}

auto VectorSpace(Real, int N, int M)()
{
  return make_object(VectorSpaceImpl!(Real, N, M)());
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
  auto idid = Set.compose(id, id);
  auto b = idid(42);

  // object
  static assert(Cat.is_object!(Object!(TypeObject!int)));
  static assert(Set.is_object!(Object!(TypeObject!int)));
  static assert(!Set.is_object!(A));

  // morphisms 
  static assert(!Set.is_morphism!(Morphism!(Cat.Identity!(A))));
  static assert(Set.is_morphism!(Morphism!(Set.Identity!(Object!(TypeObject!int)))));
  static assert(Set.is_morphism_impl!(Morphism!(typeof(idid))));

  //////////////
  // Test Vec //
  //////////////

  //writeln(Vec!(double).is_object_impl!(VectorSpaceImpl!(double, 2, 1),true));
  auto R2 = VectorSpace!(double, 1, 2);
  auto homset = Vec!(double).Hom(R2, R2);
  auto homset2 = Vec!(double).Hom(homset, homset);
  auto homset_zero = homset.zero();
  auto u = Matrix!(double, 1, 2)([2.0, 1.0]);
  
  auto sum = Vec!(double).Sum(R2, R2);
  
  writeln(u, "\n");
  writeln(R2.zero(), "\n");
  writeln(homset_zero(u), "\n");

  writeln(R2.symbol());
  writeln(homset.symbol());
  writeln(homset2.symbol());
  writeln(sum.symbol());
  writeln(sum.zero());

  static if (is(typeof(homset) : Object!(Args), Args...))
  {
    writeln("homset is Object");
    // writeln(__traits(isSame, Template, Tuple)); // true
    // writeln(is(Template!(int, long) == Tup));  // true
    writeln(typeid(Args[0]));  // int
    
    writeln(is(Args[0] : Template!( Ts), alias Template, Ts...));
    
    writeln(is(typeof(Ts[0]) == string));
    // writeln(std.traits.fullyQualifiedName!Template);
    // writeln(typeid(typeof(Ts[0])));
    // writeln(Ts[0]);
    //writeln(typeid(Args[1]));  // immutable(char)[]
  }

  /////////////////

  return 0;
}
