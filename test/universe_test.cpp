#include <iostream>

#include "meta_utils.h"
#include "universe.h"

#include "tests.h"

int main() {

  std::cout << "Testing Universe!" << std::endl << std::endl;

  float f  = 3.1415;
  auto  of = Universe::Object{1.0f};
  auto  od = Universe::Object{1.0};
  auto  oc = Universe::Object{'c'};

  auto m1 = Universe::Morphism{of, od, 1.0};
  auto m2 = Universe::Morphism{od, od, 'c'};

  test_object<Universe>(f);
  test_object<Universe>(of);
  test_object<Universe>(od);
  test_object<Universe>(oc);
  // test_object<Universe, TestMorphism<TestObject1, TestObject2>>();

  std::cout << std::endl;

  test_morphism<Universe>(f);
  test_morphism<Universe>(of);
  test_morphism<Universe>(of);
  test_morphism<Universe>(m1);
  test_morphism<Universe>(Universe::compose(m2, m1));

  std::cout << std::endl;

  test_morphism<Universe>(m1, m2);
  test_morphism<Universe>(m2, m1);

  return 0;
}
