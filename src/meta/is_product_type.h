#pragma once

#include <array>
#include <meta/template_instance.h>
#include <vector>

namespace mathpp::meta {

template <class T>
constexpr bool is_product_type(T const &) {
  if constexpr (mathpp::meta::template_instance<std::tuple, T>::is_instance) {
    return true;
  } else {
    return false;
  }
}

template <class T>
constexpr bool is_static_product_type(T const &) {
  if constexpr (mathpp::meta::template_instance<std::tuple, T>::is_instance) {
    return true;
  } else {
    return false;
  }
}

template <typename T>
using vector_detector = std::vector<T>;

template <class T>
constexpr bool is_dynamic_product_type(T const &) {
  if constexpr (mathpp::meta::template_instance<std::vector,
                                                T>::is_instance) {
    return true;
  } else {
    return false;
  }
}

} // namespace mathpp::meta
