#pragma once

#include "macros.h"
#include <boost/hana.hpp>
#include <tuple>

namespace mathpp::meta {

template <int I, typename... Ts>
using get = typename std::tuple_element<I, std::tuple<Ts...>>::type;

template <class T, class Id>
decltype(auto) mget(T &&t, Id id) {
  if constexpr (is_static_product_type(t)) {
    return std::get<id>(FWD(t));
  } else if constexpr (is_dynamic_product_type(t)) {
    return t[id];
  }
}

// template <class T, class... Ids>
// decltype(auto) get(T &&t, Ids...) {

// }
} // namespace mathpp::meta
