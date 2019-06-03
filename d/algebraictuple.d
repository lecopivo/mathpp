struct AlgebraicTuple(X...) {
  import std.typecons;

  Tuple!(X) data;

  this(X x) {
    data = tuple(x);
  }

  static bool isCWiseOpValid(string op, Y...)() {

    static if (X.length != Y.length) {
      return false;
    }
    else {

      bool result = true;

      X _x;
      Y _y;

      static foreach (I, Z; X) {
        mixin("result &=  __traits(compiles, _x[I]" ~ op ~ "_y[I]);");
      }

      return result;
    }
  }

  auto opBinary(string op, Y...)(auto ref AlgebraicTuple!(Y) rhs)
      if (isCWiseOpValid!(Y)) {

  }

  alias data this;
}

auto algebraicTuple(X...)(X x) {
  return AlgebraicTuple!(X)(x);
}

unittest {
  static assert(AlgebraicTuple!(int, int).isCWiseOpValid!("+", int, int));
  static assert(AlgebraicTuple!(int, float).isCWiseOpValid!("*", double, int));
  
  static assert(!AlgebraicTuple!(int, float).isCWiseOpValid!("*", double, int, int));
  static assert(!AlgebraicTuple!(int, int).isCWiseOpValid!("+", int, string));
}

int main() {

  import std.stdio;

  auto t1 = algebraicTuple(1, 42, 3.1415, "hello");
  auto t2 = algebraicTuple(1, 42, 3.1415);
  auto t3 = algebraicTuple("abc", "hello");

  writeln(t1);
  writeln(t2);

  return 0;
}
