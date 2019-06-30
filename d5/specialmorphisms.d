import nonsense;

immutable(Morphism) swapArguments(immutable Morphism morph){

  auto homSet = cast(immutable HomSet)morph.target();
  auto symMorph = symbolicElement(morph.set(), "template_morph");
  auto x = symbolicElement(morph.source(), "template_x");
  auto y = symbolicElement(homSet.source(), "template_y");

  return symMorph(x)(y).extract(x).extract(y).extract(symMorph)(morph);
}
