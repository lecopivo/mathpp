#pragma once

#include <tuple>
#include <utility>

namespace mathpp::meta {

namespace detail {
template <std::size_t... I>
constexpr auto integral_sequence_impl(std::index_sequence<I...>) {
  return std::make_tuple((std::integral_constant<std::size_t, I>{})...);
}

template <std::size_t N, typename Indices = std::make_index_sequence<N>>
constexpr auto integral_sequence = integral_sequence_impl(Indices{});
} // namespace detail

template <std::size_t N, typename Fun>
constexpr decltype(auto) apply_sequence(Fun &&fun) {
  return std::apply(std::forward<Fun>(fun), detail::integral_sequence<N>);
}

} // namespace mathpp::meta
