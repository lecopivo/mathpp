#pragma once

#include <type_traits>

#include "../mathpp/meta"
#include "Cat.h"
#include "utils.h"

namespace mathpp {

struct Vec : Category {

  template <class Impl>
  struct Object;
  template <class SrcObj, class TrgObj, class Impl>
  struct Morphism;
  template <class SrcObj, class TrgObj>
  struct HomSetImpl;

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

  template <class MorphSnd, class MorphFst>
  // Check if `MorphSnd` and `MorphFst` are morphisms of this category and that
  // they can be composed
  static auto compose(MorphSnd morphSnd, MorphFst morphFst) {

    auto source = morphFst.source;
    auto target = morphSnd.target;

    return Morphism{source, target,
                    [m2 = std::move(morphSnd), m1 = std::move(morphFst)](
                        auto &&x) -> decltype(auto) { return m2(m1(FWD(x))); }};
  }

  template <class Impl>
  struct Object {

    Object(Impl _impl)
        : impl(std::move(_impl)){};

    using Category = Vec;

    // Required
    using Scalar = typename Impl::Scalar;

    // Required
    template <class Elem>
    static constexpr bool is_element() {
      return Impl::template is_element<Elem>();
    }

    // Optional
    template <class Elem>
    constexpr bool is_element(Elem const &elem) const {
      // The following test is problematic - impl and elem are not constexpr
      // I should do this on a type level

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

    using Category = Vec;
    using Source   = SrcObj;
    using Target   = TrgObj;
    using Scalar   = typename Source::Scalar;

    // Required
    template <class X,
              class = std::enable_if_t<Source::template is_element<X>()>>
    decltype(auto) operator()(X &&x) const {

      // Input has te be an element of Source
      assert(source.is_element(x));

      // Check if `Impl` is actually collable with T
      static_assert(std::is_invocable_v<Impl, X>,
                    "Invalid morphism: Function "
                    "does not accepts elements of "
                    "the specified source set!");
      // The result of Impl(T) has to be element of TrgObj
      static_assert(
          Target::template is_element<std::invoke_result_t<Impl, X>>(),
          "Invalid morphism: Returned element does not belong to the "
          "specified target set!");

      // call the actual function
      decltype(auto) result = impl(std::forward<X>(x));

      // The result has to be an element of Target
      assert(target.is_element(result));

      return result;
    }

  public:
    const Source source;
    const Target target;

  public:
    const Impl impl;
  };

  template <class SrcObj, class TrgObj>
  using HomSet = Object<HomSetImpl<SrcObj, TrgObj>>;

  template <class SrcObj, class TrgObj>
  struct HomSetImpl {

    HomSetImpl(SrcObj _source, TrgObj _target)
        : source(std::move(_source))
        , target(std::move(_target)) {}

    using Source = SrcObj;
    using Target = TrgObj;

    // Required
    using Scalar = typename TrgObj::Scalar;

    // Required
    template <class Elem>
    static constexpr bool is_element() {
      if constexpr (!Vec::is_morphism<Elem>()) {
        return false;
      } else {
        return std::is_same_v<SrcObj, typename Elem::Source> &&
               std::is_same_v<TrgObj, typename Elem::Target>;
      }
    }

  public:
    const Source source;
    const Target target;
  };
};

//   ___                        _ _   _
//  / __|___ _ __  _ __  ___ __(_) |_(_)___ _ _
// | (__/ _ \ '  \| '_ \/ _ (_-< |  _| / _ \ ' \
//  \___\___/_|_|_| .__/\___/__/_|\__|_\___/_||_|
//                |_|

//    _      _    _ _ _   _
//   /_\  __| |__| (_) |_(_)___ _ _
//  / _ \/ _` / _` | |  _| / _ \ ' \
// /_/ \_\__,_\__,_|_|\__|_\___/_||_|

template <>
struct morphism_operation<Vec, '+'> {

  template <class F, class G>
  static constexpr bool is_valid() {
    return in_same_hom_set<F, G>() && in_category<F, Vec>();
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
      return f(x) + g(x);
    }

  public:
    const F f;
    const G g;
  };

  template <class F, class G, class = std::enable_if_t<is_valid<F, G>()>>
  static constexpr auto call(F &&f, G &&g) {
    using DF = std::decay_t<F>;
    using DG = std::decay_t<G>;

    using Source   = typename DF::Source;
    using Target   = typename DF::Target;
    using Impl     = Impl<DF, DG>;
    using Morphism = Vec::Morphism<Source, Target, Impl>;

    return Morphism(f.source, f.target, Impl(FWD(f), FWD(g)));
  }
};

//  __  __      _ _   _      _ _         _   _
// |  \/  |_  _| | |_(_)_ __| (_)__ __ _| |_(_)___ _ _
// | |\/| | || | |  _| | '_ \ | / _/ _` |  _| / _ \ ' \
// |_|  |_|\_,_|_|\__|_| .__/_|_\__\__,_|\__|_\___/_||_|
//                     |_|

template <>
struct morphism_operation<Vec, '*'> {

  template <class F, class G>
  static constexpr bool is_valid() {
    using DF = std::decay_t<F>;
    using DG = std::decay_t<G>;
    // Is F morphism?
    if constexpr (in_category<DF, Vec>() && is_morphism<DF>()) {
      // is G a scalar?
      return std::is_same_v<typename DF::Scalar, DG>;
    } else {
      // Is G morphism?
      if constexpr (in_category<DG, Vec>() && is_morphism<DG>()) {
        return std::is_same_v<typename DG::Scalar, DF>;
      } else {
        return false;
      }
    }
  }

  template <class F, class G, class = std::enable_if_t<is_valid<F, G>()>>
  struct Impl {
    Impl(F _f, G _g)
        : f(std::move(_f))
        , g(std::move(_g)) {
      static_assert(!std::is_reference_v<F>, "F should not be a reference!");
      static_assert(!std::is_reference_v<G>, "G should not be a reference!");
    }

    template <class X>
    constexpr auto operator()(X &&x) const {
      if constexpr (is_morphism<F>()) {
        return f(FWD(x)) * g;
      } else {
        return f * g(FWD(x));
      }
    }

  public:
    const F f;
    const G g;
  };

  template <class F, class G, class = std::enable_if_t<is_valid<F, G>()>>
  static constexpr auto call(F &&f, G &&g) {

    using DF = std::decay_t<F>;
    using DG = std::decay_t<G>;

    if constexpr (is_morphism<F>()) {

      using Source   = typename DF::Source;
      using Target   = typename DF::Target;
      using Impl     = Impl<DF, DG>;
      using Morphism = Vec::Morphism<Source, Target, Impl>;

      return Morphism(f.source, f.target, Impl(FWD(f), FWD(g)));
    } else {

      using Source   = typename DG::Source;
      using Target   = typename DG::Target;
      using Impl     = Impl<DF, DG>;
      using Morphism = Vec::Morphism<Source, Target, Impl>;

      return Morphism(g.source, g.target, Impl(FWD(f), FWD(g)));
    }
  }
};

} // namespace mathpp
