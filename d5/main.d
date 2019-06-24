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

  auto pi0 = productObject(Y,Z).projection(0);
  auto pi1 = productObject(Y,Z).projection(0);

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
  auto phi = symbolicMorphism(Set, X, Y, "phi", "\\phi");
  auto psi = symbolicMorphism(Set, X, Z, "psi", "\\psi");

  auto x = symbolicElement(X, "x");
  auto y = symbolicElement(Y, "y");
  auto z = symbolicElement(Z, "z");

  // product(phi,psi).fprint;
  // x.fprint;
  // y.fprint;
  // phi(x).fprint;
  // psi(x).fprint;
  // product(phi,psi)(x).fprint;
  
  // makePair(x,y).fprint;
  // product(phi,psi)(x).projection(0).fprint;

  // return;
  // x.fprint;
  // X.identity.fprint;
  // g.fprint;
  // f.fprint;

  // writeln();

  // compose(f, g).fprint;
  // compose(f, g.set()).fprint;
  // compose(f.set(), g.set()).fprint;
  
  //x.extract(elementMap(x)).fprint;
  // auto foo = g(x).extract(g);
  // foo.fprint;
  // writeln("........................");
  // auto foog = foo(g);
  // foog.fprint;

  // Test of that extracting and then applying should yield the same thing!
  assert(x.isEqual(x.extract(x)(x)));
  assert(y.isEqual(y.extract(x)(x)));
  assert(compose(f,g).isEqual(compose(f, g).extract(g)(g)));
  assert(g(x).isEqual(g(x).extract(x)(x)));
  assert(g(x).isEqual(g(x).extract(g)(g)));
  
  // Test of canceling projection applied on a product morphism
  assert(phi(x).isEqual(product(phi,psi)(x).projection(0)));
  assert(psi(x).isEqual(product(phi,psi)(x).projection(1)));
  
  // Test that all possible product constructions yield the same result
  auto phixpsi = product(phi,psi);
  assert(phixpsi.isEqual(product(phi.set(),psi)(phi)));
  assert(phixpsi.isEqual(product(phi,psi.set())(psi)));
  assert(phixpsi.isEqual(product(phi.set(),psi.set())(phi)(psi)));
  
  auto A = symbolicObject(Set, "A");
  auto a = symbolicElement(A, "a");
  auto u = symbolicElement(U, "u");
  
  auto F = symbolicMorphism(Set, A, Vec.homSet(U,V), "F");
  auto G = symbolicMorphism(Set, A, Vec.homSet(U,W), "G");
  
  // auto F = symbolicMorphism(Set, X, Set.homSet(X,Y), "F");

  product(F(a), G(a))(u).extract(a).fprint;

  // product(X,Y).fprint;
  // product(X,Y).projection(0).fprint;
  // product(X,Y).projection(1).fprint;

  // compose(pi0,product(f,g)).fprint;

  // product(f,g)(x).fprint;
  // pi0(product(f,g)(x)).fprint;

  // test1();
}
