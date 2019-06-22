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

    auto morph = cast(immutable IOpMorphism)(morphism);

    string result = "";

    for (int i = cast(int) morph.size() - 1; i >= 0; i--) {
      auto m = morph[i];
      result ~= m.source().latex() ~ " " ~ m.category().latexArrow(m.latex()) ~ " ";
    }
    result ~= morph[0].target().latex();

    return result;
  }
}

void fprint(immutable IElement elem) {
  import std.stdio;

  if (auto morph = cast(immutable IMorphism)(elem)) {
    writefln("%s: %s %s %s", morph.symbol(), morph.source().symbol(),
        morph.category().arrow(), morph.target().symbol());
  }
  else {
    writefln("%s ∊ %s", elem.symbol(), elem.set().symbol());
  }
}

void lprint(immutable IElement elem) {
  elem.lpretty.lwriteln;
}


void cprint(immutable IElement elem) {
  if(auto morph = cast(immutable IMorphism)(elem)){
    morph.cpretty.lwriteln;
  }else{
    elem.lprint;
  }
}
