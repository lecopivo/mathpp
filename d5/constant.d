import nonsense;

immutable(Morphism) constantMap(immutable CObject src, immutable Morphism elem) {
  return compose(elementMap(elem), zeroMap(src));
}

immutable(Morphism) makeConstant(immutable CObject X, immutable CObject Y) {

  auto mem = makeElementMap(X);

  return compose(compose(mem.target(), terminalMorphism(Y)), mem);
}
