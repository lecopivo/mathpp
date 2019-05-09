#pragma once

#include <array>
#include <meta/template_instance.h>

namespace mathpp::meta {

template <class T>
constexpr bool is_product_type(T const &) {
  if constexpr (mathpp::meta::template_instance<std::tuple, T>::is_instance) {
    return true;
  } else {
    return false;
  }
}

} // namespace mathpp::meta
