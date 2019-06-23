import nonsense;

// This might need a bit more refinment
auto ZeroSet = symbolicObject(Vec, "{0}", "\\{0\\}");

auto Zero = symbolicElement(ZeroSet, "0", "0");

immutable(Morphism) zeroMap(immutable CObject obj){
  return symbolicMorphism(obj.category(), obj, ZeroSet, "0", "0");
}
