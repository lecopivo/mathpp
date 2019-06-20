import std.stdio;
import std.format;

import category;

string lformat(immutable IMorphism morph) {

  return morph.source().latex() ~ " " ~ morph.category()
    .latexArrow(morph.latex) ~ " " ~ morph.target().latex();
}

void main() {

  auto set = cast(immutable ISymbolic)(Set);

  writeln("Categories: ");

  writeln(Set.latex);
  writeln(Diff(2).latex);
  writeln(Smooth.latex);
  writeln(Vec.latex);

  writeln();
  writeln("Objects: ");

  static X = new immutable CatObject(Set, "X");
  static Y = new immutable CatObject(Set, "Y");
  static Z = new immutable CatObject(Set, "Z");
  
  static U = new immutable CatObject(Vec, "X");
  static V = new immutable CatObject(Vec, "Y");
  static W = new immutable CatObject(Vec, "Z");


  writeln(X.latex);
  writeln(Y.latex);
  writeln(Z.latex);

  writeln();
  writeln("Morphisms: ");

  static set_f = new immutable Morphism(Set, X, Y, "f");
  static diff_f = new immutable Morphism(Smooth, U, V, "f");
  static vec_f = new immutable Morphism(Vec, U, V, "f");

  writeln(set_f.lformat);
  writeln(diff_f.lformat);
  writeln(vec_f.lformat);

  writeln("Hello World!");
}
