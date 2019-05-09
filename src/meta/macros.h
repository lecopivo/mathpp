#pragma once

#include <utility>

#define FWD(...) std::forward<decltype(__VA_ARGS__)>(__VA_ARGS__)

#define LIFT(fun)                                                              \
  [](auto &&... args) noexcept(noexcept(fun(FWD(args)...)))                    \
      ->decltype(fun(FWD(args)...)) {                                          \
    return fun(FWD(args)...);                                                  \
  }
