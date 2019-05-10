#pragma once

#include <boost/hana.hpp>

namespace mathpp::meta {

template <class T>
constexpr void test_helper(T &&t) {}

#define IS_CONSTEXPR(...) noexcept(mathpp::meta::test_helper((__VA_ARGS__, 0)))

#define IS_VALID(x, expr)                                                      \
  (boost::hana::is_valid([](auto &&x) -> decltype(expr) {})(x))
#define IS_VALID2(x1, x2, expr)                                                \
  (boost::hana::is_valid([](auto &&x1, auto &&x2) -> decltype(expr) {})(x1, x2))
#define IS_VALID3(x1, x2, x3, expr)                                            \
  (boost::hana::is_valid(                                                      \
      [](auto &&x1, auto &&x2, auto &&x3) -> decltype(expr) {})(x1, x2, x3))

struct Dummy {};

// Checks is T::S is a valid type
#define HAS_TYPE(T, S)                                                         \
  (boost::hana::is_valid([](auto t) -> boost::hana::type<typename decltype(    \
                                        t)::type::S>{}))(                      \
      boost::hana::type_c<T>)

#define HAS_MEMBER(T, member)                                                  \
  (boost::hana::is_valid(                                                      \
      [](auto t) -> decltype((void)boost::hana::traits::declval(t).member) {   \
      }))(boost::hana::type_c<T>)

#define HAS_TEMPLATED_TYPE(T, S)                                               \
  (hana::is_valid(                                                             \
      [](auto t) -> decltype(hana::template_<decltype(t)::type::template S>) { \
      }))(hana::type_c<T>)

} // namespace mathpp::meta
