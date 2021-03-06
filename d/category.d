module category;

import std.stdio;
import std.array;

import base;

//  __  __      _       _
// |  \/  |__ _| |_ _ _(_)_ __
// | |\/| / _` |  _| '_| \ \ /
// |_|  |_\__,_|\__|_| |_/_\_\

struct Matrix(Real, int N, int M) {

  this(Real[N * M] vals) {
    data = vals;
  }

  static Matrix!(Real, N, M) constant(Real c) {
    Matrix!(Real, N, M) result;
    for (int j = 0; j < M; j++) {
      for (int i = 0; i < N; i++) {
        result[i, j] = c;
      }
    }
    return result;
  }

  ref Real opIndex(int i, int j)
  in {
    assert(i >= 0 && i < N && j >= 0 && j < M, "Index out of range!");
  }
  do {
    return data[i + N * j];
  }

  Real opIndex(int i, int j) const
  in {
    assert(i >= 0 && i < N && j >= 0 && j < M, "Index out of range!");
  }
  do {
    return data[i + N * j];
  }

  void opOpAssign(string op)(Matrix!(Real, N, M) rhs) if (op == "+" || op == "-") {
    for (int j = 0; j < M; j++) {
      for (int i = 0; i < N; i++) {
        mixin("this[i,j] " ~ op ~ "= rhs[i,j];");
      }
    }
  }

  void opOpAssign(string op : "*")(Real scalar) {
    for (int j = 0; j < M; j++) {
      for (int i = 0; i < N; i++) {
        this[i, j] *= scalar;
      }
    }
  }

  Matrix!(Real, N, M) opBinary(string op)(Matrix!(Real, N, M) rhs) const 
      if (op == "+" || op == "-") {
    Matrix!(Real, N, M) result = this;
    mixin("result " ~ op ~ "= rhs;");
    return result;
  }

  Matrix!(Real, N, L) opBinary(string op, int L)(Matrix!(Real, M, L) rhs) const 
      if (op == "*") {
    Matrix!(Real, N, L) result;
    for (int j = 0; j < L; j++) {
      for (int i = 0; i < N; i++) {
        result[i, j] = 0;
        for (int k = 0; k < M; k++) {
          result[i, j] += this[i, k] * rhs[k, j];
        }
      }
    }
    return result;
  }

  Matrix!(Real, N, M) opBinary(string op)(Real scalar) const if (op == "*") {
    Matrix!(Real, N, M) result = this;
    result *= scalar;
    return result;
  }

  Matrix!(Real, N, M) opBinaryRight(string op)(Real scalar) const if (op == "*") {
    Matrix!(Real, N, M) result = this;
    result *= scalar;
    return result;
  }

  string toString() {
    // Typical implementation to minimize overhead
    // of constructing string
    auto app = appender!string();
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < M; j++) {
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

immutable struct A {
  import cat;

  alias Category = Cat;

  static void foo() {
    writeln("A.foo");
  }
}

immutable struct B {
  alias Category = float;
  alias a this;

  static void foo() {
    writeln("B.foo");
  }

  A a;
}

immutable struct M {
  import cat;

  alias Category = Cat;
  alias Source = A;
  alias Target = A;

  Source source;
  Target target;
}

immutable struct TypeObject(T) {
  import set;

  alias Category = Set;

  static bool is_element(Elem)() {
    return is(Elem == T);
  }
}

immutable struct VectorSpaceImpl(Real, int N, int M) {
  import vec;

  alias Category = Vec!(Real);

  static bool is_element(Elem)() {
    return is(Elem : Matrix!(Real, N, M));
  }

  static Matrix!(Real, N, M) zero() {
    return Matrix!(Real, N, M).constant(0.0);
  }

  string symbol() const {
    import std.conv;

    return "ℝ(" ~ to!string(N) ~ "," ~ to!string(M) ~ ")";
  }

  string latex() const {
    import std.conv;

    return "\\mathbb{R}^{" ~ to!string(N) ~ " \\times " ~ to!string(M) ~ "}";
  }
}

auto VectorSpace(Real, int N, int M)() {

  return make_object(VectorSpaceImpl!(Real, N, M)());
}

int main() {

  import std.traits;
  import base;
  import cat;
  import set;
  import vec;
  import diff;
  
  //////////////
  // Test Cat //
  //////////////

  writeln(typeid(A));
  writeln(typeid(ImmutableOf!(A)));
  writeln(is(A.Category));
  writeln(is_category!(A.Category));
  writeln(Cat.is_object_impl!(A, true));

  alias OA = Object!A;

  static assert(is_category!(A.Category));
  static assert(!is_category!(B.Category));
  static assert(Cat.is_object_impl!(Object!A));
  static assert(!Cat.is_object_impl!(B));
  static assert(Cat.is_morphism_impl!(Morphism!(Cat.Identity!(Object!A))));

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
  static assert(Cat.is_object!(Object!(TypeObject!int), true));
  static assert(Set.is_object!(Object!(TypeObject!int)));
  static assert(!Set.is_object!(A));

  // morphisms 
  static assert(!Set.is_morphism!(Morphism!(Cat.Identity!(Object!A))));
  static assert(Set.is_morphism!(Morphism!(Set.Identity!(Object!(TypeObject!int)))));
  static assert(Set.is_morphism_impl!(Morphism!(typeof(idid))));

  //////////////
  // Test Vec //
  //////////////

  writeln(Vec!(double).is_object_impl!(VectorSpaceImpl!(double, 2, 1), true));
  auto R2 = VectorSpace!(double, 2, 1);
  auto homset = Vec!(double).Hom(R2, R2);
  auto homset2 = Vec!(double).Hom(homset, homset);
  auto homset_zero = homset.zero();
  auto u = Matrix!(double, 2, 1)([1.0, 0.0]);

  auto sum = Vec!(double).Sum(R2, R2);

  writeln(u, "\n");
  writeln(R2.zero(), "\n");
  writeln(homset_zero(u), "\n");

  writeln(R2.symbol());
  writeln(homset.symbol());
  writeln(homset2.symbol());

  auto z = Vec!double.identity(R2);

  static assert(Set.is_morphism!(typeof(z)));

  writeln("hoho");
  writeln(Vec!double.is_morphism_op_valid!("+", typeof(z), typeof(z)));

  auto zz = Vec!(double).operation!("+")(z, z);
  writeln(Vec!(double).operation!("+")(z, z));
  writeln(Vec!(double).operation!("·")(z, 2.0));
  writeln(Vec!(double).operation!("⊕")(z, z));

  alias Mat22 = Matrix!(double, 2, 2);
  immutable auto A = Matrix!(double, 2, 2)([0.0, 1.0, 1.0, 0.0]);

  immutable struct MatMul(Mat) {

    Mat* mat;

    this(ref immutable Mat _mat) {
      mat = &_mat;
    }

    auto opCall(X)(X x) {
      return (*mat) * x;
    }
  }

  //auto foo = MatMul!(Mat22)(A);
  auto m = Vec!(double).morphism(R2, R2, MatMul!(Mat22)(A));
  //auto m2 = Vec!(double).morphism!(delegate (x) => A * x)(R2, R2);

  auto f = Vec!(double).operation!("·")(z, 2.0);
  auto g = Vec!(double).operation!("+")(z, z, z);
  auto h = Vec!(double).operation!("∘")(m, m, g, f, f);
  auto foo = Vec!(double).Sum.fmap(g, m);
  auto uu = Vec!(double).make_sum_element(3*u, u);
  writeln(z(u), "\n");
  writeln(f(u), "\n");
  writeln(g(u), "\n");
  writeln(h(u), "\n");
  writeln(m(u), "\n");
  writeln(foo);
  auto pi = foo.source().projection!(1);
  writeln(pi.source());
  writeln(pi.source().symbol());
  writeln(pi(uu));
  writeln(pi(uu));
  writeln(2.0*u);
  writeln(u*2.0);
  writeln(uu);
  writeln(uu + uu);
  writeln(uu*3.1415);
  writeln(3.1415*uu);
  
  

  import std.typecons;

  writeln(mixin("tuple(", expand!(5, "I"), ")").expand);

  import std.algorithm;

  // writeln( map!(x => x~x)(tuple("a", "b", "c")));
  // writeln(m2(u), "\n");

  // writeln(z);

  // writeln(homset2.latex());

  // writeln(sum.symbol());
  // writeln(sum.zero());

  // static if (is(typeof(homset) : Object!(Args), Args...)) {
  //   writeln("homset is Object");
  //   // writeln(__traits(isSame, Template, Tuple)); // true
  //   // writeln(is(Template!(int, long) == Tup));  // true
  //   writeln(typeid(Args[0])); // int

  //   writeln(is(Args[0] : Template!(Ts), alias Template, Ts...));

  //   writeln(is(typeof(Ts[0]) == string));
  //   // writeln(std.traits.fullyQualifiedName!Template);
  //   // writeln(typeid(typeof(Ts[0])));
  //   // writeln(Ts[0]);
  //   //writeln(typeid(Args[1]));  // immutable(char)[]
  // }

  // ///////////////
  // // Test Diff //
  // ///////////////

  // auto cm = Diff!(Vec!(double)).constant_morphism(R2, R2, u);

  // auto RR = Diff!(Vec!(double)).Product(R2,R2);
  // auto mm = Diff!(Vec!(double)).Product.fmap(z,z);

  // writeln(z);
  // writeln(mm.symbol());
  // writeln(RR.symbol());

  return 0;
}
