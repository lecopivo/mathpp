#include <cassert>
#include <cmath>
#include <iostream>

#include <mathpp/category>
#include <mathpp/meta>

#include "tests.h"

using namespace mathpp;

/* @brief Test a category of the provided morphisms
 *
 * Provide two morphisms from the same category, such that they compose as
 * `morphSnd | morphFst` but do not compose as `morphFst | morph Snd`
 * Also they should not share the same Source object or Target object!
 *
 * @tparm MorphSnd Second morphism
 * @tparm MorphFst First morphism
 */
template <class MorphSnd, class MorphFst>
void static_test_of_category() {

  static_assert(has_category<MorphSnd>(),
                "MorphFst does not have a valid category!");

  using Category = typename std::decay_t<MorphFst>::Category;

  static_assert(is_category<Category>(),
                "MorphFst::Category is not a valid category!");
  static_assert(in_category<MorphFst, Category>(),
                "MorphFst claims it is in a categeory but it is not!");

  static_assert(is_morphism<MorphFst>(), "MorphFst is not a morphism!");
  static_assert(is_morphism<MorphSnd>(), "MorphSnd is not a morphism!");
  static_assert(in_same_category<MorphSnd, MorphFst>(),
                "MorphSnd and MorphFst are not in the same category!");

  static_assert(
      !has_same_source<MorphFst, MorphSnd>(),
      "For this test MorphSnd and MorphFst should not share the same Source!");
  static_assert(
      !has_same_target<MorphFst, MorphSnd>(),
      "For this test MorphSnd and MorphFst should not share the same Target!");
  static_assert(
      !in_same_hom_set<MorphFst, MorphSnd>(),
      "For this test MorphSnd and MorphFst should not bet in the same HomSet");

  static_assert(are_composable<MorphSnd, MorphFst>(),
                "MorphSnd and MorphFst should be composable, i.e. `morphSnd | "
                "morphFst` should be valid");
  static_assert(!are_composable<MorphFst, MorphSnd>(),
                "MorphFst and MorphSnd should not be composable, i.e. "
                "`morphFst | morphSnd` should not be valid");

  using Composition =
      decltype(std::declval<MorphSnd>() | std::declval<MorphFst>());

  static_assert(is_morphism<Composition>(), "Composition is not morphism!");
  static_assert(has_same_source<Composition, MorphFst>(),
                "Composed morphism should have the same Source as MorphFst");
  static_assert(has_same_target<Composition, MorphSnd>(),
                "Composed morphism should have the same Target as MorphSnd");
}

template <class MorphSnd, class MorphFst>
void dynamic_test_of_category(MorphSnd morphSnd, MorphFst morphFst) {

  assert(is_morphism(morphFst));
  assert(is_morphism(morphSnd));

  static_assert(IS_VALID2(morphSnd, morphFst, morphSnd | morphFst),
                "Composition `morphSnd | morphFst` should be valid!");
  static_assert(!IS_VALID2(morphSnd, morphFst, morphFst | morphSnd),
                "Composition `morphFst | morphSnd` should not be valid!");

  auto composition = morphSnd | morphFst;

  assert(!in_same_hom_set(morphFst, morphSnd));
  assert(has_same_source(composition, morphFst));
  assert(has_same_target(composition, morphSnd));

  // add buch of other tests
}

// auxiliary tags
struct One {};
struct Two {};
struct Three {};

template<class T>
struct TypeObject{
  
};

int main() {

  auto object1   = Cat::Object<One>{};
  auto object2   = Cat::Object<Two>{};
  auto object3   = Cat::Object<Three>{};
  auto morphFst  = Cat::Morphism{object1, object2, One{}};
  auto morphSnd  = Cat::Morphism{object2, object3, Two{}};
  using MorphFst = std::decay_t<decltype(morphFst)>;
  using MorphSnd = std::decay_t<decltype(morphSnd)>;
  static_test_of_category<MorphSnd, MorphFst>();
  static_test_of_category<MorphSnd &, MorphFst &>();
  static_test_of_category<MorphSnd const &, MorphFst>();
  dynamic_test_of_category(morphSnd, morphFst);

  return 0;
}
