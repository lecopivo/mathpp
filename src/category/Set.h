#pragma once

#include <iostream>
#include <type_traits>

#include <assert.h>
#include <boost/hana.hpp>

#include <meta/apply_sequence.h>
#include <meta/general_equality.h>
#include <meta/introspection.h>
#include <meta/is_product_type.h>
#include <meta/macros.h>

#include "Set_is_elem.h"
#include "utils.h"

namespace category {
struct Set {

  template <class Obj>
  constexpr static bool is_object(Obj const &obj) {

    constexpr auto d = dummy{};
    return IS_VALID(obj, Set_is_elem(obj, d));
  }

  template <class Obj, class Element>
  constexpr static bool is_elem(Obj const &obj, Element const &elem) {
    // some kind of assert to ensure that obj is really a set
    return Set_is_elem(obj, elem);
  }

  template <class Source, class Target, class Function>
  struct morphism {

    constexpr morphism(Source _source, Target _target, Function _function)
        : source(std::move(_source))
        , target(std::move(_target))
        , function(std::move(_function)) {}

    template <class Element, typename = std::enable_if_t<
                                 std::is_invocable_v<Function, Element>>>
    constexpr auto operator()(Element &&elem) const
    //[[ expects: Set::is_elem(source, elem) ]]
    //[[ ensures result: Set::is_elem(target, result)]]
    {
      assert(Set::is_elem(source, elem));
      auto out = function(std::forward<Element>(elem));
      assert(Set::is_elem(target, out));
      return out;
    }

    const Source   source;
    const Target   target;
    const Function function;
  };

  struct empty_set {

    constexpr empty_set(){};

    template <class Element>
    constexpr bool is_elem(Element const &) const {
      return false;
    }

    constexpr bool operator==(empty_set) const { return true; }
    constexpr bool operator!=(empty_set) const { return false; }
  };

  // constexpr static auto initial_object = Set::empty_set{};

  template <class Object>
  constexpr static auto initial_object_morphism(Object object) {
    return Set::morphism{empty_set{}, std::move(object),
                         [](auto &&x) { return; }};
  }

  // constexpr static auto terminal_object = std::tuple{empty_set{}};

  template <class Object>
  constexpr static auto terminal_object_morphism(Object object) {
    return Set::morphism{std::move(object), std::tuple{empty_set{}},
                         [](auto &&x) { return empty_set{}; }};
  }

  //  ___             _         _
  // | _ \_ _ ___  __| |_  _ __| |_
  // |  _/ '_/ _ \/ _` | || / _|  _|
  // |_| |_| \___/\__,_|\_,_\__|\__|

  template <class... Objects>
  struct set_product {

    constexpr set_product(Objects... objs)
        : sets{std::move(objs)...} {}

    template <class Element>
    constexpr bool is_elem(Element const &elem) const {

      constexpr int N = sizeof...(Objects);

      if constexpr (!mathpp::meta::is_product_type(elem)) {
        return false;
      } else {
        if constexpr (std::tuple_size_v<Element> == N) {
          bool result = true;
          mathpp::meta::static_for<0, N>([&result, &elem, this](auto I) {
            result &= Set::is_elem(std::get<I>(sets), std::get<I>(elem));
          });

          return result;
        } else {
          return false;
        }
      }
    }

    template <class Integral, Integral I>
    constexpr auto proj(std::integral_constant<Integral, I> i) const {
      return morphism{*this, std::get<i>(sets),
                      [](auto &&x) { return std::get<I>(FWD(x)); }};
    }

  private:
    const std::tuple<Objects...> sets;
  };

  struct set_product_functor {

    template <class... Objects>
    constexpr auto operator()(Objects... objs) const {
      return set_product{std::move(objs)...};
    }

    template <class... Morphs>
    constexpr auto fmap(Morphs... morphs) const {

      constexpr int N = sizeof...(morphs);

      auto source = this->operator()(morphs.source...);
      auto target = this->operator()(morphs.target...);

      auto function = [funs = std::tuple{std::move(morphs)...},
                       source](auto &&input) {
        auto morph = [&](auto I) { return std::get<I>(funs); };
        auto proj  = [&](auto I) { return source.proj(I); };
        // auto fun   = [&](auto I) { return compose(morph(I), proj(I)); };

        return mathpp::meta::apply_sequence<N>(
            [morph, proj, &input](auto... I) {
              return std::tuple{morph(I)(proj(I)(FWD(input)))...};
            });
      };

      return Set::morphism{std::move(source), std::move(target),
                           std::move(function)};
    }
  };

  constexpr static auto product = set_product_functor{};

  //  ___
  // / __|_  _ _ __
  // \__ \ || | '  \
  // |___/\_,_|_|_|_|

  template <class... Objects>
  struct set_sum {

    constexpr set_sum(Objects... objects)
        : sets{std::move(objects)...} {}

    template <class Element>
    constexpr bool is_elem(Element const &elem) const {

      constexpr int N = sizeof...(Objects);

      if constexpr (!mathpp::meta::is_product_type(elem)) {
        return false;
      } else {
        if constexpr (std::tuple_size_v<Element> == 2) {
          bool result = false;
          mathpp::meta::static_for<0, N>([&result, &elem, this](auto I) {
            if (std::get<0>(elem) == I)
              if (Set::is_elem(std::get<I>(sets), std::get<1>(elem)))
                result = true;
          });
          return result;
        } else {
          return false;
        }
      }
    }

    template <class Integral, Integral I>
    constexpr auto incl(std::integral_constant<Integral, I> i) const {
      return morphism{std::get<i>(sets), *this, [i](auto &&x) {
                        return std::tuple{i, FWD(x)};
                      }};
    }

  private:
    const std::tuple<Objects...> sets;
  };

  struct set_sum_functor {

    template <class... Objects>
    constexpr auto operator()(Objects... objs) const {
      return set_sum{std::move(objs)...};
    }

    template <class... Morphs>
    constexpr auto fmap(Morphs... morphs) const {

      constexpr int N = sizeof...(morphs);

      auto source = this->operator()(morphs.source...);
      auto target = this->operator()(morphs.target...);

      auto function = [funs = std::tuple{std::move(morphs)...},
                       target](auto &&input) {
			
        auto        I    = std::get<0>(input);
        auto const &incl = target.incl(I);
        auto const &fun  = std::get<I>(funs);

        return incl(fun(std::get<I>(FWD(input))));
      };

      return Set::morphism{std::move(source), std::move(target),
                           std::move(function)};
    }
  };

  constexpr static auto sum = set_sum_functor{};

  //  ___                _ _
  // | __|__ _ _  _ __ _| (_)______ _ _
  // | _|/ _` | || / _` | | |_ / -_) '_|
  // |___\__, |\_,_\__,_|_|_/__\___|_|
  //        |_|

  template <class... Morphisms>
  struct equalizer {

    constexpr equalizer(Morphisms... _morphisms)
        : morphisms{std::move(_morphisms)...} {
      // Check if all source and target objects are the same!
    }

    template <class Element>
    constexpr bool is_elem(Element const &element) const {
      // This implementation is awful. I have to check if all morphisms are
      // actualy callable with the input `element`.

      constexpr int N = sizeof...(Morphisms);

      constexpr auto can_call = boost::hana::is_valid(
          [](auto x) -> decltype((std::declval<Morphisms>()(x), ...)) {});

      if constexpr (!can_call(element)) {
        return false;
      } else {

        bool result = true;
        auto first  = std::get<0>(morphisms)(element);
        mathpp::meta::static_for<1, N>([&](auto I) {
          result &= (are_equal(first, std::get<I>(morphisms)(element)));
        });

        return result;
      }
    }

  private:
    std::tuple<Morphisms...> morphisms;
  };

  //  ___          _        _   _
  // | _ \_ _ ___ (_)___ __| |_(_)___ _ _
  // |  _/ '_/ _ \| / -_) _|  _| / _ \ ' \
  // |_| |_| \___// \___\__|\__|_\___/_||_|
  //            |__/
  //                             _ _
  //  __ ___  ___ __ _ _  _ __ _| (_)______ _ _
  // / _/ _ \/ -_) _` | || / _` | | |_ / -_) '_|
  // \__\___/\___\__, |\_,_\__,_|_|_/__\___|_|
  //                |_|

  template <class Projection>
  struct projection_coequalizer {

    constexpr projection_coequalizer(Projection _projection)
        : projection{std::move(_projection)} {}

    template <class Element>
    constexpr bool is_elem(Element const &element) const {

      if (!Set::is_elem(projection.source, element)) {
        return false;
      } else {

        if constexpr (!IS_VALID(element, projection(element))) {
          return false;
        } else {
          if (are_equal(element, projection(element)))
            return true;
          else
            return false;
        }
      }
    }

  private:
    Projection projection;
  };
};

} // namespace category
