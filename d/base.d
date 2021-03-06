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

// This should be probably depricated
string expand(int N, string code, string variable = "I", string separator = ",") {

  string result = "";
  foreach (I; 0 .. N) {
    if (I != 0)
      result ~= separator;
    import std.array;
    import std.conv;

    result ~= code.replace(variable, to!string(I));
  }

  return result;
}

// This calling convention is probably much better
string expand(string code, int N, string separator = ",", string variable = "I") {
  return expand(N, code, variable, separator);
}

// This calling convention is probably much better
string expand2(string code, int N, string separator = ",", string variable = "I") {
  return expand(N, code, variable, separator);
}

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

  alias impl this;

  Impl impl;

  this(Impl _impl) {
    impl = _impl;
  }

  string toString() {
    return impl.symbol() ~ " : " ~ source().symbol() ~ "→" ~ target().symbol();
  }

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
