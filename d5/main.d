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

  auto pair = makePair(g, x);
  auto tmp1 = compose(eval(g.set()), pr.projection(1));

  compose(compose(tmp1.target(), pr.projection(0)), tmp1).contract()(pair).fprint;

  writeln();

  auto u2 = symbolicElement(U, "u'");

  auto XY = productObject(X, Y);
  auto xy = symbolicElement(productObject(X, Y), "xy");

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

  auto muhehe = compose(zzeta, compose(zeta, eta));

  muhehe.fprint;
  muhehe.grad()(u).fprint;

  //compose(zeta, eta).grad().grad().fprint;

  writeln();

  compose(zeta, eta.set()).grad()(eta).fprint;
  compose(zeta, eta.set()).grad()(eta)(eta2).extract(eta).extract(eta2).fprint;
  compose(zeta, eta.set()).grad()(eta)(eta2)(u).fprint;

  writeln();

  add(u, u2).fprint;
  add(u, u2).fprint;
  add(eta, eta2)(u).fprint;
  add(G, G)(x)(u).fprint;
  
  writeln();
  
  add(eta, eta.set()).fprint;
  add(eta.set(), eta).fprint;
  add(eta.set(), eta.set()).fprint;
  
  writeln();
  
  add(eta, eta2).extract(eta).fprint;
  add(eta, eta2).extract(eta2).fprint;
  add(eta, eta2).extract(eta).extract(eta2).fprint;
  add(eta, eta2).extract(eta2).extract(eta).fprint;
  
  add(eta, eta2).grad().fprint;
  
  writeln();
  
  add(eta, eta.set()).grad().fprint;
  add(eta.set(), eta).grad().fprint;
  
  writeln();
  
  terminalMorphism(U).fprint;
  terminalMorphism(U).grad().fprint;
  terminalMorphism(U).tangentMap().fprint;
  
  writeln();
  
  elementMap(v).fprint;
  elementMap(v).grad().fprint;
  auto zz = makePair(Zero,Zero);
  elementMap(v).tangentMap().fprint;
  elementMap(v).tangentMap()(zz).extract(zz).fprint;
  
  add(eta(u), eta2(u)).fprint;
  
  add(eta, eta2)(u).extract(u).fprint;
  
  product(eta, eta2)(u).fprint;
  product(eta, eta2)(u).extract(u).fprint;
  
  writeln();
  
  auto A = symbolicMorphism(Vec, U, Vec.homSet(U,V), "A");
  
  auto u3 = symbolicElement(U, "u''");
  
  A.contract.grad().fprint;
  
  // A.contract.grad()(u)(u2).fprint;
  // A(u)(u2).fprint;
  // A(u)(u2).extract(u).extract(u2).fprint;
  
  A.contract.grad()(u)(u2).extract(u2).extract(u).fprint;
  
  A.contract.grad.grad.fprint;
  A.contract.grad.grad()(u)(u2)(u3).extract(u3).extract(u2).extract(u).fprint;
  
  writeln();
  
  A.contract.grad.grad.grad.fprint;
  
  writeln();

  A.contract.grad.grad.fprint;
  auto tmp = cast(immutable ComposedMorphism)A.contract.grad.grad;
  tmp[0].fprint;
  tmp[0].grad.fprint;
  
  
  auto tmp2 = compose(tmp[0].tangentMap, tmp[1].tangentMap).projection(1);
  auto ee = symbolicElement(tmp2.source(), "ee");
  tmp2.curry()(u)(u2).extract(u2).extract(u).fprint;
  
  tmp2.curry()(u)(u2).extract(u2).extract(u).fprint;
  
  
  writeln();
  
  auto m1 = symbolicMorphism(Smooth, U, V, "m1");
  auto m2 = symbolicMorphism(Smooth, U, W, "m2");
  
  auto dm1 = symbolicMorphism(Smooth, U, V, "δm1");
  auto dm2 = symbolicMorphism(Smooth, U, W, "δm2");

  
  product(m1,m2).grad.fprint;
  
  writeln();
  
  product(m1, m2.set()).fprint;
  product(m1, m2.set())(m2).fprint;
  product(m1.set().zeroElement(), m2.set()).fprint;
  
  product(m1, m2.set()).grad().fprint;
  
  auto p = product(m1.set(), m2.set());
  auto ew = evalWith(m2, p.target());
  p.grad.fprint;
  
  p.uncurry.fprint;
  
  //product(m1, m2.set()).grad()(m2)(dm2).fprint;
  
  // elementMap(u).grad.fprint;
  // elementMap(u).grad.grad.grad.grad.fprint;
  // auto hoho = symbolicMorphism(Smooth, U, ZeroSet, "hoho");
  
  // hoho.fprint;
  // hoho.grad.fprint;
  // hoho.grad.grad.fprint;
  // hoho.grad.grad.grad.fprint;
  
  // auto B = symbolicMorphism(Vec, U, V, "B");
  // auto C = symbolicMorphism(Vec, U, V, "C");
  
  // writeln();
  
  // product(phi,psi).fprint;
  // product(phi,psi)(x).extract(x).fprint;
  // makePair(phi(x),psi(x)).extract(x).fprint;
  
  // writeln();
  
  // add(B,C).fprint;
  // add(B,C)(u).fprint;
  // add(B,C)(u).extract(u).fprint;
  // add(B,C)(u).extract(u).fprint;
}
