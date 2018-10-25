#pragma once

#include <utility>

#define M_fwd(x) std::forward<decltype(x)>(x)
#define FWD(x) std::forward<decltype(x)>(x)
