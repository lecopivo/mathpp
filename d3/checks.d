import set;

bool all_same_sources( immutable ISetMorphism[] morph){
  bool result = true;
  foreach(m; morph)
    result &= (m.source().isEqual(m.source()));
  return result;
}

bool are_composable( immutable ISetMorphism[] morph){
  bool result = true;
  const ulong N = morph.length;
  foreach(i; 1 .. N){
    result &= (morph[i-1].source().isEqual(morph[i].target()));
  }
  return result;
}


bool is_homset(immutable ISetObject obj){
  auto o = cast(immutable HomSet)(obj);
  if(o){
    return true;
  }else{
    return false;
  }
}
