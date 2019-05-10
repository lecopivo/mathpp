#pragma once

#include "../Set.h"
#include "../utils.h"
#include "test_Cat.h"

namespace mathpp::test_Set {

//   ___  _     _        _
//  / _ \| |__ (_)___ __| |_
// | (_) | '_ \| / -_) _|  _|
//  \___/|_.__// \___\__|\__|
//           |__/

template <class Obj>
void test_object() {
  test_Cat::test_object<Obj>();

  // Test if there is !static! function `is_element` !
}

template <class Obj>
void test_object(Obj const &obj) {
  test_object<Obj>();
}

// With element

template <class Obj, class Elem>
void test_object_elem() {
  test_object<Obj>();

  static_assert(Obj::template is_element<Elem>(),
                "Element is not an element of the Object");

  // Test if `is_element` callable with bunch of random types
  // All of these calls should compile and produce bool
}

template <class Obj, class Elem>
void test_object_elem(Obj const &obj, Elem const &elem) {
  test_object_elem<Obj, Elem>();
}

// Test also with somethig that is not an element
// template <class Obj, class Elem>
// void test_object_non_elem() {}

//  __  __              _    _
// |  \/  |___ _ _ _ __| |_ (_)____ __
// | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|

template <class Morph>
void test_morphism() {
  test_Cat::test_morphism<Morph>();
}

template <class Morph>
void test_morphism(Morph const &morph) {
  test_Cat::test_morphism(morph);
  test_morphism<Morph>();
}

template <class MorphSnd, class MorphFst>
void test_morphism() {
  test_Cat::test_morphism<MorphSnd, MorphFst>();
  test_morphism<MorphFst>();
  test_morphism<MorphSnd>();
}

template <class MorphSnd, class MorphFst>
void test_morphism(MorphSnd const &morphSnd, MorphFst const &morphFst) {
  test_Cat::test_morphism(morphSnd, morphFst);
  test_morphism<MorphSnd, MorphFst>();
}

// with element

template <class Morph, class Elem>
void test_morphism_elem() {
  test_morphism<Morph>();
  test_object_elem<typename Morph::Source, Elem>();
}

template <class Morph, class Elem>
void test_morphism_elem(Morph const &morph, Elem const &elem) {
  test_morphism_elem<Morph, Elem>();
}

template <class MorphSnd, class MorphFst, class Elem>
void test_morphism_elem() {
  test_morphism<MorphSnd, MorphFst>();
  test_morphism_elem<MorphFst, Elem>();
  // Element type after applying MorphFst
  using Elem2 = decltype(std::declval<MorphFst>()(std::declval<Elem>()));
  test_morphism_elem<MorphSnd, Elem2>();
}

template <class MorphSnd, class MorphFst, class Elem>
void test_morphism_elem(MorphSnd const &morphSnd, MorphFst const &morphFst,
                        Elem const &elem) {
  test_morphism_elem<MorphSnd, MorphFst, Elem>();
}

} // namespace mathpp::test_Set
