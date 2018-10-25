#pragma once

#include <utility>

namespace mathpp::meta {

template <int First, int Last, class Lambda>
constexpr void static_for(Lambda const &f) {

  if constexpr (First < Last) {
    f(std::integral_constant<int, First>{});
    static_for<First + 1, Last>(f);
  }
}

} // namespace mathpp::meta
