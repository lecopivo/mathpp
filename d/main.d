import std.stdio;

struct X(T) {

  this(T t) {
    member = t;
  }

  alias Member = T;
  T member;
}

auto myMap(alias Fun, X...)(X x) {
  import std.typecons;
  import std.meta;

  static if (X.length > 1)
    return tuple(Fun(x[0])) ~ myMap!(Fun)(x[1 .. $]);
  else
    return tuple(Fun(x[0]));
}

int main() {

  auto g(X...)(X x) {
    static foreach (y; x)
      writeln(y);
    return 0;
  }

  auto f(X...)(X x) {
    import std.meta;
    import std.traits;
    import std.algorithm;
    import std.typecons;

    alias MemberOf(T) = T.Member;
    alias TX = staticMap!(MemberOf, X);

    static foreach (t; TX)
      writeln(typeid(t));

    //writeln(typeid(typeof(x)));
    //auto y = map!(x => x)([x]);
    auto z = myMap!(x => x.member)(x).expand;
    return g(z);
  }

  f(X!(int)(1), X!(int)(42), X!(double)(3.1415));
  //f(1, "sdf", 3.1415);

  return 0;
}
