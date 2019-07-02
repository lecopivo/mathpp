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

  auto F = symbolicMorphism(Set, X, Set.homSet(Y, Z), "F");
  auto G = symbolicMorphism(Set, X, Smooth.homSet(U, V), "G");
  auto H = symbolicMorphism(Smooth, U, Set.homSet(X, V), "H");
  auto foo = symbolicMorphism(Smooth, U, Pol.homSet(V, W), "foo");
  auto bar = symbolicMorphism(Vec, U, Set.homSet(X, V), "bar");

  F.fprint;
  F.swapArguments.fprint;

  writeln();

  G.fprint;
  G.swapArguments.fprint;

  writeln();

  H.fprint;
  H.swapArguments().fprint;

  writeln();

  foo.fprint;
  foo.swapArguments().fprint;

  writeln();

  F(x)(y).fprint;
  F(x)(y).extract(x).fprint;

  auto x2 = symbolicElement(X, "x'");
  F(x)(g(x2)).extract(x2).fprint;
  F(x)(g(x)).extract(x).fprint;
  F(x)(g(x)).extract(x)(x).fprint;

  auto xi = symbolicMorphism(Set, X, Set.homSet(X, Y), "xi");

  writeln();

  xi.fprint;
  xi.contract.fprint;
  xi.contract()(x).fprint;

  writeln();

  auto pr = productObject(g.set(), g.source());

  auto pair = makePair(g,x);
  auto tmp1 = compose(eval(g.set()), pr.projection(1));

  compose(compose(tmp1.target(), pr.projection(0)), tmp1).contract()(pair).fprint;
  
  writeln();
  
  auto u2 = symbolicElement(U, "u'");
  
  auto XY = productObject(X,Y);
  auto xy = symbolicElement(productObject(X,Y), "xy");
  
  xy.projection(0).fprint;
  xy.projection(1).fprint;
  
  F(xy.projection(0))(xy.projection(1)).fprint;
  F(xy.projection(0))(xy.projection(1)).extract(xy).fprint;
  F.uncurry.curry.fprint;

  writeln();
  
  auto eta = symbolicMorphism(Smooth, U, V, "eta");
  auto eta2 = symbolicMorphism(Smooth, U, V, "eta2");
  auto zeta = symbolicMorphism(Smooth, V, W, "zeta");
  auto zzeta = symbolicMorphism(Smooth, W, V, "zzeta");
  
  eta.fprint;
  eta.tangentMap.fprint;
  eta.tangentMap.tangentMapToGrad.fprint;
  
  auto muhehe = compose(zzeta,compose(zeta,eta));
  
  muhehe.fprint;
  muhehe.grad()(u).fprint;
  
  compose(zeta,eta).grad().grad().fprint;
  
  writeln();
  
  compose(zeta, eta.set()).grad()(eta).fprint;
  compose(zeta, eta.set()).grad()(eta)(eta2).extract(eta).extract(eta2).fprint;
  compose(zeta, eta.set()).grad()(eta)(eta2)(u).fprint;
}
