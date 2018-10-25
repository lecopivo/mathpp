#pragma once

#include <tuple>

namespace mathpp::meta {

template <int I, typename... Ts>
using get = typename std::tuple_element<I, std::tuple<Ts...>>::type;
}
