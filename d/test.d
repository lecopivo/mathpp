import std.stdio;
import std.algorithm;
import std.range;
import std.traits;
import std.math;
import std.format;

//   ___      _
//  / __|__ _| |_
// | (__/ _` |  _|
//  \___\__,_|\__|

struct Cat{

  static bool is_object(Obj)(){
    return is(Obj : Object!(Arg), Arg);//std.traits.isInstanceOf!(Object, Obj);
  }

  static bool is_object(Obj)(ref const Obj obj){
    return is_object!(Obj);
  }

  static bool is_morphism(Morph)(){
    return is(Morph : Morphism!(Args), Args...);
  }

  static bool is_morphism(Morph)(ref const Morph morph){
    return is_morphism!(Morph);
  }
  
  struct Object(Impl){
    
    this(Impl _impl){
      impl = _impl;
    }

    alias Category = Cat;

    Impl impl;
  };

  struct Morphism(Src, Trg, Impl){

    alias Category = Cat;
    alias Source = Src;
    alias Target = Trg;

    this(Src _src, Trg _trg, Impl _impl){
      source = _src;
      target = _trg;
      impl   = _impl;
    }

    Source source;
    Target target;
    Impl impl;
  };
};

//  ___      _
// / __| ___| |_
// \__ \/ -_)  _|
// |___/\___|\__|

struct Set{

  static bool is_object(Obj)(){
    return is(Obj : Object!(Arg), Arg);
  }
  
  bool is_object(Obj)(ref const Obj obj){
    return is_object!(Obj);
  }
  
  static bool is_morphism(Morph)(){
    return is(Morph : Morphism!(Args), Args...);
  }
  
  bool is_morphism(Morph)(ref const Morph morph){
    return is_morphism!(Morph);
  }
  
  struct Object(Impl){
    
    this(Impl _impl){
      impl = _impl;
    }

    static bool is_element(Elem)(){
      return Impl.is_element!(Elem);
    }

    bool is_element(Elem)(ref const Elem elem){
      return impl.is_element(elem);
    }

    alias Category = Cat;

    Impl impl;
  };

  struct MorphismOp(string op, MorphF, MorphG)
    if(op=="|" && is_morphism!(MorphF) && is_morphism!(MorphG))
      {

	this (MorphF _f, MorphG _g){
	  f = _f;
	  g = _g;
	}

	auto opCall(T)(T x){
	  return f(g(x));
	}

	MorphF f;
	MorphG g;
  };

  struct Morphism(Src, Trg, Impl)
    if(is_object!(Src) && is_object!(Trg)){

    alias Category = Cat;
    alias Source = Src;
    alias Target = Trg;

    this(Src _src, Trg _trg, Impl _impl){
      source = _src;
      target = _trg;
      impl   = _impl;
    }

    auto opCall(T)(T x) if (Source.is_element!(T)())
      in(source.is_element(x), std.format.format!"Input `%s : %s` is not an element of the Source object: `%s : %s`!"(x,
														      std.traits.fullyQualifiedName!(typeof(x)),
														      std.traits.fullyQualifiedName!(typeof(source)), source))
	  out(r; target.is_element(r), std.format.format!"Output `%s : %s` is not an element of the Target object!"(r,
														    std.traits.fullyQualifiedName!(typeof(r))))
	       {
		 return impl(x);
	       }

    auto opBinary(string op, Src2, Trg2, Impl2)(Morphism!(Src2, Trg2, Impl2) morph)
      if(op == "|" && is(Trg2==Source))
	{
	  return make_morphism(morph.source, this.target, MorphismOp!("|", typeof(this), typeof(morph))(this, morph));
	}

    Source source;
    Target target;
    Impl impl;
  };

  static auto make_morphism(Src, Trg, Impl)(Src src, Trg trg, Impl impl)
    if(is_object!(Src) && is_object!(Trg)){
      return Morphism!(Src, Trg, Impl)(src, trg, impl);
    }

};


// __   __
// \ \ / /__ __
//  \ V / -_) _|
//   \_/\___\__|


struct Vec{

  static bool is_object(Obj)(){
    return is(Obj : Object!(Impl), Impl);
  }
  
  static bool is_object(Obj)(ref const Obj obj){
    return is_object!(Obj);
  }
  
  static bool is_morphism(Morph)(){
    return std.traits.isInstanceOf!(Morphism, Morph);
  }
  
  static bool is_morphism(Morph)(ref const Morph morph){
    return is_morphism!(Morph);
  }
  
  struct Object(Impl){
    
    this(Impl _impl){
      impl = _impl;
    }

    static bool is_element(Elem)(){
      return Impl.is_element!(Elem);
    }

    bool is_element(Elem)(ref const Elem elem){
      return impl.is_element(elem);
    }

    alias Category = Cat;
    alias Scalar = Impl.Scalar;
    
    Impl impl;
  };

  struct HomSetImpl(Src, Trg){

    alias Source = Src;
    alias Target = Trg;

    this(Src src, Trg trg){
      source = src;
      target = trg;
    }

    static is_element(Elem)(){
      // Elements of HomSet are morhisms in this category
      static if(!is_morphism!(Elem)){
	return false;
      }else{
	return is(Source==Elem.Source) && is(Target==Elem.Target);
      }
    }

    static is_element(Elem)(ref const Elem elem){
      static if(!is_element!(Elem)){
	return false;
      }else{
	return (source==elem.source) && (target==elem.target);
      }
    }

    Source source;
    Target target;
  };

  auto HomSet(Src, Trg)(Src src, Trg trg)
    if(is_object!(Src) && is_object!(Trg))
      {
	auto impl = HomSetImpl!(Src,Trg)(src, trg);
	return Object!(typeof(impl))(impl);
      }

  bool is_homset(Obj)(){
    return is(Obj : Object!(HomSetImpl!(Src,Trg)), Src, Trg);
  }

  struct MorphismOp(string op, MorphF, MorphG)
    if(is_morphism!(MorphF) && is_morphism!(MorphG) &&
       ((op=="|" && is(MorphF.Source==MorphG.Target)) ||
	(op=="+" && is(MorphF.Source==MorphG.Source) && is(MorphF.Target==MorphG.Target))
	(op=="*" && is(MorphF.Source==MorphG.Source) && is_homset!(MorphF.Target) && is_homset!(MorphG.Target) && is(MorphF.Target.Source==MmorphG.Target.Target))))
      {

	this (MorphF _f, MorphG _g){
	  f = _f;
	  g = _g;
	}

	auto opCall(T)(T x){
	  static if(op=="|"){
	    return f(g(x));
	  }else if(op=="+"){
	    return f(x) + g(x);
	  }else if(op=="*"){
	    return f(x) | g(x);
	  }
	}

	MorphF f;
	MorphG g;
  };

  struct Morphism(Src, Trg, Impl)
    if(is_object!(Src) && is_object!(Trg))
      {

	alias Category = Cat;
	alias Source = Src;
	alias Target = Trg;

	this(Src _src, Trg _trg, Impl _impl){
	  source = _src;
	  target = _trg;
	  impl   = _impl;
	}

	auto opCall(T)(T x) if (Source.is_element!(T)())
	  in(source.is_element(x), std.format.format!"Input `%s : %s` is not an element of the Source object: `%s : %s`!"(x,
															  std.traits.fullyQualifiedName!(typeof(x)),
															  std.traits.fullyQualifiedName!(typeof(source)), source))
	      out(r; target.is_element(r), std.format.format!"Output `%s : %s` is not an element of the Target object!"(r,
															std.traits.fullyQualifiedName!(typeof(r))))
		   {
		     return impl(x);
		   }

	auto opBinary(string op, Morph)(Morph morph)
	  if(is_morphism!(Morph) &&
	     (op == "|" || op == "+"))
	    {
	      return make_morphism(morph.source, this.target, MorphismOp!(op, typeof(this), typeof(morph))(this, morph));
	    }

	Source source;
	Target target;
	Impl impl;
  };

  static auto make_morphism(Src, Trg, Impl)(Src src, Trg trg, Impl impl)
    if(is_object!(Src) && is_object!(Trg)){
      return Morphism!(Src, Trg, Impl)(src, trg, impl);
    }

};


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

struct B{};
struct A{};

struct TypeObjectImpl(T){
  
  static bool is_element(Elem)(){
    return is(T == Elem);
  }
  
  bool is_element(Elem)(ref const Elem elem){
    return is_element!(Elem);
  }
};

auto TypeObject(T)(){
  auto impl = TypeObjectImpl!(T)();
  return Set.Object!(typeof(impl))(impl);
}

void print_types(Ts...)(Ts ts){
  foreach(t; ts)
    writeln(t);			
}

void main()
{
  // Let's get going!
  writeln("Hello World!");

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
  writefln("%s is an object: %s", std.traits.fullyQualifiedName!(Reals),
	   Set.is_object!(Reals));

}
