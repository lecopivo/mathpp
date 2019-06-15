import std.stdio;
import set;

void main() {

  static const auto X = new immutable SetObject("X");
  static const auto Y = new immutable SetObject("Y");
  static const auto Z = new immutable SetObject("Z");

  static const auto x = new immutable Element("x", X);
  static const auto y = new immutable Element("y", Y);
  static const auto z = new immutable Element("z", Z);

  static auto f = new immutable Morphism("f", X, Y);
  static auto g = new immutable Morphism("g", X, Z);
  static auto h = new immutable Morphism("h", Y, Z);
  static auto F = new immutable Morphism("F", X, X);

  static auto C = new immutable Constant(X, Y);

  static auto idX = X.identity();

  static immutable ISetMorphism pi0 = new immutable Projection(0, [Y, Z]);
  static immutable ISetMorphism pi1 = new immutable Projection(1, [Y, Z]);

  static auto hf = new immutable ComposedMorphism([h, f, F, idX]);
  static auto fg = new immutable ProductMorphism([f, g]);

  pi0.print();
  fg.print();
  writeln([pi0, fg]);

  static auto pi0fg = new immutable ComposedMorphism([pi0, fg]);

  fg.print();
  writeln(fg(x).symbol());
  pi0fg.print();
  writeln(pi0fg(x).symbol());

  C.print();
  static const auto cx = C(x);
  cx.print();
  writeln(cx(y).symbol());

  hf.print();
  writeln(hf(x).symbol());

  writeln("Hello Worlddd!");

}
