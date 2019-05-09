#pragma once

#include <type_traits>

template <class Cat, class Morph1, class Morph2>
constexpr bool                          are_composable =
    Cat::template is_morphism<Morph1> &&Cat::template is_morphism<Morph2>
        &&std::is_same_v<typename Morph1::Source, typename Morph2::Target>;

template<class Cat>
struct category_traits{
  static constexpr bool is_category = false;
};

template<class Morph>
struct morphism_traits{
  static constexpr bool is_morphism = false;
};


