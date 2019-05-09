#pragma once

#include <array>
#include <boost/hana.hpp>
#include <tuple>

#include <meta/get.h>
#include <meta/static_for.h>

#include "utils.h"

namespace category {

// hana::type<T> is a set of all value of type T
template <class Type, class Element>
constexpr bool Set_is_elem(boost::hana::basic_type<Type> const &obj,
                           Element const &                      elem) {
  return std::is_same_v<Type, Element>;
}

// std::array<T,N> is a set of N values of type T
template <class Type, std::size_t N, class Element>
constexpr bool Set_is_elem(std::array<Type, N> const &obj,
                           Element const &            elem) {
  if constexpr (!std::is_same_v<Type, Element>) {
    return false;
  } else {

    for (int i = 0; i < N; i++) {
      if (obj[i] == elem)
        return true;
    }
    return false;
  }
}

// std::tuple<Types...> is a set of values of type Types...
template <class... Types, class Element>
constexpr bool Set_is_elem(std::tuple<Types...> const &obj,
                           Element const &             elem) {
  if constexpr (!(std::is_same_v<Types, Element> || ...)) {
    return false;
  } else {
    bool out = false;
    mathpp::meta::static_for<0, sizeof...(Types)>([&out, &obj, &elem](auto I) {
      using Type = mathpp::meta::get<I, Types...>;
      if constexpr (std::is_same_v<Element, Type>) {
        out |= (std::get<I>(obj) == elem);
      }
    });
    return out;
  }
}

constexpr auto has_member__is_elem = boost::hana::is_valid(
    [](auto t) -> decltype(boost::hana::traits::declval(t).is_elem(dummy{})) {
    });

// Any class with member function `template<class T> bool is_elem(T const&)` is
// a set
template <class Obj, class Element>
constexpr std::enable_if_t<has_member__is_elem(boost::hana::type_c<Obj>), bool>
Set_is_elem(Obj const &obj, Element const &elem) {
  return obj.is_elem(elem);
}

} // namespace category
