#pragma once

#include <type_traits>

#include "../mathpp/meta"
#include "Category.h"
#include "utils.h"

namespace mathpp {

struct Set : Category {

  template <class Impl>
  struct Object;
  template <class SrcObj, class TrgObj, class Impl>
  struct Morphism;

  template <class Obj>
  static constexpr bool is_object() {
    return meta::is_template_instance_of<Object, Obj>;
  }

  template <class Obj>
  constexpr bool is_object(Obj const &obj) const {
    return is_object<Obj>();
  }

  template <class Morph>
  static constexpr bool is_morphism() {
    return meta::is_template_instance_of<Morphism, Morph>;
  }

  template <class Morph>
  constexpr bool is_morphism(Morph const &morph) const {
    return is_morphism<Morph>();
  }

  template <class Impl>
  struct Object {

    Object(Impl _impl)
        : impl(std::move(_impl)){};

    using Category = Set;

    // Required
    template <class Elem>
    static constexpr bool is_element() {
      return Impl::template is_element<Elem>();
    }

    // Oprional
    template <class Elem>
    constexpr bool is_element(Elem const &elem) const {
      // if constexpr (IS_VALID2(impl, elem, impl.is_element(elem))) {
      //   return impl.is_element(elem);
      // } else {
      return is_element<Elem>();
      //}
    }

  protected:
    const Impl impl;
  };

  template <class SrcObj, class TrgObj, class Impl>
  // Check if `Impl` provide `Source` and `Target`
  struct Morphism {

    Morphism(SrcObj _source, TrgObj _target, Impl _impl)
        : source{std::move(_source)}
        , target{std::move(_target)}
        , impl{std::move(_impl)} {};

    using Category = Set;
    using Source   = SrcObj;
    using Target   = TrgObj;

    // Required
    template <class X, class = std::enable_if<Source::template is_element<X>()>>
    decltype(auto) operator()(X &&x) const {

      // Input has te be an element of Source
      assert(source.is_element(x));

      // Check if `Impl` is actually collable with T
      static_assert(std::is_invocable_v<Impl, X>,
                    "Invalid morphism: Function "
                    "does not accepts elements of "
                    "the specified source set!");
      // The result of Impl(T) has to be element of TrgObj
      static_assert(Target::template is_element<std::invoke_result_t<Impl, X>>,
                    "Invalid morphism: Returned element does not belong to the "
                    "specified target set!");

      // call the actual function
      decltype(auto) result = impl(std::forward<X>(x));

      // The result has to be an element of Target
      assert(target.is_element(x));

      return result;
    }

  public:
    const Source source;
    const Target target;

  protected:
    const Impl impl;
  };
};

//   ___                        _ _   _
//  / __|___ _ __  _ __  ___ __(_) |_(_)___ _ _
// | (__/ _ \ '  \| '_ \/ _ (_-< |  _| / _ \ ' \
//  \___\___/_|_|_| .__/\___/__/_|\__|_\___/_||_|
//                |_|

template <>
struct morphism_operation<Set, '|'> {

  template <class F, class G>
  static constexpr bool is_valid() {
    if constexpr (!(is_morphism<F>() && is_morphism<G>() &&
                    in_category<F, Set>())) {
      return false;
    } else {
      return are_composable<F, G>();
    }
  }

  template <class F, class G, class = std::enable_if_t<is_valid<F, G>()>>
  struct Impl {
    Impl(const F _f, const G _g)
        : f(std::move(_f))
        , g(std::move(_g)) {
      static_assert(!std::is_reference_v<F>, "F should not be a reference!");
      static_assert(!std::is_reference_v<G>, "G should not be a reference!");
    }

    template <class X>
    constexpr auto operator()(X &&x) const {
      return f(g(FWD(x)));
    }

  public:
    const F f;
    const G g;
  };

  template <class F, class G, class = std::enable_if_t<is_valid<F, G>()>>
  static constexpr auto call(F &&f, G &&g) {
    using DF = std::decay_t<F>;
    using DG = std::decay_t<G>;

    using Source   = typename DG::Source;
    using Target   = typename DF::Target;
    using Impl     = Impl<DF, DG>;
    using Morphism = Set::Morphism<Source, Target, Impl>;

    return Morphism(g.source, f.target, Impl(FWD(f), FWD(g)));
  }
};

} // namespace mathpp
