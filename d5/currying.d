import nonsense;

immutable(Morphism) uncurry(immutable Morphism morph) {
  auto sndHomSet = cast(immutable HomSet) morph.target();
  assert(sndHomSet, "Invalid input!");

  auto X = morph.source();
  auto Y = sndHomSet.source();
  auto XY = productObject(X, Y);

  auto xy = symbolicElement(XY, "temporary_element_for_uncurry");



  return morph(xy.projection(0))(xy.projection(1)).extract(xy);
  
  // Old implementation
  // The following does: Contr((∘π1)∘(f∘π0))
  // return contract(compose(compose(morph.target(), XY.projection(1)),
  //     compose(morph, XY.projection(0))));
}

immutable(Morphism) curry(immutable Morphism morph) {
  auto pr = cast(immutable IProductObject) morph.source();
  assert(pr,
      "" ~ format!"Invalid input morphism `%s`, expected a morphism in the form `X✕Y→Z`"(
        morph.fsymbol));

  auto x = symbolicElement(pr[0], "temporary_element_x_for_curry");
  auto y = symbolicElement(pr[1], "temporary_element_y_for_curry");

  return morph(makePair(x, y)).extract(y).extract(x);
}
