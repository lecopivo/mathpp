#include <algorithm>
#include <cmath>
#include <iostream>

#include <category/Set.h>
#include <meta/type_name.h>

#include <meta/general_equality.h>
#include <meta/introspection.h>

using namespace category;
using namespace boost;
using namespace mathpp::meta;

using namespace hana::literals;

struct NumericValues {

  template <class Element>
  constexpr bool is_elem(Element const &t) const {
    if (std::is_integral_v<Element> || std::is_floating_point_v<Element>)
      return true;
    else
      return false;
  }
};

struct array_set {

  template <class Element>
  constexpr bool is_elem(Element const &t) const {
    return false;
  }

  template <class T, std::size_t N>
  constexpr bool is_elem(std::array<T, N> const &t) const {
    return true;
  }
};

template <class Category, class... Morphisms>
constexpr bool basic_category_test(std::tuple<Morphisms...> morphisms) {

  auto N = sizeof...(Morphisms);

  bool result = true;

  static_for<0, N>([&](auto I) {
    auto morph = std::get<I>(morphisms);

    result &= Category::is_object(morph.source);
    result &= Category::is_object(morph.target);

    auto id_morph_id = compose(identity_morphism(morph.target), morph,
                               identity_morphism(morph.source));
  });

  static_for<0, N>([&](auto I) {
    static_for<0, N>([&](auto J) {
      auto morph_i = std::get<I>(morphisms);
      auto morph_j = std::get<J>(morphisms);

      if (morph_i.target == morph_j.source) {
        auto test_composition = compose(morph_j, morph_i);
      }
    });
  });

  return result;
}

int main() {

  //---------------------------------------------------//
  constexpr auto dum = dummy{};

  static_assert(Set::is_object(dum) == false, "");

  //---------------------------------------------------//
  constexpr auto empty = Set::empty_set{};

  static_assert(Set::is_object(empty) == true, "");
  static_assert(Set::is_elem(empty, 1) == false, "");
  static_assert(Set::is_elem(empty, 'a') == false, "");
  static_assert(Set::is_elem(empty, dummy{}) == false, "");

  //---------------------------------------------------//
  constexpr auto integers = hana::type_c<int>;

  static_assert(Set::is_object(integers) == true, "");
  static_assert(Set::is_elem(integers, 1) == true, "");
  static_assert(Set::is_elem(integers, 'a') == false, "");
  static_assert(Set::is_elem(integers, dummy{}) == false, "");

  //---------------------------------------------------//
  constexpr auto arr = std::array{'a', 'b', 'c'};

  static_assert(Set::is_object(arr) == true, "");
  static_assert(Set::is_elem(arr, 'b') == true, "");
  static_assert(Set::is_elem(arr, 'x') == false, "");
  static_assert(Set::is_elem(arr, dummy{}) == false, "");

  //---------------------------------------------------//
  constexpr auto tup = std::tuple{1, 'a', 3.14, "Hello", Set::empty_set{}};

  static_assert(Set::is_object(tup) == true, "");
  static_assert(Set::is_elem(tup, 3.14) == true, "");
  static_assert(Set::is_elem(tup, Set::empty_set{}) == true, "");
  // static_assert(Set::is_elem(tup, "Hello") == true, ""); // This fails for
  // some reason :(
  static_assert(Set::is_elem(tup, 'b') == false, "");
  static_assert(Set::is_elem(tup, dummy{}) == false, "");

  //---------------------------------------------------//
  constexpr auto nv = NumericValues{};

  static_assert(Set::is_object(nv) == true, "");
  static_assert(Set::is_elem(nv, 1) == true, "");
  static_assert(Set::is_elem(nv, 1.0) == true, "");
  static_assert(Set::is_elem(nv, 2.0f) == true, "");
  static_assert(Set::is_elem(nv, 'a') == true, "");
  static_assert(Set::is_elem(nv, dummy{}) == false, "");
  static_assert(Set::is_elem(nv, "World") == false, "");

  //---------------------------------------------------//
  constexpr auto prod = Set::product(tup, nv, arr);

  static_assert(Set::is_object(prod) == true, "");
  static_assert(Set::is_elem(prod, std::tuple{1, 0, 'a'}) == true, "");
  static_assert(Set::is_elem(prod, std::tuple{3.14, 42.0, 'b'}) == true, "");
  static_assert(Set::is_elem(prod, std::tuple{"Hello", 0, 'c'}) == true, "");
  static_assert(Set::is_elem(prod, std::tuple{"Hello", 0, "hWorld"}) == false,
                "");

  //---------------------------------------------------//
  constexpr auto sum = Set::sum(tup, nv, arr);

  static_assert(Set::is_object(sum) == true, "");
  static_assert(Set::is_elem(sum, std::tuple{0, "Hello"}) == true, "");
  static_assert(Set::is_elem(sum, std::tuple{0, 2}) == false, "");
  static_assert(Set::is_elem(sum, std::tuple{1, 2}) == true, "");
  static_assert(Set::is_elem(sum, std::tuple{2, 'a'}) == true, "");

  //---------------------------------------------------//
  constexpr auto morph  = Set::morphism{hana::type_c<int>, hana::type_c<int>,
                                       [](int x) -> int { return 2 * x; }};
  constexpr auto morph2 = Set::morphism{hana::type_c<int>, hana::type_c<int>,
                                        [](int x) -> int { return 4 * x; }};

  int b = morph(1);

  std::cout << IS_VALID(morph, morph(1)) << std::endl;
  std::cout << IS_VALID(morph, morph("asdf")) << std::endl;

  std::cout << (Set::empty_set{} == Set::empty_set{}) << std::endl;

  auto pmorph = Set::product.fmap(morph, morph2);

  auto s    = pmorph.source;
  auto t    = pmorph.target;
  auto hoho = pmorph(std::tuple{1, 2});

  std::cout << std::get<0>(hoho) << " " << std::get<1>(hoho) << std::endl;

  std::cout << IS_VALID(s, s + s) << std::endl;
  std::cout << IS_VALID(s, s.proj(0_c)) << std::endl;
  std::cout << IS_VALID(s, s.proj(0_c)) << std::endl;
  std::cout << IS_VALID2(s, t, s + t) << std::endl;
  std::cout << IS_VALID2(s, t, (std::tuple{s, t})) << std::endl;
  std::cout << IS_VALID2(s, t, s == t) << std::endl;

  std::cout << are_equal(1, 1.0) << std::endl;
  auto d = dummy{};
  std::cout << IS_VALID(d, is_elem(d, dummy{})) << std::endl;

  auto m1 = Set::morphism{hana::type_c<int>, hana::type_c<int>,
                          [](int i) { return i; }};
  auto m2 = Set::morphism{hana::type_c<int>, hana::type_c<int>,
                          [](int i) { return i >= 0 ? i : 0; }};

  auto eq = Set::equalizer{m1, m2};

  static_assert(Set::is_object(eq) == true, "");
  static_assert(Set::is_elem(eq, 0) == true, "");
  static_assert(Set::is_elem(eq, 42) == true, "");
  static_assert(Set::is_elem(eq, -1) == false, "");
  static_assert(Set::is_elem(eq, "asdf") == false, "");
  static_assert(Set::is_elem(eq, dummy{}) == false, "");

  //--------------------------------------//
  constexpr auto pr = Set::morphism{hana::type_c<int>, hana::type_c<int>,
                                    [](int i) { return ((i % 2) + 2) % 2; }};

  constexpr auto coeq = Set::projection_coequalizer{pr};

  static_assert(Set::is_object(coeq) == true, "");
  static_assert(Set::is_elem(coeq, 0) == true, "");
  static_assert(Set::is_elem(coeq, 1) == true, "");
  static_assert(Set::is_elem(coeq, 2) == false, "");
  static_assert(Set::is_elem(coeq, -1) == false, "");
  static_assert(Set::is_elem(coeq, "asfd") == false, "");

  //-------------------------------------//
  constexpr auto ars = array_set{};

  static_assert(Set::is_object(ars) == true, "");
  static_assert(Set::is_elem(ars, std::array{1, 2, 3}) == true, "");
  static_assert(Set::is_elem(ars, std::array{'a', 'b', 'c'}) == true, "");

  constexpr auto proj = Set::morphism{ars, ars, [](auto arr) {
                                        std::sort(arr.begin(), arr.end());
                                        return arr;
                                      }};

  auto c = proj(std::array{2, 3, 1, -1});

  auto arcoeq = Set::projection_coequalizer{proj};

  static_assert(Set::is_object(arcoeq) == true, "");
  assert(Set::is_elem(arcoeq, std::array{1, 2, 3}) == true);
  assert(Set::is_elem(arcoeq, std::array{3, 2, 1}) == false);

  for (auto x : c)
    std::cout << x << " ";

  return 0;
}
