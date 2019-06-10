// __   __      _             ___
// \ \ / /__ __| |_ ___ _ _  / __|_ __  __ _ __ ___
//  \ V / -_) _|  _/ _ \ '_| \__ \ '_ \/ _` / _/ -_)
//   \_/\___\__|\__\___/_|   |___/ .__/\__,_\__\___|
//                               |_|

auto VectorSpace(Real, int N, int M, string symb = "", string lat = "")() {
  import base;

  return make_object(VectorSpaceImpl!(Real, N, M, symb, lat)());
}

immutable struct VectorSpaceImpl(Real, int N, int M, string symb = "", string lat = "") {
  import vec;

  alias Category = Vec!(Real);

  static bool is_element(Elem)() {
    return is(Elem : Matrix!(Real, N, M));
  }

  static Matrix!(Real, N, M) zero() {
    return Matrix!(Real, N, M).constant(0.0);
  }

  string symbol() {
    if (symb == "") {
      import std.conv;

      return "ℝ(" ~ to!string(N) ~ "," ~ to!string(M) ~ ")";
    }
    else {
      return symb;
    }
  }

  string latex() {
    if (lat == "") {
      import std.conv;

      return "\\mathbb{R}^{" ~ to!string(N) ~ " \\times " ~ to!string(M) ~ "}";
    }
    else {
      return lat;
    }
  }
}

immutable struct MatMul(Mat) {

  Mat mat;

  this(Mat _mat) {
    mat = _mat;
  }

  auto opCall(X)(X x) {
    return mat * x;
  }

  string symbol() {
    return "A";
  }

  string latex() {
    return "A";
  }
}

auto matMul(Mat)(Mat mat) {
  return MatMul!(Mat)(mat);
}

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

  string symbol() const {
    return "u";
  }

  string latex() const {
    return "u";
  }

  string toString() const {
    import std.array;

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
