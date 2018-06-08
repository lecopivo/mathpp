#include <iostream>

#include <category/type_category.h>
#include <concepts/category.h>
#include <meta/type_name.h>

using namespace std;
using namespace mathpp;
using namespace mathpp::category;

struct A {};
struct B {};
struct C {};

constexpr bool foo(int a) { return IS_CONSTEXPR(a); }

int main() {

  constexpr type_category tcat;

  constexpr auto objA = type_object<A>{};
  constexpr auto objB = type_object<B>{};
  constexpr auto objC = type_object<C>{};

  constexpr auto g  = make_type_morphism<A, B>([](A a) -> B { return B{}; });
  constexpr auto f  = make_type_morphism<B, C>([](B b) -> C { return C{}; });
  constexpr auto fg = tcat.compose(f, g);

  cout << "Testing object comparison: "
       << (tcat.is_same(objA, objA) && !tcat.is_same(objA, objB) ? "passed"
                                                                 : "failed")
       << endl;

  cout << "Testing category concept: "
       << (concepts::is_category(tcat) ? "passed" : "failed") << endl;

  cout << "Testing morphism concept: "
       << ((concepts::is_morphism(g) && concepts::is_morphism(f) &&
            concepts::is_morphism(fg))
               ? "passed"
               : "failed")
       << endl;

  auto p = tcat.product(objA, objB);
  auto m = tcat.product.fmap(g, f);
  auto q = m(std::tuple(A{}, B{}));

  auto s = tcat.sum(objA, objB);
  auto h = tcat.sum.fmap(g, f);
  auto v = std::variant<A,B>(A{});
  constexpr int I = v.index();
  //auto r = h(std::variant<A, B>(A{}));

  return 0;
}
