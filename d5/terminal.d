import nonsense;

bool isTerminalObjectIn(immutable CObject obj, immutable Category cat) {

  if (obj.isEqual(ZeroSet)) {
    return true;
  }
  else if (auto homSet = cast(immutable HomSet)(obj)) {

    auto hcat = homSet.morphismCategory();

    return homSet.isIn(cat) && homSet.target.isTerminalObjectIn(hcat);
  }
  else {
    return false;
  }
}

bool isTerminalMorphism(immutable Morphism morph){
  if(morph.target().isTerminalObjectIn(morph.category())){
    return true;
  }else{
    return false;
  }
}

immutable(Morphism) terminalMorphism(immutable CObject obj, immutable CObject trmObj){
  assert(trmObj.isTerminalObjectIn(obj.category()), ""~format!"Input object `%s` is not a terminal object!"(obj.fsymbol));
  return new immutable SymbolicMorphism(obj.category(), obj, trmObj, "0", "0");
}

immutable(Morphism) terminalMorphism(immutable CObject obj){
  return terminalMorphism(obj, ZeroSet);
}

