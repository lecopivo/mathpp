#pragma once

#include <type_traits>

#include <boost/hana.hpp>

#include "../mathpp/meta"
#include "Category.h"

namespace mathpp {

template <class Cat>
constexpr bool is_category() {
  using C = std::decay_t<Cat>;
  return std::is_base_of_v<Category, C>;
};

template <class Cat>
constexpr bool is_category(Cat const &) {
  return is_category<Cat>();
};

template <class X>
constexpr bool has_category() {
  using DX                        = std::decay_t<X>;
  constexpr bool defines_category = HAS_TYPE(DX, Category);
  if constexpr (!defines_category) {
    return false;
  } else {
    return is_category<typename std::decay_t<DX>::Category>();
  }
}

template <class X>
constexpr bool has_category(X const &) {
  return has_category<X>();
}

template <class X, class Cat>
constexpr bool in_category() {
  using DX = std::decay_t<X>;
  using C  = std::decay_t<Cat>;
  if constexpr (!has_category<DX>() || !is_category<C>()) {
    return false;
  } else {
    return std::is_same_v<typename DX::Category, C>;
  }
};

template <class X, class Cat>
constexpr bool in_category(X const &, Cat const &) {
  return in_category<X, Cat>();
}

template <class Morph>
constexpr bool is_morphism() {
  using M = std::decay_t<Morph>;
  if constexpr (!has_category<M>()) {
    return false;
  } else {
    return M::Category::template is_morphism<M>();
  }
}

template <class Morph>
constexpr bool is_morphism(Morph const &) {
  return is_morphism<Morph>();
}

template <class X, class Y>
constexpr bool in_same_category() {
  using DX = std::decay_t<X>;
  using DY = std::decay_t<Y>;
  if constexpr (!has_category<DX>() || !has_category<DY>()) {
    return false;
  } else {
    return std::is_same_v<typename DX::Category, typename DY::Category>;
  }
}

template <class X, class Y>
constexpr bool in_same_category(X const &, Y const &) {
  return in_same_category<X, Y>();
}

template <class Morph1, class Morph2>
constexpr bool has_same_source() {
  using M1 = std::decay_t<Morph1>;
  using M2 = std::decay_t<Morph2>;
  if constexpr (!is_morphism<M1>() || !is_morphism<M2>()) {
    return false;
  } else {
    return std::is_same_v<typename M1::Source, typename M2::Source>;
  }
}

template <class Morph1, class Morph2>
constexpr bool has_same_source(Morph1 const &, Morph2 const &) {
  return has_same_source<Morph1, Morph2>();
}

template <class Morph1, class Morph2>
constexpr bool has_same_target() {
  using M1 = std::decay_t<Morph1>;
  using M2 = std::decay_t<Morph2>;
  if constexpr (!is_morphism<M1>() || !is_morphism<M2>()) {
    return false;
  } else {
    return std::is_same_v<typename M1::Target, typename M2::Target>;
  }
}

template <class Morph1, class Morph2>
constexpr bool has_same_target(Morph1 const &, Morph2 const &) {
  return has_same_target<Morph1, Morph2>();
}

template <class Morph1, class Morph2>
constexpr bool in_same_hom_set() {
  return has_same_source<Morph1, Morph2>() && has_same_target<Morph1, Morph2>();
}

template <class Morph1, class Morph2>
constexpr bool in_same_hom_set(Morph1 const &, Morph2 const &) {
  return in_same_hom_set<Morph1, Morph2>();
}

template <class MorphSnd, class MorphFst>
constexpr bool are_composable() {
  using Fst = std::decay_t<MorphFst>;
  using Snd = std::decay_t<MorphSnd>;
  if constexpr (!is_morphism<Fst>() || !is_morphism<Snd>()) {
    return false;
  } else {
    return std::is_same_v<typename Fst::Target, typename Snd::Source>;
  }
}

template <class MorphSnd, class MorphFst>
constexpr bool are_composable(MorphSnd const &, MorphFst const &) {
  return are_composable<MorphSnd, MorphFst>();
}

} // namespace mathpp
