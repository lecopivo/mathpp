#pragma once

#include <utility>

#include "tensor.h"

//  ___                           _   ___         _               _   _
// | __|__ _ ___ __ ____ _ _ _ __| | |   \ ___ __| |__ _ _ _ __ _| |_(_)___ _ _
// | _/ _ \ '_\ V  V / _` | '_/ _` | | |) / -_) _| / _` | '_/ _` |  _| / _ \ ' \
// |_|\___/_|  \_/\_/\__,_|_| \__,_| |___/\___\__|_\__,_|_|
// \__,_|\__|_\___/_||_|

template <class Source, class Target, class Fun> struct differentiable_map;

template <class Source, class Target, class Fun = void> struct zero_map;

template <class Source, class Target, class Fun = void> struct constant_map;

template <class Source, class Target, class Fun> struct linear_map;

template <class Source, class Fun1, class Fun2> struct sum_map;

//  ___              _      _  __   __    _
// / __|_ __  ___ __(_)__ _| | \ \ / /_ _| |_  _ ___ ___
// \__ \ '_ \/ -_) _| / _` | |  \ V / _` | | || / -_|_-<
// |___/ .__/\___\__|_\__,_|_|   \_/\__,_|_|\_,_\___/__/
//     |_|

template <class T> auto zero = T{};

template <class Source, class Target, class Fun>
auto zero<differentiable_map<Source, Target, Fun>> = zero_map<Source, Target>{};

template <class Source, class Target>
auto zero<constant_map<Source, Target>> = zero_map<Source, Target>{};

template <class Source, class Target, class Fun>
auto zero<linear_map<Source, Target, Fun>> = zero_map<Source, Target>{};

template <class T>
constexpr bool is_differentiable_map = std::is_base_of_v<
    differentiable_map<typename T::Source, typename T::Target, T>, T>;

//  ___  _  __  __                 _   _      _    _       __  __
// |   \(_)/ _|/ _|___ _ _ ___ _ _| |_(_)__ _| |__| |___  |  \/  |__ _ _ __
// | |) | |  _|  _/ -_) '_/ -_) ' \  _| / _` | '_ \ / -_) | |\/| / _` | '_ \
// |___/|_|_| |_| \___|_| \___|_||_\__|_\__,_|_.__/_\___| |_|  |_\__,_| .__/
//                                                                    |_|

template <class SrcObj, class TrgObj, class Impl> struct differentiable_map : SetMorphism<differentiable_map> {

  using Source = SrcObj;
  using Target = TrgObj;

  // static constexpr auto zero = zero_map<Source, Target>{};

  template <class T>
  auto operator()(T &&x)
      -> std::enable_if_t<SetCategory::is_invocable<Source, Target, Impl, T>,
                          std::invoke_result_t<Impl, T>> {
    return static_cast<Impl *>(this)->operator()(std::forward<T>(x));
  }

  auto derivative() { return static_cast<Fun *>(this)->derivative(); }

  auto derivative(const Source &x) {
    return static_cast<Fun *>(this)->derivative()(x);
  }
};

//  ____              __  __
// |_  /___ _ _ ___  |  \/  |__ _ _ __
//  / // -_) '_/ _ \ | |\/| / _` | '_ \
// /___\___|_| \___/ |_|  |_\__,_| .__/
//                               |_|

template <class Source, class Target, class Fun>
struct zero_map
    : public differentiable_map<Source, Target, zero_map<Source, Target>> {

  Target operator()(const Source &) { return zero<Target>; }

  auto derivative() { return zero_map<Source, zero_map<Source, Target>>{}; }
};

//   ___             _            _     __  __
//  / __|___ _ _  __| |_ __ _ _ _| |_  |  \/  |__ _ _ __
// | (__/ _ \ ' \(_-<  _/ _` | ' \  _| | |\/| / _` | '_ \
//  \___\___/_||_/__/\__\__,_|_||_\__| |_|  |_\__,_| .__/
//                                                 |_|

template <class Source, class Target, class Fun>
struct constant_map
    : public differentiable_map<Source, Target, constant_map<Source, Target>> {

  constant_map(Target v) : value(std::move(v)) {}

  Target operator()(const Source &) { return value; }

  auto derivative() { return zero_map<Source, zero_map<Source, Target>>{}; }

public:
  Target value;
};

//  _    _                     __  __
// | |  (_)_ _  ___ __ _ _ _  |  \/  |__ _ _ __
// | |__| | ' \/ -_) _` | '_| | |\/| / _` | '_ \
// |____|_|_||_\___\__,_|_|   |_|  |_\__,_| .__/
//                                        |_|

template <class Source, class Target, class Fun>
struct linear_map : public differentiable_map<Source, Target,
                                              linear_map<Source, Target, Fun>> {

  linear_map(Fun fun) : f(std::move(fun)) {}

  Target operator()(const Source &x) { return f(x); }

  auto derivative() {
    return constant_map<Source, linear_map<Source, Target, Fun>>{*this};
  };

public:
  Fun f;
};

template <class Source, class Target, class Fun>
linear_map<Source, Target, Fun> make_linear_map(Fun &&fun) {
  return linear_map<Source, Target, Fun>(std::forward<Fun>(fun));
}

//  ___              __  __
// / __|_  _ _ __   |  \/  |__ _ _ __
// \__ \ || | '  \  | |\/| / _` | '_ \
// |___/\_,_|_|_|_| |_|  |_\__,_| .__/
//                              |_|

template <class Source, class Fun1, class Fun2>
struct sum_map : public differentiable_map<
                     Source,
                     decltype(std::declval<Fun1>()(std::declval<Source>()) +
                              std::declval<Fun2>()(std::declval<Source>())),
                     sum_map<Source, Fun1, Fun2>> {

  using Target = decltype(std::declval<Fun1>()(std::declval<Source>()) +
                          std::declval<Fun2>()(std::declval<Source>()));

  sum_map(Fun1 fun1, Fun2 fun2) : f1(std::move(fun1)), f2(std::move(fun2)) {}

  Target operator()(const Source &x) { return f1(x) + f2(x); }

  auto derivative() { return f1.derivative() + f2.derivative(); }

public:
  Fun1 f1;
  Fun2 f2;
};

template <class Fun1, class Fun2,
          class = std::enable_if_t<
              is_differentiable_map<Fun1> && is_differentiable_map<Fun2> &&
              std::is_same_v<typename Fun1::Source, typename Fun2::Source>>>
auto operator+(Fun1 f1, Fun2 f2) {
  using Source = typename Fun1::Source;
  return sum_map<Source, Fun1, Fun2>{std::move(f1), std::move(f2)};
}

// template <class Fun1, class Fun2, class Source, class Target>
// struct product_map : differentiable_map<product_map<Fun1, Fun2, Source,
// Target>,
//                                         Source, Target> {

//   Target operator()(const Source &x) { return f1(x) * f2(x); }

//   auto derivative(const Source &x) {
//     using Fun1Der = decltype(f1.derivative(x));
//     using Fun2Der = decltype(f2.derivative(x));

//     return product_map<Fun1Der, Fun2, Source, Target>{f1.derivative(x), f2} +
//            product_map<Fun1, Fun2Der, Source, Target>{f1, f2.derivative(x)};
//   }

// public:
//   Fun1 f1;
//   Fun2 f2;
// };

// template <class Fun1, class Fun2, class Source, class Target>
// auto operator*(differentiable_map<Fun1, Source, Target> f1,
//                differentiable_map<Fun2, Source, Target> f2) {
//   return product_map<Fun1, Fun2, Source, Target>{std::move(f1),
//   std::move(f2)};
//}
