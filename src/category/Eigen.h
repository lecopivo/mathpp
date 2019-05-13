#pragma once

#include <Eigen/Dense>
#include <iostream>

#include "Vec.h"

namespace mathpp {

struct EigenTypeDetector {
  template <class Derived>
  void operator()(Eigen::MatrixBase<Derived> const &) {}
};

template <class T>
constexpr bool is_Eigen_type() {
  return std::is_invocable_v<EigenTypeDetector, T>;
}

template <class S, int RowDim, int ColDim,
          class = std::enable_if_t<(RowDim > 0) && (ColDim > 0)>>
struct EigenObjectImpl {

  using Scalar = S;

  template <class Elem>
  static constexpr bool is_element() {

    using E = std::decay_t<Elem>;
    
    if constexpr (!is_Eigen_type<E>()) {
      return false;
    } else {
      constexpr int row_dim = Eigen::internal::traits<E>::RowsAtCompileTime;
      constexpr int col_dim = Eigen::internal::traits<E>::ColsAtCompileTime;

      if constexpr (row_dim != RowDim || col_dim != ColDim) {
        return false;
      } else {
        return true;
      }
    }
  }
};

template <class Scalar, int RowDim, int ColDim,
          class = std::enable_if_t<(RowDim > 0) && (ColDim > 0)>>
constexpr auto EigenVecSpc() {
  return Vec::Object<EigenObjectImpl<Scalar, RowDim, ColDim>>{{}};
}

template <class Scalar, int RowDim, int ColDim>
auto EigenLinearMap(Eigen::Matrix<Scalar, RowDim, ColDim> const &matrix) {

  auto source = EigenVecSpc<Scalar, ColDim, 1>();
  auto target = EigenVecSpc<Scalar, RowDim, 1>();

  return Vec::Morphism{source, target, [&matrix](auto &&x) -> decltype(auto) {
                         return matrix * FWD(x);
                       }};
}

} // namespace mathpp
