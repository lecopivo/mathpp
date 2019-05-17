#pragma once

#include "../mathpp/meta"
#include "utils.h"

namespace mathpp {

// template <class Snd, class Fst,
//           class = std::enable_if_t<are_composable<Snd, Fst>()>>
// decltype(auto) operator|(Snd &&snd, Fst &&fst) {
//   using Category = typename std::decay_t<Fst>::Category;

//   return Category::template compose(FWD(snd), FWD(fst));
// }

template <class Category, char Operation> struct morphism_operation {

  template <class X, class Y> static constexpr bool is_valid() { return false; }
};

template <class F, class G> auto get_first_or_second_category_impl() {
  using DF = std::decay_t<F>;
  using DG = std::decay_t<G>;
  if constexpr (has_category<DF>()) {
    return boost::hana::type_c<typename DF::Category>;
  } else {
    if constexpr (has_category<DG>()) {
      return boost::hana::type_c<typename DG::Category>;
    } else {
      return boost::hana::type_c<void>;
    }
  }
}

template <class F, class G>
using get_first_or_second_category =
    typename decltype(get_first_or_second_category_impl<F, G>())::type;

template <char Operation, class F, class G>
constexpr bool is_morphism_operation_valid() {
  return morphism_operation<get_first_or_second_category<F, G>,
                            Operation>::template is_valid<F, G>();
}

//   ___                        _ _   _
//  / __|___ _ __  _ __  ___ __(_) |_(_)___ _ _
// | (__/ _ \ '  \| '_ \/ _ (_-< |  _| / _ \ ' \
//  \___\___/_|_|_| .__/\___/__/_|\__|_\___/_||_|
//                |_|

template <class F, class G,
          class = std::enable_if_t<is_morphism_operation_valid<'|', F, G>()>>
decltype(auto) operator|(F &&f, G &&g) {
  using Category = get_first_or_second_category<F, G>;
  return morphism_operation<Category, '|'>::call(FWD(f), FWD(g));
}

//    _      _    _ _ _   _
//   /_\  __| |__| (_) |_(_)___ _ _
//  / _ \/ _` / _` | |  _| / _ \ ' \
// /_/ \_\__,_\__,_|_|\__|_\___/_||_|

template <class F, class G,
          class = std::enable_if_t<is_morphism_operation_valid<'+', F, G>()>>
decltype(auto) operator+(F &&f, G &&g) {
  using Category = get_first_or_second_category<F, G>;
  return morphism_operation<Category, '+'>::call(FWD(f), FWD(g));
}

//  __  __      _ _   _      _ _         _   _
// |  \/  |_  _| | |_(_)_ __| (_)__ __ _| |_(_)___ _ _
// | |\/| | || | |  _| | '_ \ | / _/ _` |  _| / _ \ ' \
// |_|  |_|\_,_|_|\__|_| .__/_|_\__\__,_|\__|_\___/_||_|
//                     |_|

template <class F, class G,
          class = std::enable_if_t<is_morphism_operation_valid<'*', F, G>()>>
decltype(auto) operator*(F &&f, G &&g) {
  using Category = get_first_or_second_category<F, G>;
  return morphism_operation<Category, '*'>::call(FWD(f), FWD(g));
}

// template <class X, class Y,
//           class = std::enable_if_t<has_category<X>() || has_category<Y>()>>
// decltype(auto) operator*(X &&x, Y &&y){
//   if constexpr (has_category<X>()) {

//     using Category = typename std::decay_t<X>::Category;
//     return Category::template multiply(FWD(x), FWD(y));

//   } else {

//     using Category = typename std::decay_t<Y>::Category;
//     return Category::template compose(FWD(x), FWD(y));

//   }
// }
} // namespace mathpp
