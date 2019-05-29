import std.stdio;
import std.algorithm;
import std.range;
import std.traits;
import std.math;
import std.format;

struct IdentityMap
{
  auto opCall(X)(X x)
  {
    return x;
  }
}

//   ___      _
//  / __|__ _| |_
// | (__/ _` |  _|
//  \___\__,_|\__|

struct Cat
{

  static bool is_object(Obj)()
  {
    return is(Obj : Object!(Arg), Arg); //std.traits.isInstanceOf!(Object, Obj);
  }

  static bool is_object(Obj)(ref const Obj obj)
  {
    return is_object!(Obj);
  }

  static bool is_morphism(Morph)()
  {
    return is(Morph : Morphism!(Args), Args...);
  }

  static bool is_morphism(Morph)(ref const Morph morph)
  {
    return is_morphism!(Morph);
  }

  struct Object(Impl)
  {

    this(Impl _impl)
    {
      impl = _impl;
    }

    alias Category = Cat;

    Impl impl;
  }

  struct Morphism(Src, Trg, Impl)
  {

    alias Category = Cat;
    alias Source = Src;
    alias Target = Trg;

    this(Src _src, Trg _trg, Impl _impl)
    {
      source = _src;
      target = _trg;
      impl = _impl;
    }

    Source source;
    Target target;
    Impl impl;
  }
}

//  ___      _
// / __| ___| |_
// \__ \/ -_)  _|
// |___/\___|\__|

struct Set
{

  static bool is_object(Obj)()
  {
    return is(Obj : Object!(Arg), Arg);
  }

  bool is_object(Obj)(ref const Obj obj)
  {
    return is_object!(Obj);
  }

  static bool is_morphism(Morph)()
  {
    return is(Morph : Morphism!(Args), Args...);
  }

  bool is_morphism(Morph)(ref const Morph morph)
  {
    return is_morphism!(Morph);
  }

  struct Object(Impl)
  {

    this(Impl _impl)
    {
      impl = _impl;
    }

    static bool is_element(Elem)()
    {
      return Impl.is_element!(Elem);
    }

    bool is_element(Elem)(ref const Elem elem)
    {
      return impl.is_element(elem);
    }

    alias Category = Cat;

    Impl impl;
  }

  struct MorphismOp(string op, MorphF, MorphG)
      if (op == "|" && is_morphism!(MorphF) && is_morphism!(MorphG))
  {

    this(MorphF _f, MorphG _g)
    {
      f = _f;
      g = _g;
    }

    auto opCall(T)(T x)
    {
      return f(g(x));
    }

    MorphF f;
    MorphG g;
  }

  struct Morphism(Src, Trg, Impl) if (is_object!(Src) && is_object!(Trg))
  {

    alias Category = Cat;
    alias Source = Src;
    alias Target = Trg;

    this(Src _src, Trg _trg, Impl _impl)
    {
      source = _src;
      target = _trg;
      impl = _impl;
    }

    auto opCall(T)(T x) if (Source.is_element!(T)())
    in
    {
      assert(source.is_element(x),
          std.format.format!"Input `%s : %s` is not an element of the Source object: `%s : %s`!"(x,
            std.traits.fullyQualifiedName!(typeof(x)),
            std.traits.fullyQualifiedName!(typeof(source)), source));
    }
    out (r)
    {
      assert(target.is_element(r), std.format.format!"Output `%s : %s` is not an element of the Target object!"(r,
          std.traits.fullyQualifiedName!(typeof(r)),
          std.traits.fullyQualifiedName!(typeof(target)), target));
    }
    do
    {
      return impl(x);
    }

    auto opBinary(string op, Src2, Trg2, Impl2)(Morphism!(Src2, Trg2, Impl2) morph)
        if (op == "|" && is(Trg2 == Source))
    {
      return make_morphism(morph.source, this.target, MorphismOp!("|",
          typeof(this), typeof(morph))(this, morph));
    }

    Source source;
    Target target;
    Impl impl;
  }

  static auto make_morphism(Src, Trg, Impl)(Src src, Trg trg, Impl impl)
      if (is_object!(Src) && is_object!(Trg))
  {
    return Morphism!(Src, Trg, Impl)(src, trg, impl);
  }

}

// __   __
// \ \ / /__ __
//  \ V / -_) _|
//   \_/\___\__|

struct Vec
{

  static bool is_object(Obj)()
  {
    return is(Obj : Object!(Impl), Impl);
  }

  static bool is_object(Obj)(ref const Obj obj)
  {
    return is_object!(Obj);
  }

  static bool is_morphism(Morph)()
  {
    return std.traits.isInstanceOf!(Morphism, Morph);
  }

  static bool is_morphism(Morph)(ref const Morph morph)
  {
    return is_morphism!(Morph);
  }

  struct Object(Impl)
  {

    this(Impl _impl)
    {
      impl = _impl;
    }

    static bool is_element(Elem)()
    {
      return Impl.is_element!(Elem);
    }

    bool is_element(Elem)(ref const Elem elem) const
    {
      return impl.is_element(elem);
    }

    auto zero() const
    {
      return impl.zero();
    }

    string symbol() const
    {
      return impl.symbol();
    }

    string toString() const
    {
      return symbol();
    }

    alias Category = Vec;
    alias Scalar = Impl.Scalar;

    Impl impl;
  }

  struct Sum
  {

    struct SumImpl(ObjX, ObjY)
    {

      static bool is_element(Elem)()
      {
        return is(Elem : SumElement!(X, Y), X, Y);
      }

      bool is_element(Elem)(Elem elem)
      {
        return is_element!(Elem);
      }

      auto zero() const
      {
        return make_sum_elem(objx.zero(), objy.zero());
      }

      string symbol() const
      {
        return objx.symbol() ~ "⊕" ~ objy.symbol();
      }

      string toString() const
      {
        return symbol();
      }
      
      auto projection(int I)(){
	auto source = map(objx, objy);
	
	struct ProjectionImpl(ObjX, ObjY){
	  auto opCall(X)(X x)
	  /* check if it is really sum element */
	  {
	    static if(I==0)
	      return x.x;
	    else
	      return x.y;
	  }
	}
	
	static if(I==0){
	  auto target = objx;
	}else{
	  auto target = objy;
	}
	
	return ProjectionImpl!(ObjX, ObjY);
      }

      alias Category = Vec;
      alias ObjectX = ObjX;
      alias OBjectY = ObjY;

      ObjectX objx;
      ObjectY objy;
    }

    struct SumElement(Scalar, X, Y)
    {

      auto opBinary(string op, RX, RY)(SumElement!(RX, RY) rhs) const 
          if (op == "+" || op == "-")
      {
        mixing("return make_sum_element!(Scalar)(x" ~ op ~ "rhs.x, y" ~ op ~ "rhs.y);");
      }

      auto opBinary(string op, RX, RY)(SumElement!(RX, RY) rhs) const 
          if (op == "+" || op == "-")
      {
        mixing("return make_sum_element!(Scalar)(x" ~ op ~ "rhs.x, y" ~ op ~ "rhs.y);");
      }

      X x;
      Y y;
    }

    auto make_sum_element(Scalar, X, Y)(X x, Y y)
    {
      return SumElement!(Scalar, X, Y)(x, y);
    }

    auto map(ObjX, ObjY)(ObjX objx, ObjY objy)
    {
      return Object!(SumImpl!(ObjX, ObjY))(SumImpl!(ObjX, ObjY)(objx, objy));
    }
    
    auto fmap(MorphF, MorphG)(MorphF f, MorphG g){
      auto source = map(f.source, g.source);
      auto target = map(f.target, g.target);
      
      
    }
  }

  static auto Identity(Obj)(Obj obj) if (is_object!(Obj))
  {
    IdentityMap id;
    return make_morphism(obj, obj, add_symbol!("𝑰")(id));
  }

  struct HomSetImpl(Src, Trg)
  {

    alias Source = Src;
    alias Target = Trg;
    alias Scalar = Src.Scalar;

    this(Src src, Trg trg)
    {
      source = src;
      target = trg;
    }

    auto zero() const
    {
      struct ZeroMorphismImpl(Trg)
      {

        this(Trg trg)
        {
          target = trg;
        }

        auto opCall(X)(X x)
        {
          return target.zero();
        }

        string symbol() const
        {
          return "0";
        }

        Trg target;
      }

      auto impl = ZeroMorphismImpl!(Target)(target);

      return make_morphism!(Source, Target, typeof(impl))(source, target, impl);
    }

    static bool is_element(Elem)()
    {
      // Elements of HomSet are morhisms in this category
      static if (!is_morphism!(Elem))
      {
        return false;
      }
      else
      {
        return is(Source == Elem.Source) && is(Target == Elem.Target);
      }
    }

    bool is_element(Elem)(ref const Elem elem) const
    {
      static if (!is_element!(Elem))
      {
        return false;
      }
      else
      {
        return (source == elem.source) && (target == elem.target);
      }
    }

    string symbol() const
    {
      return "Hom(" ~ source.symbol() ~ "," ~ target.symbol() ~ ")";
    }

    Source source;
    Target target;
  }

  static auto HomSet(Src, Trg)(Src src, Trg trg)
      if (is_object!(Src) && is_object!(Trg))
  {
    auto impl = HomSetImpl!(Src, Trg)(src, trg);
    return Object!(typeof(impl))(impl);
  }

  static bool is_homset(Obj)()
  {
    return is(Obj : Object!(HomSetImpl!(Src, Trg)), Src, Trg);
  }

  struct MorphismOp(string op, MorphF, MorphG)
      if (is_morphism!(MorphF) && is_morphism!(MorphG) && ((op == "|"
        && is(MorphF.Source == MorphG.Target)) || (op == "+"
        && is(MorphF.Source == MorphG.Source) && is(MorphF.Target == MorphG.Target))))
  {

    this(MorphF _f, MorphG _g)
    {
      f = _f;
      g = _g;
    }

    auto opCall(T)(T x)
    {
      static if (op == "|")
      {
        return f(g(x));
      }
      else
      {
        return f(x) + g(x);
      }
    }

    string symbol() const
    {
      static if (op == "|")
      {
        return "(" ~ f.symbol() ~ "⚬" ~ g.symbol() ~ ")";
      }
      else
      {
        return "(" ~ f.symbol() ~ op ~ g.symbol() ~ ")";
      }
    }

    MorphF f;
    MorphG g;
  }

  struct Morphism(Src, Trg, Impl) if (is_object!(Src) && is_object!(Trg))
  {

    alias Category = Cat;
    alias Source = Src;
    alias Target = Trg;

    this(Src _src, Trg _trg, Impl _impl)
    {
      source = _src;
      target = _trg;
      impl = _impl;
    }

    auto opCall(T)(T x) if (Source.is_element!(T)())
    in
    {
      assert(source.is_element(x),
          std.format.format!"Input `%s : %s` is not an element of the Source object: `%s : %s`!"(x,
            std.traits.fullyQualifiedName!(typeof(x)),
            std.traits.fullyQualifiedName!(typeof(source)), source));
    }
    out (r)
    {
      assert(target.is_element(r),
          std.format.format!"Output `%s : %s` is not an element of the Target object: `%s : %s`!"(r,
            std.traits.fullyQualifiedName!(typeof(r)),
            std.traits.fullyQualifiedName!(typeof(target)), target));
    }
    do
    {
      return impl(x);
    }

    auto opBinary(string op, Morph)(Morph morph)
        if (is_morphism!(Morph) && (op == "|" || op == "+"))
    {
      return make_morphism(morph.source, this.target, MorphismOp!(op,
          typeof(this), typeof(morph))(this, morph));
    }

    string symbol() const
    {
      return impl.symbol();
    }

    string toString() const
    {
      return impl.symbol() ~ " : " ~ source.symbol() ~ " ⟶ " ~ target.symbol();
    }

    Source source;
    Target target;
    Impl impl;
  }

  static auto make_morphism(Src, Trg, Impl)(Src src, Trg trg, Impl impl)
      if (is_object!(Src) && is_object!(Trg))
  {
    return Morphism!(Src, Trg, Impl)(src, trg, impl);
  }

}

struct WithSymbol(string s, T)
{

  this(T _t)
  {
    t = _t;
  }

  alias t this;

  static string symbol()
  {
    return s;
  }

  T t;
}

auto add_symbol(string s, T)(T t)
{
  return WithSymbol!(s, T)(t);
}

struct Diff
{

  static bool is_object(Obj)()
  {
    return is(Obj : Object!(Vec.Object!(Impl)), Impl);
  }

  static bool is_object(Obj)(ref const Obj obj)
  {
    return is_object!(Obj);
  }

  static bool is_morphism(Morph)()
  {
    return is(Morph : Morphism!(Args), Args...);
  }

  static bool is_morphism(Morph)(ref const Morph morph)
  {
    return is_morphism!(Morph);
  }

  struct Object(Impl) if (is(Impl : Vec.Object!(Impl2), Impl2))
  {

    this(Impl _impl)
    {
      impl = _impl;
    }

    static bool is_element(Elem)()
    {
      return Impl.is_element!(Elem);
    }

    bool is_element(Elem)(ref const Elem elem) const
    {
      return impl.is_element(elem);
    }

    auto zero() const
    {
      return impl.zero();
    }

    string symbol() const
    {
      return impl.symbol();
    }

    string toString() const
    {
      return symbol();
    }

    alias Category = Diff;
    alias Scalar = Impl.Scalar;

    Impl impl;
  }

  static auto Identity(Obj)(Obj obj) if (is_object!(Obj))
  {
    IdentityMap id;
    return make_morphism(obj, obj, add_symbol!("𝑰")(id));
  }

  struct HomSetImpl(Src, Trg)
  {

    alias Source = Src;
    alias Target = Trg;
    alias Scalar = Trg.Scalar;

    this(Src src, Trg trg)
    {
      source = src;
      target = trg;
    }

    auto zero() const
    {
      struct ZeroMorphismImpl(Trg)
      {

        this(Trg trg)
        {
          target = trg;
        }

        auto opCall(X)(X x)
        {
          return target.zero();
        }

        string symbol() const
        {
          return "0";
        }

        Trg target;
      }

      auto impl = ZeroMorphismImpl!(Target)(target);

      return make_morphism!(Source, Target, typeof(impl))(source, target, impl);
    }

    static bool is_element(Elem)()
    {
      // Elements of HomSet are morhisms in this category
      static if (!is_morphism!(Elem))
      {
        return false;
      }
      else
      {
        return is(Source == Elem.Source) && is(Target == Elem.Target);
      }
    }

    bool is_element(Elem)(ref const Elem elem) const
    {
      static if (!is_element!(Elem))
      {
        return false;
      }
      else
      {
        return (source == elem.source) && (target == elem.target);
      }
    }

    string symbol() const
    {
      return "Hom(" ~ source.symbol() ~ "," ~ target.symbol() ~ ")";
    }

    Source source;
    Target target;
  }

  static auto HomSet(Src, Trg)(Src src, Trg trg)
      if (is_object!(Src) && is_object!(Trg))
  {
    auto impl = HomSetImpl!(Src, Trg)(src, trg);
    return Object!(typeof(impl))(impl);
  }

  static bool is_homset(Obj)()
  {
    return is(Obj : Object!(HomSetImpl!(Src, Trg)), Src, Trg);
  }

  struct MorphismOp(string op, MorphF, MorphG)
      if (is_morphism!(MorphF) && is_morphism!(MorphG) && ((op == "|"
        && is(MorphF.Source == MorphG.Target)) || (op == "+"
        && is(MorphF.Source == MorphG.Source) && is(MorphF.Target == MorphG.Target)) || (op == "*"
        && is(MorphF.Source == MorphG.Source) && Vec.is_homset!(MorphF.Target)
        && Vec.is_homset!(MorphG.Target) && is(MorphF.Target.Source == MorphG.Target.Target))))
  {

    this(MorphF _f, MorphG _g)
    {
      f = _f;
      g = _g;
    }

    auto opCall(T)(T x)
    {
      static if (op == "|")
      {
        return f(g(x));
      }
      else static if (op == "+")
      {
        return f(x) + g(x);
      }
      else
      { /* op == "*" */
        // We assume that:
        // f : X --> Vec.HomSet(V,W)
        // g : X --> Vec.HomSet(U,V)
        // then
        // f*g : X --> Vec.HomSet(U,W)

        return f(x) | g(x);

        //return f(x).composeAtArg!(0)(g(x));
      }
    }

    auto derivative() const
    {
      static if (op == "|")
      {
        return (f.derivative() | g) * g.derivative();
      }
      else static if (op == "+")
      {
        return f.derivative() + g.derivative();
      }
      else
      { /* op == "*" */
        return (f.derivative() * make_const_over(f.source, g)) + (make_const_over(g.source,
            f) * g.derivative());
      }
    }

    string symbol() const
    {
      static if (op == "|")
      {
        return "(" ~ f.symbol() ~ "⚬" ~ g.symbol() ~ ")";
      }
      else
      {
        return "(" ~ f.symbol() ~ op ~ g.symbol() ~ ")";
      }
    }

    MorphF f;
    MorphG g;
  }

  struct Morphism(Src, Trg, Impl) if (is_object!(Src) && is_object!(Trg))
  {

    alias Category = Cat;
    alias Source = Src;
    alias Target = Trg;

    this(Src _src, Trg _trg, Impl _impl)
    {
      source = _src;
      target = _trg;
      impl = _impl;
    }

    auto opCall(T)(T x) if (Source.is_element!(T)())
    in
    {
      assert(source.is_element(x),
          std.format.format!"Input `%s : %s` is not an element of the Source object: `%s : %s`!"(x,
            std.traits.fullyQualifiedName!(typeof(x)),
            std.traits.fullyQualifiedName!(typeof(source)), source));
    }
    out (r)
    {
      assert(target.is_element(r),
          std.format.format!"Output `%s : %s` is not an element of the Target object: `%s : %s`!"(r,
            std.traits.fullyQualifiedName!(typeof(r)),
            std.traits.fullyQualifiedName!(typeof(target)), target));
    }
    do
    {
      return impl(x);
    }

    auto opBinary(string op, Morph)(Morph morph)
        if (is_morphism!(Morph) && (op == "|" || op == "+"))
    {
      return make_morphism(morph.source, this.target, MorphismOp!(op,
          typeof(this), typeof(morph))(this, morph));
    }

    string symbol() const
    {
      return impl.symbol();
    }

    string toString() const
    {
      return impl.symbol() ~ " : " ~ source.symbol() ~ " ⟶ " ~ target.symbol();
    }

    Source source;
    Target target;
    Impl impl;
  }

  static auto make_morphism(Src, Trg, Impl)(Src src, Trg trg, Impl impl)
      if (is_object!(Src) && is_object!(Trg))
  {
    return Morphism!(Src, Trg, Impl)(src, trg, impl);
  }

}

// struct Diff{

//   static bool is_object(Obj)(){
//     return std.traits.isInstanceOf!(Object, Obj);
//   }

//   static bool is_object(Obj)(ref const Obj obj){
//     return is_object!(Obj);
//   }

//   static bool is_morphism(Morph)(){
//     return std.traits.isInstanceOf!(Morphism, Morph);
//   }

//   static bool is_morphism(Morph)(ref const Morph morph){
//     return is_morphism!(Morph);
//   }

//   struct Object(Impl){

//     this(Impl _impl){
//       impl = _impl;
//     }

//     static bool is_element(Elem)(){
//       return Impl.is_element!(Elem);
//     }

//     bool is_element(Elem)(ref const Elem elem){
//       return impl.is_element(elem);
//     }

//     alias Category = Cat;
//     //aliar Scalar = Impl.Scalar;

//     Impl impl;
//   };

//   struct MorphismOp(string op, MorphF, MorphG)
//     if(is_morphism!(MorphF) && is_morphism!(MorphG) &&
//        ((op=="|" && is(MorphF.Source==MorphG.Target)) ||
// 	(op=="+" && is(MorphF.Source==MorphG.Source) && is(MorphF.Target==MorphG.Target))))
//       {

// 	this (MorphF _f, MorphG _g){
// 	  f = _f;
// 	  g = _g;
// 	}

// 	auto opCall(T)(T x){
// 	  static if(op=="|"){
// 	    return f(g(x));
// 	  }else{
// 	    return f(x) + g(x);
// 	  }
// 	}

// 	MorphF f;
// 	MorphG g;
//   };

//   struct Morphism(Src, Trg, Impl)
//     if(is_object!(Src) && is_object!(Trg))
//       {

// 	alias Category = Cat;
// 	alias Source = Src;
// 	alias Target = Trg;

// 	this(Src _src, Trg _trg, Impl _impl){
// 	  source = _src;
// 	  target = _trg;
// 	  impl   = _impl;
// 	}

// 	auto opCall(T)(T x) if (Source.is_element!(T)())
// 	  in(source.is_element(x), std.format.format!"Input `%s : %s` is not an element of the Source object: `%s : %s`!"(x,
// 															  std.traits.fullyQualifiedName!(typeof(x)),
// 															  std.traits.fullyQualifiedName!(typeof(source)), source))
// 	      out(r; target.is_element(r), std.format.format!"Output `%s : %s` is not an element of the Target object!"(r,
// 															std.traits.fullyQualifiedName!(typeof(r))))
// 		   {
// 		     return impl(x);
// 		   }

// 	auto opBinary(string op, Morph)(Morph morph)
// 	  if(is_morphism!(Morph) &&
// 	     (op == "|" || op == "+"))
// 	    {
// 	      return make_morphism(morph.source, this.target, MorphismOp!(op, typeof(this), typeof(morph))(this, morph));
// 	    }

// 	Source source;
// 	Target target;
// 	Impl impl;
//   };

//   static auto make_morphism(Src, Trg, Impl)(Src src, Trg trg, Impl impl)
//     if(is_object!(Src) && is_object!(Trg)){
//       return Morphism!(Src, Trg, Impl)(src, trg, impl);
//     }
// };

struct Matrix(Real, int N, int M)
{

  this(Real[N * M] vals)
  {
    data = vals;
  }

  static Matrix!(Real, N, M) constant(Real c)
  {
    Matrix!(Real, N, M) result;
    for (int j = 0; j < M; j++)
    {
      for (int i = 0; i < N; i++)
      {
        result[i, j] = c;
      }
    }
    return result;
  }

  ref Real opIndex(int i, int j)
  in
  {
    assert(i >= 0 && i < N && j >= 0 && j < M, "Index out of range!");
  }
  do
  {
    return data[i + N * j];
  }

  Real opIndex(int i, int j) const
  in
  {
    assert(i >= 0 && i < N && j >= 0 && j < M, "Index out of range!");
  }
  do
  {
    return data[i + N * j];
  }

  void opOpAssign(string op)(Matrix!(Real, N, M) rhs) if (op == "+" || op == "-")
  {
    for (int j = 0; j < M; j++)
    {
      for (int i = 0; i < N; i++)
      {
        mixin("this[i,j] " ~ op ~ "= rhs[i,j];");
      }
    }
  }

  void opOpAssign(string op : "*")(Real scalar)
  {
    for (int j = 0; j < M; j++)
    {
      for (int i = 0; i < N; i++)
      {
        this[i, j] *= scalar;
      }
    }
  }

  Matrix!(Real, N, M) opBinary(string op)(Matrix!(Real, N, M) rhs) const 
      if (op == "+" || op == "-")
  {
    Matrix!(Real, N, M) result = this;
    mixin("result " ~ op ~ "= rhs;");
    return result;
  }

  Matrix!(Real, N, L) opBinary(string op, int L)(Matrix!(Real, M, L) rhs)
      if (op == "*")
  {
    Matrix!(Real, N, L) result;
    for (int j = 0; j < L; j++)
    {
      for (int i = 0; i < N; i++)
      {
        result[i, j] = 0;
        for (int k = 0; k < M; k++)
        {
          result[i, j] += this[i, k] * rhs[k, j];
        }
      }
    }
    return result;
  }

  Matrix!(Real, N, M) opBinary(string op)(Real scalar) if (op == "*")
  {
    auto result = this;
    result *= scalar;
    return result;
  }

  Matrix!(Real, N, M) opBinaryRight(string op)(Real scalar) if (op == "*")
  {
    auto result = this;
    result *= scalar;
    return result;
  }

  string toString()
  {
    // Typical implementation to minimize overhead
    // of constructing string
    auto app = appender!string();
    for (int i = 0; i < N; i++)
    {
      for (int j = 0; j < M; j++)
      {
        import std.conv;

        app.put(to!string(this[i, j]));
        if (j < M - 1)
          app.put(" ");
      }
      if (i < N - 1)
        app.put(" \n");
    }
    return app.data;
  }

  Real[N * M] data;
}

struct B
{

}

struct A
{
}

struct TypeObjectImpl(T)
{

  static bool is_element(Elem)()
  {
    return is(T == Elem);
  }

  bool is_element(Elem)(ref const Elem elem)
  {
    return is_element!(Elem);
  }
}

auto TypeObject(T)()
{
  auto impl = TypeObjectImpl!(T)();
  return Set.Object!(typeof(impl))(impl);
}

struct VectorSpaceImpl(Real, int N, int M)
{

  alias Scalar = Real;

  static bool is_element(Elem)()
  {
    return is(Elem : Matrix!(Real, N, M));
  }

  static bool is_element(Elem)(ref const Elem elem)
  {
    return is_element!(Elem);
  }

  static Matrix!(Real, N, M) zero()
  {
    return Matrix!(Real, N, M).constant(0.0);
  }

  string symbol() const
  {
    import std.conv;

    return "ℝ(" ~ to!string(N) ~ "," ~ to!string(M) ~ ")";
  }
}

auto VectorSpace(Real, int N, int M)()
{
  auto impl = VectorSpaceImpl!(Real, N, M)();
  return Vec.Object!(typeof(impl))(impl);
}

void print_types(Ts...)(Ts ts)
{
  foreach (t; ts)
    writeln(t);
}

void main()
{
  // Let's get going!
  writeln("Hello World!");

  auto mat = Matrix!(double, 2, 2)([0., 1., 2., 3.]);
  auto vec = Matrix!(double, 6, 1)([0., 1., 2., 3., 4., 5.]);

  writeln(mat, "\n");
  writeln(0.1 * mat, "\n");
  writeln(mat * 0.01, "\n");
  writeln(mat + mat, "\n");
  writeln(mat * mat, "\n");

  writeln(vec, "\n");
  writeln(0.1 * vec, "\n");
  writeln(vec * 0.01, "\n");
  writeln(vec + vec, "\n");

  Cat.Object!(A) a;
  Cat.Object!(B) b;

  alias ObjA = Cat.Object!(A);
  alias ObjB = Cat.Object!(B);

  auto reals = TypeObject!(double)();
  alias Reals = typeof(reals);

  auto fun = delegate(double x) => std.math.sqrt(x);

  print_types(reals, reals, fun);

  auto morph = Set.make_morphism(reals, reals, fun);

  writefln("Type of morphism: %s", std.traits.fullyQualifiedName!(typeof(morph)));

  auto morph2 = morph | morph;

  auto sqrt2 = morph(2.0);

  writefln("Sqrt(2) = %s\nSqrt(Sqrt(2)) = %s", morph(2.0), morph2(2.0));

  writefln("Type of morph | morph is: %s", std.traits.fullyQualifiedName!(typeof(morph2)));

  writefln("Object A is of type: %s", std.traits.fullyQualifiedName!(float));
  writefln("%s is an object: %s", std.traits.fullyQualifiedName!(ObjB), Cat.is_object!(ObjB));
  writefln("%s is an object: %s", std.traits.fullyQualifiedName!(double),
      Cat.is_object!(double));
  writefln("%s is an object: %s", std.traits.fullyQualifiedName!(Reals), Set.is_object!(Reals));

  auto R2 = VectorSpace!(double, 2, 1);
  auto foo = add_symbol!("𝑓")(delegate(ref const Matrix!(double, 2, 1) x) => mat * x);
  auto m = Vec.make_morphism(R2, R2, foo);
  auto homset = Vec.HomSet(R2, R2);
  auto id = Vec.Identity(R2);

  auto e0 = Matrix!(double, 2, 1)([1, 0]);
  auto e1 = Matrix!(double, 2, 1)([0, 1]);

  auto u = m(e0);
  auto v = m + m;

  auto u1 = m(e1);
  auto u2 = m(e1);
  auto u3 = m(e0) + m(e0);

  writeln(u, "\n");
  writeln(u + u, "\n");
  writeln(m(e1) + m(e1), "\n");
  writeln(foo, "\n");
  writeln(std.traits.fullyQualifiedName!(typeof(m + m)), "\n");
  writeln(std.traits.fullyQualifiedName!(typeof(m | m)), "\n");
  writeln((id | (m | (m + m)))(e1), "\n");
  writeln((id + (m | (m + m)))(e1), "\n");

  auto bar = (id | (m | (m + m)));
  auto z = homset.zero();

  writeln(((z | z) + id + m + (id | z))(e0));
  writeln(((z | z) + id + m + (id | z)));
  //writeln(z.symbol());

  writeln((id | (m | (m + m))).symbol(), "\n");
  writeln(homset, "\n");
  writeln((id | (m | (m + m))), "\n");

  writeln(bar, "\n");
  writeln(std.traits.fullyQualifiedName!(typeof(bar)), "\n");

  writeln("f⚬g: V → W");
  writeln("𝑓⚬𝑔: Vᵢ ⟶ Wᵢ");
}
