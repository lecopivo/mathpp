import category;

import std.algorithm;
import std.array;

// immutable(IMorphism) replace(immutable IComposeMorphism morph, int start, int end,
//     immutable IMorphism newMorph) {
//   return ;
// }

// // Basic simplification extends initial and terminal morphisms.
// // and collapses projections applied on product morphisms
// immutable(IMorphism) basicSimplify(immutable IMorphism morphism) {

//   if (!cast(immutable IComposedMorphism)(morphism))
//     return morphism;

//   auto morph = cast(immutable IComposedMorphism)(morphism);

//   const int N = morph.size();

//   auto cat = morph.category();

//   if (cat.hasTerminalObject()) {
//     auto terminal = cat.terminalObject();
//     // check for initial object
//     for (int i = 0; i < N; i++) {
//       if (morph[i].source().isEqual(terminal)) {
//         auto m = morph.replace(i + 1, N, terminal.terminalMorphism(morph[N - 1].source()));
//         return basicSimplify(m);
//       }
//     }
//   }
// }

immutable(IMorphism) expandComposition(immutable IMorphism morphism) {

  if (!isComposedMorphism(morphism)) {
    return morphism;
  }
  else {

    auto morph = cast(immutable IComposedMorphism)(morphism);

    if (!any!(m => isComposedMorphism(m))(morph.args())) {
      return morph;
    }
    else {

      auto morphs = morph.args().map!(m => isComposedMorphism(m)
          ? (cast(immutable IComposedMorphism)(m)).args() : [m]).join();
      auto cat = morph.category();
      return cat.compose(morphs).expandComposition();
    }
  }
}

immutable(IMorphism) removeIdentities(immutable IMorphism morphism) {

  if (!isComposedMorphism(morphism)) {
    return morphism;
  }
  else {

    auto morph = cast(immutable IComposedMorphism)(morphism);

    if (!any!(m => isIdentity(m))(morph.args())) {
      return morph;
    }
    else {

      auto morphs = filter!(m => !isIdentity(m))(morph.args()).array;

      if (morphs.length == 0) {
        return morph.source().identity();
      }
      else if (morphs.length == 1) {
        return morphs[0];
      }
      else {
        return morph.category().compose(morphs);
      }
    }
  }
}

immutable(IMorphism) collapseProjection(immutable IMorphism morphism) {

  if (!isComposedMorphism(morphism)) {
    return morphism;
  }
  else {

    auto morph = cast(immutable IComposedMorphism)(morphism);

    for (int i = 0; i < morph.size() - 1; i++) {

      if (morph[i].isProjection() && morph[i + 1].isProductMorphism()) {
        auto morphs = morph.args();
        auto proj = cast(immutable Projection)(morph[i]);
        auto prodMorph = cast(immutable IProductMorphism)(morph[i + 1]);
        auto newMorphs = morphs[0 .. i] ~ prodMorph[proj.index()] ~ morphs[i + 2 .. $];
        if (newMorphs.length == 1)
          return newMorphs[0];
        else
          return morph.category().compose(newMorphs).collapseProjection();
      }
    }

    return morph;
  }
}

immutable(IMorphism) expandTerminalMorphism(immutable IMorphism morphism) {

  if (!isComposedMorphism(morphism)) {
    return morphism;
  }
  else {

    auto morph = cast(immutable IComposedMorphism)(morphism);
    auto cat = morph.category();

    for (int i = 0; i < morph.size() - 2; i++) {
      if (morph[i].source().isTerminalObjectIn(cat)) {

        auto terminalMorph = cat.terminalObject().terminalMorphism(morph.source());

        return cat.compose(morph.args[0 .. (i + 1)] ~ terminalMorph);
      }

    }
    return morph;
  }
}

immutable(IMorphism) expandInitialMorphism(immutable IMorphism morphism) {

  if (!isComposedMorphism(morphism)) {
    return morphism;
  }
  else {

    auto morph = cast(immutable IComposedMorphism)(morphism);
    auto cat = morph.category();

    for (int i = 1; i < morph.size(); i++) {
      if (morph[i].source().isInitialObjectIn(cat)) {

        auto initialMorph = cat.initialObject().initialMorphism(morph.target());

        if (i == morph.size() - 1)
          return initialMorph;
        else
          return cat.compose(initialMorph ~ morph.args[(i + 1) .. $]);
      }
    }

    return morph;
  }
}
