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

template <class T>
struct TypeObjectImpl {

  template <class Elem>
  static constexpr bool is_element() {
    return std::is_same_v<Elem, T>;
  }
};

template <class T>
constexpr auto TypeSet() {
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
    auto R2       = EigenVecSpc<double, 2, 1>();
    auto R3       = EigenVecSpc<double, 3, 1>();
    auto R4       = EigenVecSpc<double, 4, 1>();
    auto v2       = Eigen::Vector2d{};
    auto v3       = Eigen::Vector3d{};
    auto v4       = Eigen::Vector4d{};
    auto M1       = Eigen::Matrix<double, 3, 2>{};
    auto M2       = Eigen::Matrix<double, 4, 3>{};
    auto morphFst = EigenLinearMap(M1);
    auto morphSnd = EigenLinearMap(M2);
    test_Set::test_morphism_elem(morphSnd, morphFst, v2);
    auto sumMorph  = morphFst + morphFst;

    auto u = sumMorph(v2);
    
    auto c = v2 + v2;

    using cat = get_first_or_second_category<decltype(v2), decltype(v2)>;

    //std::cout << "cat: " << meta::type_name<decltype(sumMorph)>() << std::endl;

    std::cout << "Operation valid: " << is_morphism_operation_valid<'+', decltype(v2), decltype(v2)>() << std::endl;
    
    auto prodMorph = 5.0 * morphSnd;

    auto u2 = prodMorph(v3);

    auto comp = prodMorph | sumMorph;

    std::cout << "cat: " << meta::type_name<decltype(comp)>() << std::endl;

    auto u3 = comp(v2);
    
    //auto composed  = prodMorph | sumMorph;
    //auto v         = composed.impl(v2);
    // auto v1 = morphSnd(morphFst(v2));
    // std::cout << "Is element: " << R4.is_element(v1) << std::endl;
    // auto v = composed(v2);
    // test_Set::test_morphism_elem(morphSnd, morphFst, v2);
  }

  return 0;
}
