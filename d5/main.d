#!/usr/bin/rdmd -g

import nonsense;

import std.stdio;

void test1() {

  auto X = symbolicObject(Set, "X");
  auto Y = symbolicObject(Set, "Y");
  auto Z = symbolicObject(Set, "Z");

  auto f = symbolicMorphism(Set, X, Y, "f");
  auto g = symbolicMorphism(Set, X, Z, "g");

  auto x = symbolicElement(X, "x");

  auto pi0 = productObject(Y, Z).projection(0);
  auto pi1 = productObject(Y, Z).projection(0);

  compose(pi0, product(f, g)).fprint;

  product(f, g)(x).fprint;
  pi0(product(f, g)(x)).fprint;

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
  auto phi = symbolicMorphism(Set, X, Y, "phi", "\\phi");
  auto psi = symbolicMorphism(Set, X, Z, "psi", "\\psi");

  auto x = symbolicElement(X, "x");
  auto y = symbolicElement(Y, "y");
  auto z = symbolicElement(Z, "z");

  auto u = symbolicElement(U, "u");
  auto v = symbolicElement(V, "v");

  auto F = symbolicMorphism(Set, X, Set.homSet(Y,Z), "F");
  auto foo = symbolicMorphism(Set, X, Vec.homSet(U,V), "foo");
  auto bar = symbolicMorphism(Vec, U, Set.homSet(X,V), "bar");


  F.fprint;
  F.swapArguments.fprint;
  F(x)(y).extract(x).fprint;

  writeln();

  foo.fprint;
  foo(x)(u).fprint;
  foo(x)(u).extract(x).fprint;
  foo(x)(u).extract(u).fprint;

  writeln();

  bar.fprint;
  bar(u)(x).fprint;
  bar(u)(x).extract(x).fprint;
  bar(u)(x).extract(u).fprint;

  bar(u)(x).extract(u).cprint;
  
  writeln();
  
  compose(f.set(), g).fprint;
  compose(f.set(), g).extract(g)(g).fprint;
  
  //foo.swapArguments.fprint;

  // makePair(x,u).extract(x).fprint;
  // makePair(v,u).extract(u).extract(v).swapArguments.fprint;
  // makePair(x,y).extract(x).extract(y).fprint;
  // makePair(v,u).extract(v).extract(u).fprint;
}
