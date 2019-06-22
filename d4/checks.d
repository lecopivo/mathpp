import interfaces;
import category;

import std.traits;

bool isIn(immutable IMorphism c, immutable ICategory cat) {
  return meet(c.category(), cat).isEqual(cat);
}

bool isIn(immutable IObject c, immutable ICategory cat) {
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

bool areComposableIn(immutable IMorphism[] morph, immutable ICategory cat) {

  bool result = morph.allIn(cat);
  for (int i = 0; i < morph.length - 1; i++) {
    import std.stdio;

    result &= morph[i].source().isEqual(morph[i + 1].target());
  }
  return result;
}

bool isInitialObjectIn(immutable IObject obj, immutable ICategory cat) {

  if (cat.hasInitialObject() && cat.initialObject().isEqual(obj)) {

    return true;

  }
  else if (auto cobj = cast(immutable CartesianProductObject)(obj)) {

    return allSatisfy!(o => o.isInitialObjectIn(cat))(cobj);

  }
  else if (auto homSet = cast(immutable IHomSet)(obj)) {

    if (cat.isEqual(Set)) {
      auto hcat = homSet.morphismCategory();

      return homSet.isIn(cat) && homSet.target.isInitialObjectIn(cat);
    }

    if (cat.isEqual(Vec)) {
      return obj.isTerminalObjectIn(cat);
    }

    return false;

  }
  else {

    return false;

  }
}

bool isTerminalObjectIn(immutable IObject obj, immutable ICategory cat) {

  if (cat.hasTerminalObject() && cat.terminalObject().isEqual(obj)) {

    return true;

  }
  else if (auto cobj = cast(immutable CartesianProductObject)(obj)) {

    return allSatisfy!(o => o.isTerminalObjectIn(cat))(cobj);

  }
  else if (auto homSet = cast(immutable IHomSet)(obj)) {

    auto hcat = homSet.morphismCategory();

    return homSet.isIn(cat) && (homSet.target.isTerminalObjectIn(hcat)
        || homSet.source.isInitialObjectIn(hcat));

  }
  else {

    return false;

  }
}

bool allSatisfy(alias pred, X)(immutable X x)
    if (hasMember!(X, "opIndex") && hasMember!(X, "size")) {

  bool result = true;
  foreach (i; 0 .. x.size())
    result &= pred(x[i]);
  return result;
}

bool anySatisfy(alias pred, X)(immutable X x)
    if (hasMember!(X, "opIndex") && hasMember!(X, "size")) {

  foreach (i; 0 .. x.size())
    if (pred(x[i]))
      return true;
  return false;
}
