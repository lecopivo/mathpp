#pragma once

#include <type_traits>

#include "../mathpp/meta"
#include "Vec.h"
#include "operations.h"
#include "utils.h"

namespace mathpp {

template <class BaseCategory>
// The BaseCategory need internal HomSet!
// Every object in the BaseCategory needs to have a zero element
struct Diff : Category {

  template <class Impl> struct Object;
  template <class SrcObj, class TrgObj, class Impl> struct Morphism;

  template <class Obj> static constexpr bool is_object() {
    return BaseCategory::template is_object<Object, Obj>();
  }

  template <class Obj> constexpr bool is_object(Obj const &obj) const {
    return is_object<Obj>();
  }

  template <class Morph> static constexpr bool is_morphism() {
    return meta::is_template_instance_of<Morphism, Morph>;
  }

  template <class Morph> constexpr bool is_morphism(Morph const &morph) const {
    return is_morphism<Morph>();
  }

  // template <class Impl> struct Object {

  //   Object(Impl _impl) : impl(std::move(_impl)) {
  //     static_assert(BaseCategory::template is_object<Impl>,
  //                   "Implementation of category `Diff<BaseCategory>` can be "
  //                   "only objects of `BaseCategory`");
  //   };

  //   using Category = Diff;

  //   // Required
  //   template <class Elem> static constexpr bool is_element() {
  //     return Impl::template is_element<Elem>();
  //   }

  //   // Oprional
  //   template <class Elem> constexpr bool is_element(Elem const &elem) const {
  //     // The following test is problematic - impl and elem are not constexpr
  //     // I should do this on a type level

  //     // if constexpr (IS_VALID2(impl, elem, impl.is_element(elem))) {
  //     //   return impl.is_element(elem);
  //     // } else {
  //     return is_element<Elem>();
  //     //}
  //   }

  // protected:
  //   const Impl impl;
  // };

  template <class SrcObj, class TrgObj, class Impl>
  // Check if `Impl` provide `Source` and `Target`
  // Check if `Impl` provide `derivative() const`
  struct Morphism {

    Morphism(SrcObj _source, TrgObj _target, Impl _impl)
        : source{std::move(_source)}, target{std::move(_target)},
          impl{std::move(_impl)} {};

    using Category = Diff;
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
};

//    _      _    _ _ _   _
//   /_\  __| |__| (_) |_(_)___ _ _
//  / _ \/ _` / _` | |  _| / _ \ ' \
// /_/ \_\__,_\__,_|_|\__|_\___/_||_|

//  __  __      _ _   _      _ _         _   _
// |  \/  |_  _| | |_(_)_ __| (_)__ __ _| |_(_)___ _ _
// | |\/| | || | |  _| | '_ \ | / _/ _` |  _| / _ \ ' \
// |_|  |_|\_,_|_|\__|_| .__/_|_\__\__,_|\__|_\___/_||_|
//                     |_|

template <class BaseCategory>
struct morphism_operation<Diff<BaseCategory>, '*'> {

  using ThisCat = Diff<BaseCategory>;

  /*
   *
   * Multiplication F*G is valid for
   *   F: V --> Hom(U2,U3)
   *   G: V --> Hom(U1,U2)
   * where
   */
  template <class F, class G> static constexpr bool is_valid() {
    using DF = std::decay_t<F>;
    using DG = std::decay_t<G>;

    if constexpr (!(in_category<DF, ThisCat>() && has_same_source<DF, DG>())) {
      return false;
    } else {
      using HomF = Forget<ThisCat, BaseCategory, DF::Target>;
      using HomG = Forget<ThisCat, BaseCategory, DG::Target>;
      if constexpr (!(is_hom_set<HomF>() && is_hom_set<HomG>() &&
                      in_category<HomF, BaseCategory>())) {
        return false;
      } else {
        return std::is_same_v<typename HomG::Target, typeame HomF::Source>;
      }
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
      return f(x) + g(x);
    }
    
    constexpr auto derivative() const{
      return derivative(f)*g + f*derivative(g);            
    }

  public:
    const F f;
    const G g;
  };

};
/*
template <class BaseCategory, class Src, class Trg, class Impl>
auto derivative(
  typename Diff<BaseCategory>::template Morphism<Src, Trg, Impl> const
      &morph) {

using DCat = Diff<BaseCategory>;

// Is it a morphism of the base category?
// First extract info
if constexpr (BaseCategory::template is_morphism<Impl>()) {

  return DCat::Morphism{
      morph.source,
      BaseCategory::HomSet{morph.impl.source, morph.impl.target},
      ConstantMorphismImpl{morph.impl}};
} else {

  // Does it come from an operation?
  // using OperationInfo = typename
  // meta::template_instance<morphism_operation<

  // case '|'
  (derivative(impl.f) | impl.g) * derivative(impl.g)
      // The multiplication makes sense only in Diff<BaseClass>!!!

      // case '+'
      return Diff<BaseCategory>::template Morphism<...>{
          source, modified_target, derivative(impl.f) + derivative(impl.g)};

  // case '*'
  (derivative(impl.f) * impl.g) + impl.f *derivative(impl.g)
}
} // namespace mathpp

*/
// template <class Morph1, class Morph2,
//           class = std::enable_if_t<in_category<Morph1, Diff>() &&
//                                    in_same_hom_set<Morph1, Morph2>()>>
// auto operator+(const Morph1 morph1, const Morph2 morph2) {

//   auto source = morph1.source;
//   auto target = morph1.target;

//   return Diff::Morphism{source, target,
//                        [morph1, morph2](auto &&x) -> decltype(auto) {
//                          return morph1(x) + morph2(x);
//                        }};
// }

} // namespace mathpp
