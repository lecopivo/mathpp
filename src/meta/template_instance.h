#pragma once
#include <tuple>

namespace mathpp::meta {

template <template <class...> class F, class T> struct template_instance {
  static constexpr bool is_instance = false;
};

template <template <class...> class F, class... Ts>
struct template_instance<F, F<Ts...>> {
  static constexpr bool is_instance = true;

  template <std::size_t I>
  using arg = typename std::tuple_element<I, std::tuple<Ts...>>::type;
};

template <template <class...> class F, class T>
constexpr bool is_template_instance_of = template_instance<F, T>::is_instance;

} // namespace mathpp::meta
