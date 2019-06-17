import std.stdio;
import set;
import hash;

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

  static auto pi0 = projection(0, Y, Z);
  static auto pi1 = projection(1, Y, Z);

  writeln();
  writeln("Projection: ");

  pi0.print();
  pi1.print();

  static auto hf = compose(h, f);
  static auto fg = product(f, g);

  writeln();
  writeln("Composition and product: ");

  hf.print();
  fg.print();

  writeln();
  writeln("Symbol extraction: ");
  
  x.extractSymbol(x).print();
  y.extractSymbol(x).print();
  hf(x).extractSymbol(x).print();
  hf(x).extractSymbol(f).extractSymbol(x).print();
  fg(x).extractSymbol(x).print();
  fg(x).extractSymbol(f).print();
  f(x).extractSymbol(x).print();
  f(x).extractSymbol(f).print();


  writeln((hf(x).extractSymbol(f).extractSymbol(x))(x));
}
