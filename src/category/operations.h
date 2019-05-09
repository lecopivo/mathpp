#pragma once

#include "utils.h"
#include "../mathpp/meta"

namespace mathpp {

template <class Snd, class Fst,
          class = std::enable_if_t<are_composable<Snd, Fst>()>>
decltype(auto) operator|(Snd &&snd, Fst &&fst) {
  using Category = typename std::decay_t<Fst>::Category;

  return Category::template compose(std::forward<Snd>(snd), std::forward<Fst>(fst));
}
} // namespace mathpp
