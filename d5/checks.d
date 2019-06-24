import nonsense;

bool isIn(immutable Morphism c, immutable Category cat) {
  return meet(c.category(), cat).isEqual(cat);  
}

bool isIn(immutable CObject c, immutable Category cat) {
  return meet(c.category(), cat).isEqual(cat);
}

bool isElementOf(immutable Morphism m, immutable CObject set){
  return m.set().isSubsetOf(set);
}

bool isElement(immutable Morphism m){
  return m.source().isEqual(ZeroSet) && m.set().isEqual(m.target());
}

bool isMorphism(immutable Morphism m){
  // The compilcated definition is just to doulbe check everything is in order
  if(m.isElement){
    return false;
  }else{
    assert(m.set().isEqual(m.category().homSet(m.source(), m.target())), "" ~ format!"Something is wrong with `%s`! Investigate!"(m.fsymbol));
    return true;
  }
}

bool isIdentity(immutable Morphism m){
  if(cast(immutable Identity)(m)){
    return true;
  }else{
    return false;
  }
}

bool isProjection(immutable Morphism m){
  if(cast(immutable Projection)(m)){
    return true;
  }else{
    return false;
  }
}

bool isHomSet(immutable CObject obj){
  if(cast(immutable HomSet)(obj)){
    return true;
  }else{
    return false;
  }
}

bool isProductMorphism(immutable Morphism m){
  if(cast(immutable IProductMorphism)(m)){
    return true;
  }else{
    return false;
  }
}

bool isProductObject(immutable CObject obj){
  if(cast(immutable IProductObject)(obj)){
    return true;
  }else{
    return false;
  }
}
