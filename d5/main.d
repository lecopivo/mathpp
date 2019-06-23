#!/usr/bin/rdmd -g

import nonsense;

import std.stdio;

void test1(){
  
  auto X = symbolicObject(Set, "X");
  auto Y = symbolicObject(Set, "Y");
  auto Z = symbolicObject(Set, "Z");

  auto f = symbolicMorphism(Set, X, Y, "f");
  auto g = symbolicMorphism(Set, X, Z, "g");

  auto x = symbolicElement(X, "x");

  auto pi0 = product(Y,Z).projection(0);
  auto pi1 = product(Y,Z).projection(0);

  compose(pi0,product(f,g)).fprint;

  product(f,g)(x).fprint;
  pi0(product(f,g)(x)).fprint;

}

void main() {

  auto X = symbolicObject(Set, "X");
  auto Y = symbolicObject(Set, "Y");
  auto Z = symbolicObject(Set, "Z");

  auto U = symbolicObject(Vec, "U");
  auto V = symbolicObject(Vec, "V");
  auto W = symbolicObject(Vec, "W");


  auto g = symbolicMorphism(Set, X, Y, "g");
  auto f = symbolicMorphism(Set, Y, Z, "f");
  auto h = symbolicMorphism(Set, Z, X, "h");

  auto g2 = symbolicMorphism(Set, X, Y, "g2");
  auto f2 = symbolicMorphism(Set, Y, Z, "f2");
  auto h2 = symbolicMorphism(Set, Z, X, "h2");


  auto x = symbolicElement(X, "x");
  auto y = symbolicElement(Y, "y");
  auto z = symbolicElement(Z, "z");

  x.fprint;
  X.identity.fprint;
  g.fprint;
  f.fprint;

  writeln();

  compose(f, g).fprint;
  compose(f, g.set()).fprint;
  compose(f.set(), g.set()).fprint;

  writeln();

  assert(x.isEqual(x.extract(x)(x)));
  assert(y.isEqual(y.extract(x)(x)));
  assert(compose(f,g).isEqual(compose(f, g).extract(g)(g)));
  assert(g(x).isEqual(g(x).extract(x)(x)));
  assert(x.isEqual(x.extract(elementMap(x))(elementMap(x))));
  assert(g(x).isEqual(g(x).extract(g)(g)));

  // g(x).extract(g).fprint;

  // auto F = symbolicMorphism(Set, X, Set.homSet(X,Y), "F");

  // //F(x)(x).extract(elementMap(x)).fprint;

  product(X,Y).fprint;
  product(X,Y).projection(0).fprint;
  product(X,Y).projection(1).fprint;


  test1();
}
