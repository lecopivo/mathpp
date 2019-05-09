#pragma once

#include <string_view>

template <class T> constexpr std::string_view type_name() {
  using namespace std;
#ifdef __clang__
  string_view p = __PRETTY_FUNCTION__;
  return string_view(p.data() + 34, p.size() - 34 - 1);
#elif defined(__GNUC__)
  string_view p = __PRETTY_FUNCTION__;
#if __cplusplus < 201402
  return string_view(p.data() + 36, p.size() - 36 - 1);
#else
  return string_view(p.data() + 49, p.size() - 99);
#endif
#elif defined(_MSC_VER)
  string_view p = __FUNCSIG__;
  return string_view(p.data() + 84, p.size() - 84 - 7);
#endif
};

template <class T> constexpr std::string_view type_name(T &&) {
  return type_name<std::decay_t<T>>();
  // return  std::string_view(__PRETTY_FUNCTION__);
}

namespace internal {

template <template <class> class F> struct static_base_check {
  template <class T>
  auto operator()(T const &)
      -> std::enable_if_t<std::is_base_of_v<F<T>, T>, bool> {
    return true;
  };
};

} // namespace internal

template <template <class...> class F, class T>
constexpr bool is_static_base_of =
    std::is_invocable_v<internal::static_base_check<F>, T>;

template <template <class...> class F, class T> struct template_instance_of {
  static constexpr bool value = false;
};

template <template <class...> class F, class... Ts>
struct template_instance_of<F, F<Ts...>> {
  static constexpr bool value = true;
};

template <template <class...> class F, class T>
constexpr bool is_template_instance_of = template_instance_of<F, T>::value;
