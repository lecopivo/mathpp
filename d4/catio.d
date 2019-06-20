import category;

void lwriteln(string sp = "", Xs...)(Xs xs) {
  import std.stdio;

  writeln("\\begin{align}");
  foreach (i, x; xs) {

    if (i != 0)
      write(sp);

    static if (__traits(hasMember, x, "latex")) {
      write(x.latex());
    }
    else {
      write(x);
    }

  }
  writeln();
  writeln("\\end{align}");
}

string lpretty(immutable IElement elem) {
  auto morph = cast(immutable IMorphism)(elem);
  if (morph) {
    return morph.source().latex() ~ " " ~ morph.category()
      .latexArrow(morph.latex()) ~ " " ~ morph.target().latex();
  }
  else {
    return elem.latex() ~ " \\in " ~ elem.set().latex();
  }
}

string lpretty(immutable IObject obj) {
  return obj.latex() ~ " \\in " ~ obj.category().latex();
}

string cpretty(immutable IMorphism morphism) {

  if (!isComposedMorphism(morphism)) {
    return lpretty(morphism);
  }
  else {

    auto morph = cast(immutable IComposedMorphism)(morphism);

    string result = "";

    for (int i = cast(int) morph.size() - 1; i >= 0; i--) {
      auto m = morph[i];
      result ~= m.source().latex() ~ " " ~ m.category().latexArrow(m.latex()) ~ " ";
    }
    result ~= morph[0].target().latex();

    return result;
  }
}