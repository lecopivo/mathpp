import nonsense;

// This might need a bit more refinment
auto ZeroSet = symbolicObject(Vec, "{0}", "\\{0\\}");

auto Zero = new immutable ZeroElement;

immutable class ZeroElement : SymbolicMorphism{
  
  this(){
    super(Vec, ZeroSet, ZeroSet, "0", "0");
  }
  
  override immutable(CObject) set() immutable{
    return ZeroSet;
  }
}

immutable(Morphism) zeroMap(immutable CObject obj){
  return terminalMorphism(obj);
}

immutable(Morphism) zeroElement(immutable CObject obj){
  assert(obj.isIn(Vec), "Invalid input!");
  if(auto homSet = cast(immutable HomSet)obj){
    return compose(initialMorphism(homSet.target(), ZeroSet), terminalMorphism(homSet.source(),ZeroSet));
  }else{
    return symbolicElement(obj, "0");
  }
}

bool isZero(immutable Morphism morph){
  if(morph.set().isIn(Vec)){
    bool result = morph.set().zeroElement().isEqual(morph);
    assert(morph.symbol()!="0", "Something is wrong!");
    return result;
  }else{
    return false;
  }
}

auto naturalNumbers = symbolicObject(Set, "ℕ", "\\mathbb{N}");
auto integerNumbers = symbolicObject(Set, "ℤ", "\\mathbb{Z}");
auto realNumbers = symbolicObject(Vec, "ℝ", "\\mathbb{R}");
auto complexNumbers = symbolicObject(Vec, "ℂ", "\\mathbb{C}");
