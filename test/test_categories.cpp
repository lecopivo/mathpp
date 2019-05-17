#include <cassert>
#include <cmath>
#include <iostream>

#include <mathpp/category>
#include <mathpp/meta>
#include <mathpp/test>

//#include "tests.h"

using namespace mathpp;

// auxiliary tags
struct One {};
struct Two {};
struct Three {};

template <class T> struct TypeObjectImpl {

  template <class Elem> static constexpr bool is_element() {
    return std::is_same_v<Elem, T>;
  }
};

template <class T> constexpr auto TypeSet() {
  return Set::Object<TypeObjectImpl<T>>{{}};
}

int main() {

  { // Test of Cat
    auto object1  = Cat::Object<One>{{}};
    auto object2  = Cat::Object<Two>{{}};
    auto object3  = Cat::Object<Three>{{}};
    auto morphFst = Cat::Morphism{object1, object2, One{}};
    auto morphSnd = Cat::Morphism{object2, object3, Two{}};
    test_Cat::test_morphism(morphSnd, morphFst);
  }

  {
    auto object_int    = TypeSet<int>();
    auto object_float  = TypeSet<float>();
    auto object_double = TypeSet<double>();
    auto morphFst      = Set::Morphism{object_int, object_float,
                                  [](int x) -> float { return sqrt(x); }};
    auto morphSnd      = Set::Morphism{object_float, object_double,
                                  [](float x) -> double { return sqrt(x); }};
    test_Set::test_morphism(morphSnd, morphFst);
  }

  {
    using namespace Eigen;

    auto R2 = EigenVecSpc<double, 2, 1>();
    auto R3 = EigenVecSpc<double, 3, 1>();
    auto R4 = EigenVecSpc<double, 4, 1>();

    Vector2d v2 = Vector2d::Random();
    Vector3d v3 = Vector3d::Random();
    Vector4d v4 = Vector4d::Random();

    Matrix<double, 3, 2> M1 = Matrix<double, 3, 2>::Random();
    Matrix<double, 4, 3> M2 = Matrix<double, 4, 3>::Random();

    auto morphFst = EigenLinearMap(M1);
    auto morphSnd = EigenLinearMap(M2);
    test_Set::test_morphism_elem(morphSnd, morphFst, v2);

    auto sumMorph  = morphFst + morphFst;
    auto prodMorph = 5.0 * morphSnd;
    auto comp      = prodMorph | sumMorph;
    auto u3        = comp(v2);

    std::cout << u3.transpose() << std::endl;

    std::cout << (5.0 * M2 * (M1 * v2 + M1 * v2)).transpose() << std::endl;

    auto composed = prodMorph | sumMorph;
    auto v        = composed.impl(v2);
    auto v1       = morphSnd(morphFst(v2));
    std::cout << "Is element: " << R4.is_element(v1) << std::endl;
  }

  return 0;
}
