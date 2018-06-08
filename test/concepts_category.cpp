#include <iostream>

#include <concepts/category.h>

using namespace std;
using namespace mathpp::concepts;

struct cat {

  constexpr cat() {}

  static constexpr auto is_object   = [](auto &&obj) { return true; };
  static constexpr auto is_morphism = [](auto &&morph) { return true; };
  static constexpr auto compose     = [](auto &&f, auto &&g) { return 0; };
};

int main() {

  cout << "Is `cat` a category: " << is_category(cat{}) << endl;
  cout << "Is `int` a category: " << is_category(int{}) << endl;

  return 0;
}
