#!/usr/bin/rdmd

import std.stdio;
import std.format;

import category;

string lformat(immutable IMorphism morph) {

  return morph.source().latex() ~ " " ~ morph.category()
    .latexArrow(morph.latex) ~ " " ~ morph.target().latex();
}

void fprint(immutable IElement elem) {
  auto morph = cast(immutable IMorphism)(elem);
  if (morph) {
    writefln("%s: %s %s %s", morph, morph.source(), morph.category().arrow(), morph.target());
  }
  else {
    writefln("%s ∈ %s", elem, elem.set());
  }
}

void main() {

  static X = new immutable CatObject(Set, "X");
  static Y = new immutable CatObject(Set, "Y");
  static Z = new immutable CatObject(Set, "Z");

  static U = new immutable CatObject(Vec, "U");
  static V = new immutable CatObject(Vec, "V");
  static W = new immutable CatObject(Vec, "W");

  static F = new immutable Morphism(Set, X, Y, "F");
  static G = new immutable Morphism(Set, X, Z, "G");
  static H = new immutable Morphism(Set, Y, Z, "H");

  static f = new immutable Morphism(Smooth, U, V, "f");
  static g = new immutable Morphism(Smooth, U, W, "g");
  static h = new immutable Morphism(Smooth, V, W, "h");
  static A = new immutable Morphism(Vec, U, V, "A");
  static B = new immutable Morphism(Vec, U, W, "B");
  static C = new immutable Morphism(Vec, V, W, "C");

  static x = new immutable Element(X, "x");
  static y = new immutable Element(Y, "y");
  static z = new immutable Element(Z, "z");

  static u = new immutable Element(U, "u");
  static v = new immutable Element(V, "v");
  static w = new immutable Element(W, "w");

  static HF = compose(H, F);
  static hf = compose(h, f);
  static Cf = compose(C, f);
  static fg = product(f, g);

  HF.fprint();
  hf.fprint();
  Cf.fprint();
  fg.fprint();

  static xi = new immutable Morphism(Smooth, U, V, "ξ");

  static pi0 = fg.target().projection(0);
  static pi1 = fg.target().projection(1);
  static Pi0 = productObject(X,Y).projection(0);

  pi0.fprint;
  pi1.fprint;
  Pi0.fprint;

  compose(pi0,fg)(u).extractElement(f).fprint;

  elementMap(f(u)).extractElement(f).fprint;
  hf(u).extractElement(h).fprint;
  
  fg.extractElement(f).fprint;
  auto foo = cast(immutable IMorphism)(fg.extractElement(f)(xi));
  foo(u).fprint;

  //writefln("%s: %s %s %s", Cf, Cf.source(), Cf.category().arrow(), Cf.target());
  // writefln(hf);
  // writefln(Cf);
}
