import interfaces;
import category;

bool isIn(immutable ICategorical c, immutable ICategory cat) {
  return meet(c.category(), cat).isEqual(cat);
}

bool allIn(immutable IObject[] obj, immutable ICategory cat) {
  import std.algorithm;

  return obj.all!(o => o.isIn(cat));
}

bool allIn(immutable IMorphism[] morph, immutable ICategory cat) {
  import std.algorithm;

  return morph.all!(o => o.isIn(cat));
}

bool allSameSource(immutable IMorphism[] morph) {
  if (morph.length == 1) {
    return true;
  }
  else {
    return morph[0].source().isEqual(morph[1].source()) && allSameSource(morph[1 .. $]);
  }

}
