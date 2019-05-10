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
  template <class MorphSnd, class MorphFst>
  struct ComposedMorphism;

  template <class Obj>
  static constexpr bool is_object() {
    return meta::is_template_instance_of<Object, Obj>;
  }

  template <class Obj>
  constexpr bool is_object(Obj const &obj) {
    return is_object<Obj>();
  }

  template <class Morph>
  static constexpr bool is_morphism() {
    return meta::is_template_instance_of<Morphism, Morph>;
  }

  template <class Morph>
  constexpr bool is_morphism(Morph const &morph) {
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

    // Oprional
    template <class Elem>
    constexpr bool is_element(Elem const &elem) {
      // The following test is problematic - impl and elem are not constexpr
      // I should do this on a type level

      // if constexpr (IS_VALID2(impl, elem, impl.is_element(elem))) {
      //   return impl.is_element(elem);
      // } else {
      return is_element<Elem>();
      //}
    }

  protected:
    Impl impl;
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
    decltype(auto) operator()(X &&x) {

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

      return impl(std::forward<X>(x)); /// result;
    }

  public:
    Source source;
    Target target;

  protected:
    Impl impl;
  };
};

template <class ObjOrMorph, class Scalar>
constexpr bool compatible_scalar() {
  if constexpr (!in_category<ObjOrMorph, Vec>()) {
    return false;
  } else {
    using TrueScalar = typename std::decay_t<ObjOrMorph>::Scalar;
    return std::is_same_v<TrueScalar, std::decay_t<Scalar>>;
  }
}

template <class Morph, class Scalar,
          class = std::enable_if_t<compatible_scalar<Morph, Scalar>()>>
auto operator*(Morph morph, Scalar scalar) {
  // return Vec::ScalarProductMorphism{FWD(morph), FWD(scalar)};
  auto source = morph.source;
  auto target = morph.target;
  return Vec::Morphism{source, target,
                       [morph, scalar](auto &&x) -> decltype(auto) {
                         return scalar * morph(FWD(x));
                       }};
}

template <class Morph, class Scalar,
          class = std::enable_if_t<compatible_scalar<Morph, Scalar>()>>
auto operator*(Scalar scalar, Morph morph) {
  return morph * scalar;
}

template <class Morph1, class Morph2,
          class = std::enable_if_t<in_category<Morph1, Vec>() &&
                                   in_same_hom_set<Morph1, Morph2>()>>
auto operator+(Morph1 morph1, Morph2 morph2) {
  auto source = morph1.source;
  auto target = morph1.target;

  return Vec::Morphism{source, target,
                       [morph1, morph2](auto &&x) -> decltype(auto) {
                         return morph1(x) + morph2(x);
                       }};
}
} // namespace mathpp
