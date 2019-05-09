#include <iostream>

#include <mathpp/category>
#include <mathpp/meta>

#include "tests.h"

using namespace mathpp;

int main() {

  std::cout << "Testing Cat!" << std::endl << std::endl;

  float f  = 3.1415;
  auto  of = Cat::Object{1.0f};
  auto  od = Cat::Object{1.0};
  auto  oc = Cat::Object{'c'};

  auto m1 = Cat::Morphism{of, od, 1.0};
  auto m2 = Cat::Morphism{od, od, 'c'};

  test_object<Cat>(f);
  test_object<Cat>(of);
  test_object<Cat>(od);
  test_object<Cat>(oc);
  // test_object<Cat, TestMorphism<TestObject1, TestObject2>>();

  std::cout << std::endl;

  test_morphism<Cat>(f);
  test_morphism<Cat>(of);
  test_morphism<Cat>(of);
  test_morphism<Cat>(m1);
  test_morphism<Cat>(Cat::compose(m2, m1));

  std::cout << std::endl;

  test_morphism<Cat>(m1, m2);
  test_morphism<Cat>(m2, m1);

  return 0;
}
