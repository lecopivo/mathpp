#pragma once

#include "../Cat.h"
#include "../utils.h"

#include "test_settings.h"

namespace mathpp::test_Cat {

template <class C>
void test_category() {
  static_assert(is_category<C>(), "C is not a category!");
}

//   ___  _     _        _
//  / _ \| |__ (_)___ __| |_
// | (_) | '_ \| / -_) _|  _|
//  \___/|_.__// \___\__|\__|
//           |__/

template <class Obj>
void test_object() {
  static_assert(!std::is_reference_v<Obj>,
                "Object should not be a reference type!");
  static_assert(HAS_TYPE(Obj, Category), "Object does not have `Category`");
  test_category<typename Obj::Category>();
  static_assert(has_category<Obj>(), "Object should define category!");
  static_assert(is_object<Obj>(), "Should be an object!");
  static_assert(!std::is_reference_v<typename Obj::Category>,
                "Obj::Category should not be a reference type!");
  static_assert((sizeof(Obj) <= test::max_object_size),
                "Size of an object exceeds allowed size!");
}

template <class Obj>
void test_object(Obj const &) {
  test_object<Obj>();
}

//  __  __              _    _
// |  \/  |___ _ _ _ __| |_ (_)____ __
// | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|

template <class Morph>
void test_morphism() {
  static_assert(!std::is_reference_v<Morph>,
                "Morphism should not be a reference type!");

  // Does it satisfy type requirement for a Cat::Morph ?
  static_assert(HAS_TYPE(Morph, Category), "Morphism does not have `Source`");
  static_assert(HAS_TYPE(Morph, Source), "Morphism does not have `Source`");
  static_assert(HAS_TYPE(Morph, Target), "Morphism does not have `Target`");
  static_assert(HAS_MEMBER(Morph, source), "Morphism does not have `source`");
  static_assert(HAS_MEMBER(Morph, target), "Morphism does not have `target`");

  // Is it really a morphism in its category?
  static_assert(is_morphism<Morph>(), "Should be morphism!");

  // Is Source and Target valid?
  test_object<typename Morph::Source>();
  test_object<typename Morph::Target>();

  // Morhism should be a light object and not store too much data.
  static_assert((sizeof(Morph) <= test::max_morphism_size),
                "Size of a morphism exceeds allowed size!");
}

template <class Morph>
void test_morphism(Morph const &morph) {
  test_morphism<Morph>();
}

template <class MorphSnd, class MorphFst>
void test_morphism() {
  // Test both morhisms on their own
  test_morphism<MorphFst>();
  test_morphism<MorphSnd>();

  // Test if composition is possible
  static_assert(are_composable<MorphSnd, MorphFst>(),
                "Morphisms should be composable!");

  // Test the composed morphism
  using ComposedMorph =
      decltype(std::declval<MorphSnd>() | std::declval<MorphFst>());
  test_morphism<ComposedMorph>();
}

template <class MorphSnd, class MorphFst>
void test_morphism(MorphSnd const &morphSnd, MorphFst const &morphFst) {
  test_morphism<MorphSnd, MorphFst>();
}

} // namespace mathpp::test_Cat
