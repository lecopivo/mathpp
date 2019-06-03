immutable struct Fun(alias Lambda) {

  auto opCall(X)(X x) {
    return Lambda(x);
  }
}

auto callFun(Fun, X)(Fun fun, X x) {
  return fun(x);
}

int main() {
  import std.stdio;
  import std.math;

  Fun!(x => x) fun;

  writeln(callFun(fun, 3.1415));
  writeln(callFun(Fun!(x => sqrt(x)).init, 2.0));
  //writeln(callFun(x => sqrt(x), 2.0));

  return 0;

}
