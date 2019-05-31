bool are_composable(Category, Morph...)() {
  import std.meta;
  import base;

  // All morphisms in the 
  static if (!allSatisfy!(Category.is_morphism, Morph))
    return false;

  static if (!(Morph.length >= 2))
    return false;

  static foreach (I, M; Morph[0 .. $ - 1])
    static if (!is(Morph[I].Source == Morph[I + 1].Target))
      return false;

  return true;
}

bool has_same_source(Category, Morph...)() {
  import std.meta;

  static if (Morph.length > 0) {
    bool result = allSatisfy!(Category.is_morphism, Morph);

    static foreach (i, M; Morph[0 .. $]) {
      result &=  is(M.Source == Morph[0].Source);
    }

    return result;
  }
  else {
    return true;
  }

}

bool has_same_target(Category, Morph...)() {
  import std.meta;

  static if (Morph.length > 0) {
    bool result = allSatisfy!(Category.is_morphism, Morph);

    static foreach (i, M; Morph[0 .. $]) {
      result &=  is(M.Target == Morph[0].Target);
    }

    return result;
  }
  else {
    return true;
  }

}
