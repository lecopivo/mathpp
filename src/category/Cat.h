#pragma once

#include <type_traits>

#include "../mathpp/meta"
#include "Category.h"
#include "utils.h"

namespace mathpp {

struct Cat : Category {

  template <class Impl>
  struct Object;
  template <class SrcObj, class TrgObj, class Impl>
  struct Morphism;

  template <class Obj>
  static constexpr bool is_object() {
    return meta::is_template_instance_of<Object, Obj>;
  }

  template <class Obj>
  constexpr bool is_object(Obj const &) const {
    return is_object<Obj>();
  }

  template <class Morph>
  static constexpr bool is_morphism() {
    return meta::is_template_instance_of<Morphism, Morph>; 
  }

  template <class Morph>
  constexpr bool is_morphism(Morph const &) const {
    return is_morphism<Morph>();
  }

  template <class Impl>
  struct Object {

    Object(Impl _impl)
        : impl(std::move(impl)){};

    using Category = Cat;
    // static constexpr auto identity_morphism() { Impl::identity_morphism();

  protected:
    const Impl impl;
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
struct morphism_operation<Cat, '|'> {

  template <class F, class G>
  static constexpr bool is_valid() {
    if constexpr (!(is_morphism<F>() && is_morphism<G>() &&
                    in_category<F, Cat>())) {
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
    using Morphism = Cat::Morphism<Source, Target, Impl>;

    return Morphism(g.source, f.target, Impl(FWD(f), FWD(g)));
  }
};

} // namespace mathpp
