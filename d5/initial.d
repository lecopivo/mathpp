import nonsense;

bool isInitialObjectIn(immutable CObject obj, immutable Category cat){
  return obj.isTerminalObjectIn(Vec) && cat.isEqual(Vec);
}

bool isInitialMorphism(immutable Morphism morph){
  if(morph.source().isInitialObjectIn(morph.category())){
    return true; 
  }else{
    return false;
  }
}

immutable(Morphism) initialMorphism(immutable CObject obj, immutable CObject initObj){
  assert(initObj.isInitialObjectIn(obj.category()), ""~format!"Input object `%s` is not an initial object!"(obj.fsymbol));
  return symbolicMorphism(obj.category(), initObj, obj, "0", "0");
}

immutable(Morphism) initialMorphism(immutable CObject obj){
  return initialMorphism(obj, ZeroSet);
}

