import nonsense;

immutable(Morphism) swapArguments(immutable Morphism morph) {

  auto evl = eval(morph.target());
  auto omorph = compose(evl.target(), morph);

  return compose(omorph, evl);
}
