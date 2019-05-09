#include <iostream>

#include <cmath>

#include <mathpp/category>
#include <mathpp/meta>

#include "tests.h"

using namespace mathpp;

template <class T> struct TypeObjectImpl {

  template <class Elem>
  static constexpr bool is_element = std::is_same_v<Elem, T>;
};

template <class T> using TypeObject = Set::Object<TypeObjectImpl<T>>;

int main() {
  /*
  std::cout << "Testing Set!" << std::endl << std::endl;

  float f  = 3.1415;
  auto  of = TypeObject<float>{};
  auto  od = TypeObject<double>{};
  auto  oc = TypeObject<char>{};

  auto m1 = Set::Morphism{of, od, [](float x) -> double { return 2.0f; }};
  auto m2 = Set::Morphism{od, od, [](double x) -> double { return sin(x); }};

  test_object<Set>(f);
  test_object<Set>(of);
  test_object<Set>(od);
  test_object<Set>(oc);
  // test_object<Set, TestMorphism<TestObject1, TestObject2>>();

  std::cout << std::endl;

  test_morphism<Set>(f);
  test_morphism<Set>(of);
  test_morphism<Set>(of);
  test_morphism<Set>(m1);
  test_morphism<Set>(Set::compose(m2, m1));

  std::cout << m1(1) << std::endl;
  std::cout << m2(2) << std::endl;
  std::cout << Set::compose(m2, m1)(1) << std::endl;

  std::cout << std::endl;

  // test_morphism<Set>(m1, m2);
  // test_morphism<Set>(m2, m1);
  */
  return 0;
}
