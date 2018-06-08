#include <meta/introspection.h>
#include <utility>

namespace mathpp::concepts {

constexpr auto is_morphism = [](auto const &m) constexpr -> bool {
  return IS_VALID(m, m.source) && IS_VALID(m, m.target);
};

// Category extra
// c.is_object(o) => IS_VALID(c.identity(o))

// (c.is_morphism(F) &&
//  c.is_morphism(G) &&
//  c.is_same_object(F.source(), G.target()))
//     => IS_VALID(c.compose(F,G))
auto is_category = [](auto const &c) constexpr -> bool {
  return IS_VALID(c, c.is_object) && IS_VALID(c, c.is_morphism) &&
         IS_VALID(c, c.compose) && IS_VALID(c, c.identity);
};

// Functor extra
// (f.source().is_object(o))
//   => (IS_VALID(f, f(o)) && (f.target().is_object(f(o)))
//
// (f.source().is_morphism(m)))
//   => (IS_VALID(f, f.fmap(m) && f.target().is_morphism(f(m))))
auto is_functor = [](auto const &f) constexpr -> bool {
  return IS_VALID(f, f.source) && IS_VALID(f, f.target) && IS_VALID(f, f.fmap);
};

// Extra info about a catagory
auto has_product = [](auto const &c) constexpr -> bool {
  return IS_VALID(c, c.product) && IS_VALID(c, c.is_product);
};

} // namespace mathpp::concepts
