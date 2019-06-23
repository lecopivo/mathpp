import category;



immutable(IElement) zeroElement(immutable IObject obj){

  assert(obj.isIn(Vec), "Only vector spaces have zero element!");

  if(auto homSet = cast(immutable IHomSet)(obj)){
    return zeroMorphism(homSet.source(),homSet.target());
  }else{
    return new immutable Element(obj, "0");
  }
}

immutable(IMorphism) zeroMorphism(immutable IObject source, immutable IObject target){
  return compose( new immutable Morphism(Vec, zeroSet, target, "0"), new immutable Morphism(Vec, source, zeroSet, "0"));
}
