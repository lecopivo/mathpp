import nonsense;



immutable(Morphism) constantMap(immutable CObject src, immutable Morphism elem){
  return compose( elementMap(elem) ,zeroMap(src));
}
