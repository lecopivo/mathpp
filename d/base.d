auto myMap(alias Fun, X...)(X x) {
  import std.typecons;
  import std.meta;

  static if (X.length > 1)
    return tuple(Fun(x[0])) ~ myMap!(Fun)(x[1 .. $]);
  else
    return tuple(Fun(x[0]));
}

immutable struct FunctionObject(alias Lambda) {

  auto opCall(X)(X x) {
    return Lambda(x);
  }
}

alias SourceOf(T) = T.Source;
alias TargetOf(T) = T.Target;

bool is_category(C, bool fail_if_false = false)() {
  import std.traits;

  const bool defines__is_object_impl = std.traits.hasMember!(C, "is_object_impl");
  const bool is_immutable = is(ImmutableOf!(C) == C);

  static if (fail_if_false) {
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
bool is_sub_category(D, C, bool fail_if_false = false)() {
  // Do some proper checking of categories
  return is_category!(D, fail_if_false);
}

//  --------
bool is_functor() {
  return false;
}

string to_latex(string unicode) {
  switch (unicode) {
  case "⊕":
    return "\\oplus";
  case "⊗":
    return "\\otimes";
  case "→":
    return "\\rightarrow";
  default:
    return unicode;
  }
}

immutable struct Object(Impl)
    if (is(Impl.Category) && is_category!(Impl.Category) && Impl.Category.is_object_impl!(Impl)) {
  this(Impl _impl) {
    impl = _impl;
  }

  string symbol() {
    import std.traits;

    static if (std.traits.hasMember!(Impl, "symbol")) {
      return impl.symbol();
    }
    else static if (std.traits.hasMember!(Impl, "arg") && is(Impl : Template!T,
        alias Template, T...)) {
      static if (is(typeof(T[0]) == string))
        return "(" ~ impl.arg!(0).symbol() ~ T[0] ~ impl.arg!(1).symbol() ~ ")";
      else
        return "?";
    }
    else {
      return "?";
    }

    return "?";
  }

  string latex() {
    import std.traits;

    // static if (std.traits.hasMember!(Impl, "latex"))
    //   {
    //     return impl.latex();
    //   }
    // else static if (is(Impl : Template!Args, alias Template, Args...))
    //   {
    //     static if(is(typeof(Args[0])==string))
    //       return "\\left(" ~ impl.objx.latex() ~ " " ~ to_latex(Args[0]) ~ " " ~ impl.objy.latex() ~ "\\right)";
    //     else
    //       return "?";
    //   }
    // else
    //   {
    //     return "?";
    //   }

    return "?";
  }

  alias impl this;

  Impl impl;
}

auto make_object(Impl)(Impl impl)
    if (is(Impl.Category) && is_category!(Impl.Category) && Impl.Category.is_object_impl!(Impl)) {
  return Object!(Impl)(impl);
}

string symbol(T)(T t) {
  import std.traits;

  static if (std.traits.hasMember!(T, "symbol")) {
    return impl.symbol();
  }
  else static if (std.traits.hasMember!(T, "toString")) {
    return t.toString();
  }
  else {
    import std.conv;

    return to!string(t);
  }
}

immutable struct Morphism(Impl)
    if (is(Impl.Category) && is_category!(Impl.Category) && Impl.Category.is_morphism_impl!(Impl)) {
  this(Impl _impl) {
    impl = _impl;
  }

  string symbol() const {
    import std.traits;

    // static if (std.traits.hasMember!(Impl, "symbol"))
    //   {
    //     return impl.symbol();
    //   }
    // else static if (is(Impl : Template!Args, alias Template, Args...))
    //   {
    //     static if(is(typeof(Args[0])==string))
    //       return "(" ~ impl.f.symbol() ~ Args[0] ~ impl.g.symbol() ~ ")";
    //     else
    //       return "?";
    //   }
    // else
    //   {
    //     return "?";
    //   }
    return "?";
  }

  string toString() const {
    return symbol() ~ " : " ~ source().symbol() ~ "→" ~ target().symbol();
  }

  alias impl this;

  Impl impl;
}

auto make_morphism(Impl)(Impl impl)
    if (is(Impl.Category) && is_category!(Impl.Category) && Impl.Category.is_morphism_impl!(Impl)) {
  return Morphism!(Impl)(impl);
}

bool is_object(Obj)() {
  return is(Obj : Object!(Impl), Impl);
}

bool is_morphism(Morph)() {
  return is(Morph : Morphism!(Impl), Impl);
}
