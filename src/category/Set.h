#pragma once

#include <type_traits>

#include "../mathpp/meta"
#include "Category.h"

namespace mathpp {

struct Set : Category {

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
  static auto compose(MorphSnd &&morphSnd, MorphFst &&morphFst) {

    auto source = morphFst.source;
    auto target = morphSnd.target;

    return Morphism{source, target,
                    [m2 = FWD(morphSnd), m1 = FWD(morphFst)](
                        auto &&x) -> decltype(auto) { return m2(m1(FWD(x))); }};
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
    constexpr bool is_element(Elem const &elem) {
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

    using Category = Set;
    using Source   = SrcObj;
    using Target   = TrgObj;

    // Required
    template <class X, class = std::enable_if<Source::template is_element<X>()>>
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

      return result;
    }

  public:
    Source source;
    Target target;

  protected:
    Impl impl;
  };

  template <class MorphSnd, class MorphFst>
  struct ComposedMorphism {

    ComposedMorphism(MorphSnd _second_morphism, MorphFst _first_morphism)
        : first_morphism(std::move(_first_morphism))
        , second_morphism(std::move(_second_morphism)){};

    template <class X>
    decltype(auto) operator()(X &&x) {
      return second_morphism(first_morphism(std::forward<X>(x)));
    }

  public:
    MorphFst first_morphism;
    MorphSnd second_morphism;
  };
};

} // namespace mathpp
