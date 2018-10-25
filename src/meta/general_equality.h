#pragma once

#include "introspection.h"

template <class A, class B>
constexpr bool are_equal(A const &a, B const &b) {

  constexpr auto has_equality =
      boost::hana::is_valid([](auto &&x1, auto &&x2) -> decltype(x1 == x2) {});

  // I calling operator== valid?
  if constexpr (has_equality(a, b)) {
    return a == b;
  } else {
    return false;
  }
}
