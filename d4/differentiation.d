import category;

import std.format;

immutable(ICategory) changeOrder(immutable ICategory cat, int d) {

  if (cast(immutable VecCategory)(cat)) {
    return Vec;
  }
  else if (cast(immutable PolCategory)(cat)) {
    return Pol;
  }
  else if (cast(immutable DiffCategory)(cat)) {
    auto diff = cast(immutable DiffCategory)(cat);
    return Diff(diff.order() - 1);
  }
  else if (cast(immutable SetCategory)(cat)) {
    return Set;
  }
  else {
    assert(false, format!"Encountered unknown category: %s"(cat));
  }
}

interface IHasTangentMap {
  immutable(IMorphism) tangentMap() immutable;
}

interface IHasGradient {
  immutable(IMorphism) gradient() immutable;
}

immutable(IMorphism) tangentMap(immutable IMorphism morph) {
  return gradientToTangentMap(morph, grad(morph));
}

immutable(IMorphism) grad(immutable IMorphism morph) {
  auto g = new immutable Gradient(morph.set());
  return g(morph);
}

immutable(IMorphism) gradientToTangentMap(immutable IMorphism morph, immutable IMorphism grad) {

  auto src = morph.source();
  auto Tsrc = productObject(src, src);
  auto xv = new immutable Element(Tsrc, "temporary_element_for_differentiation");
  auto x = Tsrc.projection(0)(xv);
  auto v = Tsrc.projection(1)(xv);

  auto fx = morph(x);
  auto gradx = cast(immutable IMorphism) grad(x);
  auto tangent = cList(fx, gradx(v));

  return tangent.extractElement(xv);
}

immutable(IMorphism) tangentMapToGradient(immutable IMorphism morph) {

  assert(morph.source().isProductObject(), "Source has to be a product object!");
  assert(morph.target().isProductObject(), "Target has to be a product object!");

  auto src = cast(immutable IProductObject)(morph.source());
  auto trg = cast(immutable IProductObject)(morph.target());

  auto x = new immutable Element(src[0], "temporary_element_for_differentiation_x");
  auto v = new immutable Element(src[1], "temporary_element_for_differentiation_v");

  auto pi1 = trg.projection(1);

  return pi1(morph(cList(x, v))).extractElement(v).extractElement(x);
}

// immutable class TangentMap : Morphism {

//   this(immutable IHomSet homSet) {

//     auto mSrc = homSet.source();
//     auto mTrg = homSet.target();
//     auto targetCategory = homSet.morphismCategory().changeOrder(-1);
//     auto targetHomSet = targetCategory.homSet(productObject(mSrc, mSrc), productObject(mTrg, mTrg));

//     assert(mSrc.isIn(Vec) && mTrg.isIn(Vec), "" ~ format!"Tangent map can be computed only for functions between vector spaces! Fuctions of type `%s` are not differentiable!"(
//         homSet));
//     assert(meet([Diff(1), homSet.morphismCategory()]).isEqual(Diff(1)),
//         "Functions on the input are not differentiable!");

//     super(Smooth, homSet, targetHomSet, "T", "T");
//   }

//   override immutable(IMorphism) opCall(immutable IElement elem) immutable {
//     assert(source().isElement(elem),
//         "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

//     auto morph = cast(immutable IMorphism)(elem);

//     auto hasTangentMap = cast(immutable IHasTangentMap)(elem);
//     if (hasTangentMap) {
//       return hasTangentMap.tangentMap();
//     }

//     if (isComposedMorphism(morph)) {
//       auto cmorph = cast(immutable IOpMorphism)(morph);
//       immutable(IMorphism)[] tmorphs;
//       for (int i = 0; i < cmorph.size(); i++) {
//         tmorphs ~= tangentMap(cmorph[i]);
//       }
//       return compose(tmorphs);
//     }

//     // auto hasGradient = cast(immutable IHasGradient)(elem);
//     // if(hasGradient){
//     //   auto morph = cast(immutable IMorphisms)(elem);
//     //   return gradientToTangentMap(elem, hasGradient.gradient());
//     // }

//     return cast(immutable IMorphism) evaluate(this, elem);
//   }
// }

immutable class Gradient : Morphism {

  this(immutable IHomSet homSet) {

    auto mSrc = homSet.source();
    auto mTrg = homSet.target();

    assert(mSrc.isIn(Vec) && mTrg.isIn(Vec), "" ~ format!"Tangent map can be computed only for functions between vector spaces! Fuctions of type `%s` are not differentiable!"(
        homSet));

    auto targetCategory = meet([Pol, homSet.morphismCategory().changeOrder(-1)]);
    auto targetHomSet = targetCategory.homSet(mSrc, Vec.homSet(mSrc, mTrg));

    assert(meet([Diff(1), homSet.morphismCategory()]).isEqual(Diff(1)),
        "Functions on the input are not differentiable!");

    super(Smooth, homSet, targetHomSet, "∇", "\\nabla");
  }

  override immutable(IMorphism) opCall(immutable IElement elem) immutable {
    assert(source().isElement(elem),
        "" ~ format!"Input `%s` in not an element of the source `%s`!"(elem, source()));

    auto morph = cast(immutable IMorphism)(elem);

    if (morph.source().isEqual(zeroSet)) {
      return zeroSet.initialMorphism(Vec.homSet(zeroSet, morph.target()));
    }

    // // This case is covered by the linear map!
    if(morph.target().isTerminalObjectIn2(Vec)){
      return new immutable Morphism(Vec, morph.source(), Vec.homSet(morph.source(), morph.target()), "0");
    }

    if(morph.isIn(Vec)){
      return constantMap(morph.source(), morph);
    }

    if(morph.isComposedMorphism()){
      auto opmorph = cast(immutable IOpMorphism)(morph);
      immutable(IMorphism)[] tmorphs;
      foreach(i; 0 .. opmorph.size){
	tmorphs ~= opmorph[i].tangentMap;
      }
      return compose(tmorphs).tangentMapToGradient;
    }

    if(morph.isProductMorphism()){
      auto opmorph = cast(immutable IOpMorphism)(morph);
      immutable(IMorphism)[] tmorphs;
      foreach(i; 0 .. opmorph.size){
	tmorphs ~= opmorph[i].grad;
      }
      return productResult(product(tmorphs));
    }

    return cast(immutable IMorphism) evaluate(this, elem);
  }
}
