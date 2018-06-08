#include <boost/hana.hpp>

namespace mathpp::meta {

template <class T> constexpr void test_helper(T &&t) {}

#define IS_VALID(x, expr)                                                      \
  (boost::hana::is_valid([](auto &&x) -> decltype(expr) {})(x))
#define IS_CONSTEXPR(...) noexcept(mathpp::meta::test_helper((__VA_ARGS__, 0)))

} // namespace mathpp::meta
