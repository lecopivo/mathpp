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
  return symbolicMorphism(obj.category(), obj, ZeroSet, "0", "0");
}
