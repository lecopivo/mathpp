import nonsense;

string fsymbol(immutable CObject obj){
  return obj.symbol() ~ " ∊ " ~ obj.category().symbol();
}

string fsymbol(immutable Morphism morph){
  import std.format;
  if(!morph.isElement){
    return format!"%s: %s %s %s"(morph.symbol(), morph.source().symbol(),
				 morph.category().arrow(), morph.target().symbol());
  }else{
    return morph.symbol() ~ " ∊ " ~ morph.set().fsymbol();
  }
}

string csymbol(immutable Morphism morph){
  if(auto cmorph = cast(immutable ComposedMorphism)morph){
    const int N = cast(int)cmorph.size();
    string result = morph.symbol();
    result ~= ": ";
    result ~= cmorph[N-1].source().symbol();
    for(int i=N-1;i>=0;i--){
      result ~= cmorph[i].category().arrow();
      result ~= cmorph[i].target().symbol();
    }
    return result;
  }else{
    return morph.fsymbol();
  }
}

string flatex(immutable CObject obj){
  return obj.latex() ~ " \\in " ~ obj.category().latex();
}

string flatex(immutable Morphism morph){
  import std.format;
  if(!morph.isElement){
    return format!"%s: %s %s %s"(morph.latex(), morph.source().latex(),
				 morph.category().latexArrow(morph.latex()), morph.target().latex());
  }else{
    return morph.latex() ~ " \\in " ~ morph.set().flatex();
  }
}


void fprint(immutable Morphism morph) {
  import std.stdio;

  writeln(morph.fsymbol());
}

void cprint(immutable Morphism morph) {
  import std.stdio;

  writeln(morph.csymbol());
}


void fprint(immutable CObject obj) {
  import std.stdio;

  writeln(obj.fsymbol());
}

void lprint(immutable Morphism morph){
  import std.stdio;

  writeln("\\begin{align}");
  writeln(morph.flatex());
  writeln("\\end{align}");
}
