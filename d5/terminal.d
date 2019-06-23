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

immutable(Morphism) terminalMorphism(immutable CObject obj){
  assert(obj.isTerminalObjectIn(Set), "Input object is not a terminal object!");
  return new immutable SymbolicMorphism(obj.category(), obj, ZeroSet, "0", "0");
}
