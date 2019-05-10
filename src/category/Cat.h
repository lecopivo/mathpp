#pragma once

#include <type_traits>

#include "../mathpp/meta"
#include "Category.h"

namespace mathpp {

struct Cat : Category {

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
  constexpr bool is_object(Obj const &) {
    return is_object<Obj>();
  }

  template <class Morph>
  static constexpr bool is_morphism() {
    return meta::is_template_instance_of<Morphism, Morph>;
  }

  template <class Morph>
  constexpr bool is_morphism(Morph const &) {
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
        : impl(std::move(impl)){};

    using Category = Cat;
    // static constexpr auto identity_morphism() { Impl::identity_morphism();

  protected:
    Impl impl;
  };

  template <class SrcObj, class TrgObj, class Impl>
  // Check if `Impl` provide `Source` and `Target`
  struct Morphism {

    Morphism(SrcObj _source, TrgObj _target, Impl _impl)
        : source(std::move(_source))
        , target(std::move(_target))
        , impl(std::move(_impl)){};

    using Category = Cat;
    using Source   = SrcObj;
    using Target   = TrgObj;

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

  public:
    MorphFst first_morphism;
    MorphSnd second_morphism;
    ;
  };
};

} // namespace mathpp
