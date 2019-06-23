#!/usr/bin/rdmd

import std.stdio;
import std.format;

import category;

string lformat(immutable IMorphism morph) {

  return morph.source().latex() ~ " " ~ morph.category()
    .latexArrow(morph.latex) ~ " " ~ morph.target().latex();
}

void problem1() {
  auto X = new immutable CatObject(Set, "X");
  auto Y = new immutable CatObject(Set, "Y");

  auto x = new immutable Element(X, "x");
  auto y = new immutable Element(Y, "y");

  auto f = product(X.identity(), constantMap(X, y));
  f.extractElement(y)(y).fprint; // segfault :(
}

void problem2() {

  auto X = new immutable CatObject(Set, "X");
  auto Y = new immutable CatObject(Set, "Y");

  auto x = new immutable Element(X, "x");
  auto y = new immutable Element(Y, "y");

  //auto f = constantMap(X, y);
  auto f = constantMap(X, y);
  assert(f.symbol() == f.extractElement(y)(y).symbol()); // The symbol is some exception message
  f.extractElement(y)(y).symbol().writeln;
}

void problem3() {
  auto X = new immutable CatObject(Set, "X");
  auto Y = new immutable CatObject(Set, "Y");

  auto f = new immutable Morphism(Set, X, Y, "f");
  auto x = new immutable Element(X, "x");

  f(x).extractElement(f).extractElement(x)(x).fprint; // segfault :(
}

void problem4() {
  auto X = new immutable CatObject(Set, "X");
  auto Y = new immutable CatObject(Set, "Y");
  auto Z = new immutable CatObject(Set, "Z");

  auto XY = productObject(X, Y);
  auto pi0 = XY.projection(0);
  auto pi1 = XY.projection(1);

  auto f = new immutable Morphism(Set, XY, Z, "f");
  auto g = new immutable Morphism(Set, X, Set.homSet(Y, Z), "g");

  auto x = new immutable Element(X, "x");
  auto y = new immutable Element(Y, "y");
  auto xy = new immutable Element(XY, "xy");

  auto curry = f(cList(x, y)).extractElement(y).extractElement(x).extractElement(f);
  auto uncurry = g(pi0(xy)).toMorph()(pi1(xy)).extractElement(xy).extractElement(g);

  curry.fprint;
  uncurry.fprint;

  compose(curry, uncurry)(g).toMorph()(x).toMorph()(y).fprint;
  compose(uncurry, curry)(f).toMorph()(xy).fprint; // This does not simplify fully :(
}

void problem5() {

  auto U = new immutable CatObject(Vec, "U");
  auto V = new immutable CatObject(Vec, "V");

  auto f = new immutable Morphism(Smooth, U, V, "f");

  writeln("Gradient: ");
  f.fprint;
  f.grad().fprint;

  writeln();

  writeln("Gradient → Tangent Map: ");
  f.fprint;
  tangentMap(f).fprint;
}

void problem6() {

  auto U = new immutable CatObject(Vec, "U");
  auto V = new immutable CatObject(Vec, "V");

  auto u = new immutable Element(U, "u");

  auto zeroMap = zeroSet.terminalMorphism(U);
  auto elemu = elementMap(u);
  auto A = new immutable Morphism(Vec, U, V, "A");

  zeroMap.fprint;
  elemu.fprint;
  A.fprint;

  writeln();
  
  zeroMap.grad.fprint;
  elemu.grad.fprint;
  A.grad.fprint;

  writeln();

  zeroMap.grad.grad.fprint;
  elemu.grad.grad.fprint;
  A.grad.grad.fprint;

  writeln();


  // //zeroMap.grad.set.isTerminalObjectIn2(Pol).writeln;

  // zeroMap.grad.fprint;

  A.grad.grad()(u).toMorph()(u).toMorph()(u).fprint;
}

void problem7(){

  auto U = new immutable CatObject(Vec, "U");
  auto V = new immutable CatObject(Vec, "V");

  auto u = new immutable Element(U, "u");

  auto f = new immutable Involution(Smooth, U, U, "f");
  auto g = new immutable Involution(Smooth, U, U, "g");

  auto inv = new immutable Inverse(f.set());

  f(u).fprint;
  f(f(u)).fprint;
  f(f(f(u))).fprint;

  inv(f).fprint;
  inv(f).toMorph()(u).fprint;

  inv.fprint;
  inv.grad.fprint;

  f.grad()(inv(f).toMorph()(u)).toMorph()(g(inv(f).toMorph()(u))).extractElement(u).extractElement(f).extractElement(g).fprint;
}

void main() {

  // writeln("\nProblem 1:");
  // problem1();

  // writeln("\nProblem 2:");
  // problem2();

  // writeln("\nProblem 3:");
  // problem3();

  // writeln("\nProblem 4:");
  // problem4();

  // writeln("\nProblem 5:");
  // problem5();

  // writeln("\nProblem 6:");
  // problem6();

  writeln("\nProblem 7:");
  problem7();


  // f(u).fprint;
  // f(u).extractElement(u).fprint;

  // auto foo = product(X.identity(), constantMap(X, y));

  // foo.fprint;
  // foo.extractElement(y).fprint;
  // auto bar = cast(immutable IComposedMorphism) foo.extractElement(y); //(u).fprint;
  // bar[1].category().writeln;
  // writeln("\nbar1");
  // bar[1].fprint;
  // auto bar2 = cast(immutable IProductMorphism) bar[1];
  // writeln("\nbar2[0]");
  // bar2[0].fprint;
  // bar2[0](y).fprint;

  // writeln("\nbar2[1]");
  // bar2[1].fprint;
  // bar2[1](y).fprint;

  // auto bar3 = product(bar2[0], bar2[1]);
  // writeln("\nbar3");
  // bar3.fprint;
  // auto ho = cast(immutable IOpElement)bar3(y);
  // //ho[1].symbol().writeln;
  // ho[1].fprint;
  // auto hi = ho[1];

  // string name = hi.symbol();

  // writeln(name.length);

  // auto elemy = elementMap(y);
  // writeln(elemy.set().isElement(elemy));

  // f(u).extractElement(f).fprint;
  // // f(u).extractElement(u).extractElement(f).fprint;
  // f(u).extractElement(f).extractElement(u).fprint;
  // auto foo = cast(immutable IComposedMorphism)f(u).extractElement(f).extractElement(u);
  // foo[1].fprint();

  // assert(f(u).extractElement(u)(u).isEqual(f(u)));
  // assert(f(u).extractElement(f)(f).isEqual(f(u)));

  // HF.fprint();
  // hf.fprint();
  // Cf.fprint();
  // fg.fprint();

  // auto bar = cast(immutable IComposedMorphism) f(u).extractElement(f);
  // bar.fprint;
  // bar[1].fprint;
  // bar[1].extractElement(u).fprint;

  // auto foo = product(X.identity(), constantMap(X, y));
  // foo.fprint;
  // auto fy = foo.extractElement(y);
  // fy.fprint;
  // auto fooy = fy(y);
  // fooy.fprint;

  // f(u).extractElement(f).extractElement(u).fprint;
  // f(u).extractElement(f).extractElement(u)(u).fprint;
  // fg(u).extractElement(f)(f).fprint;

  // auto gradf = new immutable Morphism(Smooth, U, Vec.homSet(U, V), "f'", "f'");
  // auto gradh = new immutable Morphism(Smooth, V, Vec.homSet(V, W), "h'", "h'");

  // auto tanf = gradientToTangentMap(f, gradf);
  // auto tanh = gradientToTangentMap(h, gradh);

  // static a = new immutable Element(U, "a");
  // static b = new immutable Element(U, "b");

  // tanf.fprint;
  // tanh.fprint;

  // auto foo = new immutable Morphism(Smooth, U, Smooth.homSet(V, W), "f");
  // auto bar = new immutable Morphism(Smooth, productObject(U, V), W, "f");

  // auto UV = productObject(U, V);
  // auto xv = new immutable Element(UV, "xv");

  // bool check = UV.isElement(xv);
  // writeln(check);

  // auto xx = UV.projection(0)(xv);
  // auto vv = UV.projection(1)(xv);

  // xv.fprint;
  // xx.fprint;
  // vv.fprint;

  // writeln(UV.isElement(xv));

  // foo(xx).toMorph()(vv).extractElement(xv).fprint;
  // auto curry = foo(xx).toMorph()(vv).extractElement(xv).extractElement(foo);

  // bar(cList(u, v)).fprint;
  // auto uncurry = bar(cList(u, v)).extractElement(v).extractElement(u).extractElement(bar);

  // curry.fprint;
  // uncurry.fprint;

  // compose(curry, uncurry).fprint;
  // compose(curry, uncurry)(bar).fprint;

  // auto pi0  = UU.projection(0);
  // pi0.fprint;
  // pi0(xv).fprint;
  // auto xx  = UU.projection(0)(xv);
  // xx.fprint;

  // tanf(a).fprint;
  // tanf(a).toMorph()(b).fprint;

  //  compose(tanh, tanf).fprint;

  // f(u).extractElement(u).fprint;
  // f(u).extractElement(f).extractElement(u).fprint;
  // static xi = new immutable Morphism(Smooth, U, V, "ξ");

  // static pi0 = fg.target().projection(0);
  // static pi1 = fg.target().projection(1);
  // static Pi0 = productObject(X,Y).projection(0);

  // pi0.fprint;
  // pi1.fprint;
  // Pi0.fprint;

  // compose(pi0,fg)(u).extractElement(f).fprint;

  // elementMap(f(u)).extractElement(f).fprint;
  // hf(u).extractElement(h).fprint;

  // fg.extractElement(f).fprint;
  // auto foo = cast(immutable IMorphism)(fg.extractElement(f)(xi));
  // foo(u).fprint;

  //writefln("%s: %s %s %s", Cf, Cf.source(), Cf.category().arrow(), Cf.target());
  // writefln(hf);
  // writefln(Cf);
}
