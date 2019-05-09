#pragma once

#include <type_traits>

#include "Cat.h"
#include <mathpp/meta>

namespace mathpp {

struct Vec {

  template <class Impl>
  struct Object;
  template <class SrcObj, class TrgObj, class Impl>
  struct Morphism;
  template <class MorphSnd, class MorphFst>
  struct ComposedMorphism;

  template <class Obj>
  static constexpr bool is_object = meta::is_template_instance_of<Object, Obj>;

  template <class Morph>
  static constexpr bool is_morphism =
      meta::is_template_instance_of<Morphism, Morph>;

  template <class MorphSnd, class MorphFst>
  // Check if `MorphSnd` and `MorphFst` are morphisms of this category and that
  // they can be composed
  static auto compose(MorphSnd morphSnd, MorphFst morphFst) {

    using Source = typename MorphFst::Source;
    using Target = typename MorphSnd::Target;

    return Morphism{Source{}, Target{},
                    ComposedMorphism{std::move(morphSnd), std::move(morphFst)}};
  }

  template <class Impl>
  struct Object {

    Object(){};
    Object(Impl const &){};

    using Category    = Vec;
    using scalar_type = typename Impl::scalar_type;

    constexpr auto zero() const { return impl.zero(); }

    template <class Elem>
    static constexpr bool is_element = Impl::template is_element<Elem>;

    // template <class Elem> constexpr bool is_elemet(Elem const &elem)  const{
    //   return impl.is_element(elem);
    // }

  protected:
    Impl impl;
  };

  template <class SrcObj, class TrgObj, class Impl>
  // Check if `Impl` provide `Source` and `Target`
  // Check if `SrcObj` and `TrgObj` are vector fields over the same field
  struct Morphism {

    Morphism(SrcObj const &, TrgObj const &, Impl _impl)
        : impl{std::move(_impl)} {};
    Morphism(Impl _impl)
        : impl{std::move(_impl)} {};

    using Category    = Vec;
    using Source      = SrcObj;
    using Target      = TrgObj;
    using scalar_type = typename Source::scalar_type;

    template <class X> //, class = std::enable_if_t<Impl::Source::is_element<T>>
    decltype(auto) operator()(X &&x) {

      // Check if `Impl` is actually collable with T
      static_assert(std::is_invocable_v<Impl, X>,
                    "Invalid morphism: Function "
                    "does not accepts elements of "
                    "the specified source vector space!");
      // The result of Impl(T) has to be element of TrgObj
      static_assert(Target::template is_element<std::invoke_result_t<Impl, X>>,
                    "Invalid morphism: Returned element does not belong to the "
                    "specified target vector space!");

      return impl(std::forward<X>(x));
    }

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

  template <class Morph>
  struct ScalarProductMorphism {

    ScalarProductMorphism(Morph _morph, typename Morph::scalar_type _s)
        : morph(std::move(_morph))
        , s(std::move(s)) {}

    template <class X>
    decltype(auto) operator()(X &&x) {
      return s * morph(std::forward<X>(x));
    }

  protected:
    Morph                       morph;
    typename Morph::scalar_type s;
  };

  template <class MorphSnd, class MorphFst>
  struct SumMorphism {

    SumMorphism(MorphSnd _second_morphism, MorphFst _first_morphism)
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

  template<class MorphFst, class MorphSnd, class = std::enable_if_t< > >
  auto operator+(MorphFst && morphFst, MorphSnd &&morphSnd)

} // namespace mathpp
