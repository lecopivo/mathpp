#pragma once

#include <tuple>
#include <type_traits>
#include <utility>
#include <variant>

#include <meta/apply_sequence.h>
#include <meta/static_for.h>
#include <meta/template_instance.h>

namespace mathpp::category {

template <typename T>
struct type_object;
template <typename Src, typename Trg, typename Fun>
struct type_morphism;
template <typename MorphF, typename MorphG>
struct composed_type_morphism;
struct type_category;
struct type_product;
struct type_sum;

template <typename T>
struct type_object {

  constexpr type_object() {}

  using type = T;

  static constexpr auto is_element = [](auto &&e) {
    return std::is_same_v<std::decay_t<decltype(e)>, T>;
  };
};

template <typename Src, typename Trg, typename Fun>
struct type_morphism {

  constexpr type_morphism(Fun fun)
      : m_fun(std::move(fun)) {}

  using source_type = Src;
  using target_type = Trg;

  static constexpr auto source = []() { return type_object<source_type>{}; };
  static constexpr auto target = []() { return type_object<target_type>{}; };

  template <typename X>
  constexpr decltype(auto) operator()(X &&x) {
    return m_fun(std::forward<X>(x));
  }

  template <typename X>
  constexpr decltype(auto) operator()(X &&x) const {
    return m_fun(std::forward<X>(x));
  }

private:
  Fun m_fun;
};

template <typename Src, typename Trg, typename Fun>
constexpr auto make_type_morphism(Fun fun) {
  return type_morphism<Src, Trg, Fun>(std::move(fun));
}

template <typename MorphF, typename MorphG>
struct composed_type_morphism {

  constexpr composed_type_morphism(MorphF morphF, MorphG morphG)
      : m_morphF(std::move(morphF))
      , m_morphG(std::move(morphG)) {}

  static constexpr auto source = []() { return MorphG::source(); };
  static constexpr auto target = []() { return MorphF::target(); };

  template <typename X>
  constexpr decltype(auto) operator()(X &&x) {
    return m_morphF(m_morphG(std::forward<X>(x)));
  }

  template <typename X>
  constexpr decltype(auto) operator()(X &&x) const {
    return m_morphF(m_morphG(std::forward<X>(x)));
  }

protected:
  MorphF m_morphF;
  MorphG m_morphG;
};

struct type_product {

  constexpr type_product() {}

  // static constexpr auto source = []() { return type_category{}; };
  // static constexpr auto target = []() { return type_category{}; };

  template <typename... Objs>
  constexpr auto operator()(Objs &&... objs) const {
    return type_object<std::tuple<typename std::decay_t<Objs>::type...>>{};
  };

  static constexpr auto fmap = [](auto &&... morphs) constexpr
                               -> decltype(auto) {

    constexpr int N = sizeof...(morphs);
    using source_type =
        std::tuple<typename std::decay_t<decltype(morphs)>::source_type...>;
    using target_type =
        std::tuple<typename std::decay_t<decltype(morphs)>::target_type...>;

    auto lam = [ms{std::forward_as_tuple(morphs...)}](
                   auto &&x) mutable->decltype(auto) {

      return meta::apply_sequence<N>([&ms, &x](auto... I) {

        // Check if input `x` is of valid type
        static_assert(
            (std::is_assignable_v<std::tuple_element_t<I, source_type>,
                                  decltype(std::get<I>(x))> &&
             ...),
            "Invalid argument!");

        return std::tuple(
            std::get<I>(ms)(std::get<I>(std::forward<decltype(x)>(x)))...);
      });
    };

    return make_type_morphism<source_type, target_type>(std::move(lam));
  };
};

struct type_sum {

  // static constexpr auto source = []() { return type_category{}; };
  // static constexpr auto target = []() { return type_category{}; };

  template <typename... Objs>
  constexpr auto operator()(Objs &&... objs) const {
    return type_object<std::variant<typename std::decay_t<Objs>::type...>>{};
  };

  static constexpr auto fmap = [](auto &&... morphs) constexpr
                               -> decltype(auto) {

    constexpr int N = sizeof...(morphs);
    using source_type =
        std::variant<typename std::decay_t<decltype(morphs)>::source_type...>;
    using target_type =
        std::variant<typename std::decay_t<decltype(morphs)>::target_type...>;

    // auto lam = [ms{std::forward_as_tuple(morphs...)}](auto &&x) {
    auto lam = [ms{std::forward_as_tuple(morphs...)}](auto &&arg) {

      using T = std::decay_t<decltype(arg)>;
      static_assert(std::is_same_v<source_type, T>, "Invalid argument");
      target_type output;

      int i = arg.index();

      meta::static_for<0,N>([&](auto I) {
        if (I.value == i) {
          auto &morph = std::get<I>(ms);
	  auto val = std::get<I>(arg);
          output = target_type{morph(std::get<I>(arg))};
        }
      });

      return output;
    };

    return make_type_morphism<source_type, target_type>(std::move(lam));
  };
};

struct type_category {

  static constexpr auto is_object = [](auto const &obj) -> bool {
    return meta::template_instance<type_object,
                                   std::decay_t<decltype(obj)>>::is_instance;
  };

  static constexpr auto is_same = [](auto const &obj1,
                                     auto const &obj2) -> bool {
    using T1 = typename std::decay_t<decltype(obj1)>::type;
    using T2 = typename std::decay_t<decltype(obj2)>::type;
    return std::is_same_v<T1, T2>;
  };

  static constexpr auto is_morphism = [](auto const &morph) -> bool {
    return meta::template_instance<type_morphism,
                                   std::decay_t<decltype(morph)>>::is_instance;
  };

  static constexpr auto identity = [](auto const &obj) {
    using Type = typename std::decay_t<decltype(obj)>::type;
    return make_type_morphism<Type, Type>(
        [](auto &&x) { return std::forward<decltype(x)>(x); });
  };

  static constexpr auto compose = [](auto morphF, auto morphG) {
    static_assert(is_same(morphF.source(), morphG.target()),
                  "Morphishm cannot be composed!");
    return composed_type_morphism(std::move(morphF), std::move(morphG));
  };

  // functors
  static constexpr type_product product = type_product{};
  static constexpr type_sum     sum = type_sum{};
};

} // namespace mathpp::category
