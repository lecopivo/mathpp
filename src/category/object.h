#pragma once

template <class Impl>
// Check if `Impl` cprovide `identity_morphism`
// Check if `Impl` cprovide `Category`
struct Object {
  // static constexpr auto identity_morphism() { Impl::identity_morphism(); }
};

template <class Impl>
// Check if `Impl` provide `is_element`
struct SetObject : public Object<SetObject<Impl>> {

  template <class Element>
  static constexpr bool is_element<Element> = Impl::is_element<Element>;

  // template <class Element> static constexpr bool is_element(Element const &)
  // {
  //   return is_element<Element>;
  // }
};

template <class Impl>
// Check if `Impl` can be `SetObject`
// Check if `Impl` provide `scalar_type`
// Check if `Impl` provide `zero()`
struct VecObject : public Object<VecObject<Impl>> {

  template <class Element>
  static constexpr bool is_element<Element> = Impl::is_element<Element>;

  using scalar_type = typename Impl::scalar_type;

  static constexpr auto zero() { return Impl::zero(); }
};

// template <class SrcObj, class TrgObj, class Impl>
// struct HomObject : public SetObject<HomObject<SrcObj, TrgObj, Impl>> {

//   using SourceObject = SrcObj;
//   using TargetObject = TrgObj;
// };

///////////////////////////
//////// Morphism /////////

template <class SrcObj, class TrgObj, class Impl>
// Check if `Impl` provide `Source`
// Check if `Impl` provide `Target`
struct Morphism {

  using Source = typename Impl::Source;
  using Target = typename Impl::Target;

  // template<class Morph>
  // // Check if the morphism
  // auto compose(Morph && morph)
  //   return compose(morph)
};

template <class SrcObj, class TrgObj, class Impl>
// Check that SrcObj and TrgObj are in SetCategory
struct SetMorphism
    : Morphism<SrcObj, TrgObj, SetMorphism<SrcObj, TrgObj, Impl>> {

  template <class T, class = std::enable_if_t<SrcObj::is_element<T>>>
  auto operator(T &&x) {

    // Check if `Impl` is actually collable with T
    static_assert(std::is_invocable_v<Impl, T>, "Invalid morphism: Function "
                                                "does not accepts elements of "
                                                "the specified source set!");
    // The result of Impl(T) has to be element of TrgObj
    static_assert(TrgObj::is_element<std::is_invoke_result_t<Impl, T>>,
                  "Invalid morphism: Returned element does not belong to the "
                  "specified target set!");

    return static_cast<Impl *>(this)->operator()(std::forward<T>(x));
  }
};

template <class SrcObj, class TrgObj, class Impl>
struct VecMorphism
    : Morphism<SrcObj, TrgObj, VecMorphism<SrcObj, TrgObj, Impl>> {};

// template <class SrcObj, class TrgObj, class Impl>
// // Check existence of Impl::derivitive()
// // Check if the result of Tmpl::derivative() is DiffMorphism<SrcObj,
// // VecMorphism<SrcObj, TrgObj> Check that SrcObj and TrgObj are VecSpcObjects
// struct DiffMorphism
//     : SetMorphism<SrcObj, TrgObj, DiffMorphism<SrcObj, TrgObj, Impl>> {

//   auto derivative() { return static_cast<Impl *>(this)->derivative(); }
// };

/////////////////////////////
//////// Categories /////////

struct Universe : SetObject<Universe> {};

struct SetCategory : SetObject<SetCategory> {};
