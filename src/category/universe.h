#pragma once

#include "category_utils.h"
#include "meta_utils.h"

#include <type_traits>

struct Universe {

  template <class Impl> struct Object;
  template <class SrcObj, class TrgObj, class Impl> struct Morphism;
  template <class MorphSnd, class MorphFst> struct ComposedMorphism;

  template <class Obj>
  static constexpr bool is_object = is_template_instance_of<Object, Obj>;

  template <class Morph>
  static constexpr bool is_morphism = is_template_instance_of<Morphism, Morph>;

  template <class MorphSnd, class MorphFst>
  static auto compose(MorphSnd morphSnd, MorphFst morphFst) {

    using Source = typename MorphFst::Source;
    using Target = typename MorphSnd::Target;

    return Morphism{Source{}, Target{},
                    ComposedMorphism{std::move(morphSnd), std::move(morphFst)}};
  }

  template <class Impl> struct Object {

    Object(){};
    Object(Impl const &){};

    using Category = Universe;
    // static constexpr auto identity_morphism() { Impl::identity_morphism();
  };

  template <class SrcObj, class TrgObj, class Impl>
  // Check if `Impl` provide `Source` and `Target`
  struct Morphism {

    Morphism(SrcObj const &, TrgObj const &, Impl _impl)
        : impl(std::move(_impl)){};

    Morphism(Impl _impl) : impl(std::move(_impl)){};

    using Category = Universe;
    using Source   = SrcObj;
    using Target   = TrgObj;

  public:
    Impl impl;
  };

  template <class MorphSnd, class MorphFst> struct ComposedMorphism {

    ComposedMorphism(MorphSnd _second_morphism, MorphFst _first_morphism)
        : first_morphism(std::move(_first_morphism)),
          second_morphism(std::move(_second_morphism)){};

  public:
    MorphFst first_morphism;
    MorphSnd second_morphism;
    ;
  };
};
