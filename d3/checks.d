import set;

bool all_same_sources( immutable ISetMorphism[] morph){
  bool result = true;
  foreach(m; morph)
    result &= (m.source() == morph[0].source());
  return result;
}

bool are_composable( immutable ISetMorphism[] morph){
  bool result = true;
  const ulong N = morph.length;
  foreach(i; 1 .. N){
    // This is a bed check!!!
    result &= (morph[i-1].source().symbol() == morph[i].target().symbol());
  }
  return result;
}
