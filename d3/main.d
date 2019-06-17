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
  x.extractSymbol(x)(x).print();
  writeln();
  y.extractSymbol(x).print();
  y.extractSymbol(x)(x).print();

  writeln();
  f(x).extractSymbol(x).print();
  f(x).extractSymbol(x)(x).print();
  writeln();
  f(x).extractSymbol(f).print();
  f(x).extractSymbol(f)(f).print();

  writeln();
  hf(x).extractSymbol(x).print();
  hf(x).extractSymbol(x)(x).print();
  writeln();
  hf(x).extractSymbol(f).print();
  hf(x).extractSymbol(f)(f).print();

  writeln();
  fg(x).extractSymbol(x).print();
  fg(x).extractSymbol(x)(x).print();
  writeln();
  fg(x).extractSymbol(f).print();
  fg(x).extractSymbol(f)(f).print();

  static auto xy = new immutable ProductElement([x, y]);

  static auto F = new immutable Morphism("F", prod(X, Y), Z);
  static auto G = new immutable Morphism("G", X, homset(Y, Z));
  
  static auto p0 = projection(0, X, Y);
  static auto p1 = projection(1, X, Y);

  static auto curry = F(xy).extractSymbol(y).extractSymbol(x).extractSymbol(F);
  static auto uncurry = compose(eval(Y, Z), product(compose(G, p0), p1)).extractSymbol(G);
  
  writeln();
  writeln("Curry F:");
  curry(F).print();
  static assert(curry(F)(x)(y).isEqual(F(xy)));
  writeln("Uncurry G:");
  uncurry(G).print();
  static assert(uncurry(G)(xy).isEqual(G(x)(y)));
  
  writeln();
  writeln("Curry∘Uncurry:");
  compose(curry,uncurry).print();
  compose(curry,uncurry)(G).print();
  compose(curry,uncurry)(G)(x)(y).extractSymbol(y).extractSymbol(x).print();
  

  // compose(curry, uncurry).print();
  // compose(uncurry, curry).print();
  //F.print();

}
