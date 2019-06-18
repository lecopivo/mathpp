import base;
import checks;
import hash;
import meta;

import std.array;
import std.algorithm;

// interface ISetMorphism : IExpression {

//   immutable(ISetObject) set() immutable;

//   immutable(ISetObject) source() immutable;
//   immutable(ISetObject) target() immutable;

//   immutable(ISetMorphism) opCall(immutable ISetMorphism elem) immutable;
// }

interface ISetObject : ISymbolic {

  bool is_element(immutable ISetMorphism elem) immutable;
}

interface ISetMorphism : IExpression {

  immutable(ISetObject) set() immutable;

  immutable(ISetObject) source() immutable;
  immutable(ISetObject) target() immutable;

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) immutable;
}

interface ICMorphism : ISetMorphism{
 
  immutable(ICMorphism) grad() immutable;
    
  int order() immutable; // The return value should be able to return infinity!
}

interface IPolMorphism : ICMorphism{
  
  final int order() immutable{
    return -1;
  }
  
  immutable(IPolMorphism) grad() immutable;
  
  int degree() immutable;
}

interface IVecMorphism : IPolMorphism{
 
  final int degree() immutable{
    return 1;
  }
  
  final immutable(IPolMorphism) grad() immutable{
    return constant(source(), this);
  }
}

//   ___                     _   _
//  / _ \ _ __  ___ _ _ __ _| |_(_)___ _ _  ___
// | (_) | '_ \/ -_) '_/ _` |  _| / _ \ ' \(_-<
//  \___/| .__/\___|_| \__,_|\__|_\___/_||_/__/
//       |_|

immutable(ISetMorphism) compose(Morph...)(Morph morph) {

  static assert(Morph.length != 0, "Compose cannot be called without an argument!");

  static if (Morph.length >= 2) {
    enum N = Morph.length;
    enum string mlist = "[" ~ "cast(immutable(ISetMorphism))(morph[J])".expand(N, ",", "J") ~ "]";

    return new immutable ComposedMorphism(mixin(mlist));
  }
  else static if (Morph.length == 1 && is(Morph[0] : M[], M)) {

    return new immutable ComposedMorphism(morph);

  }
  else {
    return morph[0];
  }

}

immutable(ISetObject) homset(immutable ISetObject src, immutable ISetObject trg) {
  return new immutable HomSet(src, trg);
}

immutable(ISetMorphism) product(Morph...)(Morph morph) {

  static assert(Morph.length != 0, "Product cannot be called without an argument!");

  static if (Morph.length >= 2) {
    enum N = Morph.length;
    enum string mlist = "[" ~ "cast(immutable(ISetMorphism))(morph[J])".expand(N, ",", "J") ~ "]";

    return new immutable ProductMorphism(mixin(mlist));
  }
  else static if (Morph.length == 1 && is(Morph[0] : M[], M)) {

    return new immutable ProductMorphism(morph);

  }
  else {
    return morph[0];
  }
}

immutable(ISetObject) prod(Obj...)(Obj obj) { //(immutable ISetObject objX, immutable ISetObject objY) {

  static if (Obj.length >= 2) {
    enum N = Obj.length;
    enum string olist = "[" ~ "cast(immutable(ISetObject))(obj[J])".expand(N, ",", "J") ~ "]";

    return new immutable ProductObject(mixin(olist));
  }
  else static if (Obj.length == 1 && is(Obj[0] : M[], M)) {

    return new immutable ProductObject(obj);
  }
  else {
    return obj[0];
  }
  //return new immutable ProductObject([objX, objY]);
}

immutable(ISetMorphism) eval(immutable ISetObject src, immutable ISetObject trg) {
  return new immutable Eval(src, trg);
}

immutable(ISetMorphism) projection(Obj...)(int I, Obj obj) {

  enum N = Obj.length;
  enum string olist = "[" ~ "cast(immutable(ISetObject))(obj[J])".expand(N, ",", "J") ~ "]";

  return new immutable Projection(I, mixin(olist));
}

immutable(ISetMorphism) identity(immutable ISetObject obj) {
  return new immutable Identity(obj);
}

immutable(ISetMorphism) constant(immutable ISetObject src, immutable ISetMorphism elem) {
  return new immutable ConstantMorphism(src, elem.set(), elem);
}

//  ___            _          ___      _
// | __|_ __  _ __| |_ _  _  / __| ___| |_
// | _|| '  \| '_ \  _| || | \__ \/ -_)  _|
// |___|_|_|_| .__/\__|\_, | |___/\___|\__|
//           |_|       |__/

// Empty set is also the initial object in category Set

immutable class EmptySet : ISetMorphism, ISetObject {

  this() {
  }

  immutable(ISetObject) set() {
    return terminalObject;
  }

  immutable(ISetObject) source() {
    return terminalObject;
  }

  immutable(ISetObject) target() {
    return terminalObject;
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) immutable {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");
    return this;
  }

  bool is_element(immutable ISetMorphism elem) {
    return false;
  }

  string symbol() {
    return "∅";
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash("EmptySet");
  }

  bool containsSymbol(immutable IExpression s) {
    return this.isEqual(s);
  }
}

static auto emptySet = new immutable EmptySet;

//  ___      _ _   _      _    ___  _     _        _
// |_ _|_ _ (_) |_(_)__ _| |  / _ \| |__ (_)___ __| |_
//  | || ' \| |  _| / _` | | | (_) | '_ \| / -_) _|  _|
// |___|_||_|_|\__|_\__,_|_|  \___/|_.__// \___\__|\__|
//                                     |__/

immutable class TerminalObject : ISetObject {

  this() {
  }

  bool is_element(immutable ISetMorphism elem) {
    return elem.isEqual(emptySet);
  }

  string symbol() {
    return "{∅}";
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash("TerminalObject");
  }
}

static auto terminalObject = new immutable TerminalObject;

//  ___ _                   _
// | __| |___ _ __  ___ _ _| |_
// | _|| / -_) '  \/ -_) ' \  _|
// |___|_\___|_|_|_\___|_||_\__|

immutable class Element : ISetMorphism {

  ISetObject object;
  string sym;

  this(string symbol, immutable ISetObject _object) {
    object = _object;
    sym = symbol;
  }

  immutable(ISetObject) set() {
    return object;
  }

  immutable(ISetObject) source() {
    return terminalObject;
  }

  immutable(ISetObject) target() {
    return set();
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) immutable {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");
    return this;
  }

  string symbol() {
    return sym;
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(sym, "Element");
  }

  bool containsSymbol(immutable IExpression s) {
    return this.isEqual(s);
  }
}

//  ___          _           _          _
// | __|_ ____ _| |_  _ __ _| |_ ___ __| |
// | _|\ V / _` | | || / _` |  _/ -_) _` |
// |___|\_/\__,_|_|\_,_\__,_|\__\___\__,_|

immutable class Evaluated : ISetMorphism {

  ISetMorphism morph;
  ISetMorphism element;

  this(immutable ISetMorphism _morph, immutable ISetMorphism _elem) {
    morph = _morph;
    element = _elem;
  }

  immutable(ISetObject) set() {
    if (morph.target().is_homset()) {
      auto homSet = cast(immutable HomSet)(morph.target());
      return homSet.target();
    }
    else {
      return morph.target();
    }
  }

  immutable(ISetObject) source() {
    if (morph.target().is_homset()) {
      auto homSet = cast(immutable HomSet)(morph.target());
      return homSet.source();
    }
    else {
      return terminalObject;
    }
  }

  immutable(ISetObject) target() {
    return set();
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) immutable {

    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");

    if (source().isEqual(terminalObject)) {
      return this;
    }
    else {
      return new immutable Evaluated(this, elem);
    }
  }

  string symbol() {
    return morph.symbol() ~ "(" ~ element.symbol() ~ ")";
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(morph, element, "Evaluated");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return morph.containsSymbol(s) || element.containsSymbol(s) || this.isEqual(s);
  }
}

//  ___             _         _   ___ _                   _
// | _ \_ _ ___  __| |_  _ __| |_| __| |___ _ __  ___ _ _| |_
// |  _/ '_/ _ \/ _` | || / _|  _| _|| / -_) '  \/ -_) ' \  _|
// |_| |_| \___/\__,_|\_,_\__|\__|___|_\___|_|_|_\___|_||_\__|

immutable class ProductElement : ISetMorphism {

  alias arg this;

  ISetMorphism[] arg;

  this(immutable ISetMorphism[] _arg) {
    arg = _arg;
  }

  immutable(ISetObject) set() {
    return new immutable ProductObject(map!(x => x.set())(arg).array);
  }

  immutable(ISetObject) source() {
    return terminalObject;
  }

  immutable(ISetObject) target() {
    return set();
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) immutable {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");
    return this;
  }

  string symbol() {
    import std.array;

    auto s = appender!string;
    s ~= "(";
    foreach (i, a; arg) {
      if (i != 0)
        s ~= ",";
      s ~= a.symbol();
    }
    s ~= ")";
    return s.data;
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(arg, "ProductElement");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    bool result = false;
    foreach (a; arg)
      result |= a.containsSymbol(s);
    return result || this.isEqual(s);
  }
}

//   ___  _     _        _
//  / _ \| |__ (_)___ __| |_
// | (_) | '_ \| / -_) _|  _|
//  \___/|_.__// \___\__|\__|
//           |__/

immutable class SetObject : ISetObject {

  string sym;

  this(string _sym) {
    sym = _sym;
  }

  bool is_element(immutable ISetMorphism elem) {
    return elem.set().isEqual(this);
  }

  string symbol() {
    return sym;
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(sym, "SetObject");
  }
}

// //  _____              _           _    ___  _     _        _
// // |_   _|__ _ _ _ __ (_)_ _  __ _| |  / _ \| |__ (_)___ __| |_
// //   | |/ -_) '_| '  \| | ' \/ _` | | | (_) | '_ \| / -_) _|  _|
// //   |_|\___|_| |_|_|_|_|_||_\__,_|_|  \___/|_.__// \___\__|\__|
// //                                              |__/

// immutable class TerminalObject : ISetObject{

//   this(){}

//   string symbol(){
//     return "{∅}";
//   }

//   string latex(){
//     return symbol();
//   }

//   ulong toHash(){
//     return computeHash("TerminalObject");
//   }
// }

//  ___             _         _      ___  _     _        _
// | _ \_ _ ___  __| |_  _ __| |_   / _ \| |__ (_)___ __| |_
// |  _/ '_/ _ \/ _` | || / _|  _| | (_) | '_ \| / -_) _|  _|
// |_| |_| \___/\__,_|\_,_\__|\__|  \___/|_.__// \___\__|\__|
//                                           |__/

immutable class ProductObject : ISetObject {

  ISetObject[] arg;

  this(immutable ISetObject[] _arg) {
    arg = _arg;
  }

  bool is_element(immutable ISetMorphism elem) {
    auto E = cast(immutable ProductElement)(elem);
    if (E) {
      bool result = true;
      foreach (i, e; E.arg)
        result &= arg[i].is_element(e);
      return result;
    }
    else {
      return false;
    }
  }

  string symbol() {
    import std.array;

    auto s = appender!string;
    s ~= "(";
    foreach (i, a; arg) {
      if (i != 0)
        s ~= "⊗";
      s ~= a.symbol();
    }
    s ~= ")";
    return s.data;
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(arg, "ProductObject");
  }
}

//  _  _           ___      _
// | || |___ _ __ / __| ___| |_
// | __ / _ \ '  \\__ \/ -_)  _|
// |_||_\___/_|_|_|___/\___|\__|

immutable class HomSet : ISetObject {

  ISetObject src;
  ISetObject trg;

  this(immutable ISetObject _src, immutable ISetObject _trg) {
    src = _src;
    trg = _trg;

    import std.format;

    assert(!(src.isEqual(terminalObject) && trg.is_homset),
        format!"Constructing homset %s→%s, which is probably undesirable!"(src, trg));
  }

  bool is_element(immutable ISetMorphism elem) {
    auto m = cast(immutable ISetMorphism)(elem);
    if (m)
      return (m.source().isEqual(source())) && (m.target().isEqual(target()));
    else
      return false;
  }

  immutable(ISetObject) source() {
    return src;
  }

  immutable(ISetObject) target() {
    return trg;
  }

  string symbol() {
    return "(" ~ source().symbol() ~ "→" ~ target().symbol() ~ ")";
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(src, trg, "HomSet");
  }
}

//  __  __              _    _
// |  \/  |___ _ _ _ __| |_ (_)____ __
// | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|

immutable class Morphism : ISetMorphism {

  ISetObject src;
  ISetObject trg;
  string sym;

  this(string _sym, immutable ISetObject _src, immutable ISetObject _trg) {
    src = _src;
    trg = _trg;
    sym = _sym;
  }

  immutable(ISetObject) source() {
    return src;
  }

  immutable(ISetObject) target() {
    return trg;
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");
    return new immutable Evaluated(this, elem);
  }

  immutable(ISetObject) set() {
    return new immutable HomSet(source(), target());
  }

  string symbol() {
    return sym;
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(src, trg, sym, "Morphism");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s);
  }
}

//  ___    _         _   _ _
// |_ _|__| |___ _ _| |_(_) |_ _  _
//  | |/ _` / -_) ' \  _| |  _| || |
// |___\__,_\___|_||_\__|_|\__|\_, |
//                             |__/

immutable class Identity : ISetMorphism {

  ISetObject object;

  this(immutable ISetObject obj) {
    object = obj;
  }

  immutable(ISetObject) source() {
    return object;
  }

  immutable(ISetObject) target() {
    return object;
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");
    return elem;
  }

  immutable(ISetObject) set() {
    return new immutable HomSet(object, object);
  }

  string symbol() {
    return "id";
  }

  string latex() {
    return "id";
  }

  ulong toHash() {
    return computeHash(object.toHash(), "Identity");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s);
  }
}

//   ___             _            _     __  __              _    _
//  / __|___ _ _  __| |_ __ _ _ _| |_  |  \/  |___ _ _ _ __| |_ (_)____ __
// | (__/ _ \ ' \(_-<  _/ _` | ' \  _| | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
//  \___\___/_||_/__/\__\__,_|_||_\__| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                                                    |_|

immutable class ConstantMorphism : ISetMorphism {

  ISetObject src;
  ISetObject trg;

  ISetMorphism element;

  this(immutable ISetObject _src, immutable ISetObject _trg, immutable ISetMorphism elem) {
    src = _src;
    trg = _trg;
    element = elem;
  }

  immutable(ISetObject) source() {
    return src;
  }

  immutable(ISetObject) target() {
    return trg;
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");
    return element;
  }

  immutable(ISetObject) set() {
    return new immutable HomSet(source(), target());
  }

  string symbol() {
    return "const(" ~ element.symbol() ~ ")";
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(src, trg, element, "ConstantMorphism");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return element.containsSymbol(s) || this.isEqual(s);
  }
}

//   ___             _            _
//  / __|___ _ _  __| |_ __ _ _ _| |_
// | (__/ _ \ ' \(_-<  _/ _` | ' \  _|
//  \___\___/_||_/__/\__\__,_|_||_\__|

immutable class Constant : ISetMorphism {

  ISetObject objX;
  ISetObject objY;

  this(immutable ISetObject _objX, immutable ISetObject _objY) {
    objX = _objX;
    objY = _objY;
  }

  immutable(ISetObject) source() {
    return objX;
  }

  immutable(ISetObject) target() {
    return new immutable HomSet(objY, objX);
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");

    return new immutable ConstantMorphism(objY, objX, elem);
  }

  immutable(ISetObject) set() {
    return new immutable HomSet(source(), target());
  }

  string symbol() {
    return "const";
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(objX, objY, "Constant");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s);
  }
}

//  ___          _        _   _
// | _ \_ _ ___ (_)___ __| |_(_)___ _ _
// |  _/ '_/ _ \| / -_) _|  _| / _ \ ' \
// |_| |_| \___// \___\__|\__|_\___/_||_|
//            |__/

immutable class Projection : ISetMorphism {

  int I;
  ISetObject[] arg;

  this(const int _I, immutable ISetObject[] _arg) {
    arg = _arg;
    I = _I;
  }

  immutable(ISetObject) source() {
    return new immutable ProductObject(arg);
  }

  immutable(ISetObject) target() {
    return arg[I];
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");

    immutable e = cast(immutable ProductElement)(elem);
    assert(e);
    return e.arg[I];
  }

  immutable(ISetObject) set() {
    return new immutable HomSet(source(), target());
  }

  string symbol() {
    import std.conv;

    return "π" ~ to!string(I);
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(I, arg, "Projection");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s);
  }
}

//   ___                                _   __  __              _    _
//  / __|___ _ __  _ __  ___ ___ ___ __| | |  \/  |___ _ _ _ __| |_ (_)____ __
// | (__/ _ \ '  \| '_ \/ _ (_-</ -_) _` | | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
//  \___\___/_|_|_| .__/\___/__/\___\__,_| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|                                     |_|

immutable class ComposedMorphism : ISetMorphism {

  ISetMorphism[] arg;

  this(immutable ISetMorphism[] _arg) {
    assert(are_composable(_arg), "Morphisms are not composable!");
    arg = _arg;
  }

  immutable(ISetObject) source() {
    return arg[$ - 1].source();
  }

  immutable(ISetObject) target() {
    return arg[0].target();
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");

    immutable(ISetMorphism)[] e;
    e ~= elem;
    const ulong N = arg.length;
    foreach (i; 0 .. N) {
      e ~= arg[N - i - 1](e[i]);
    }

    return e[N];
  }

  immutable(ISetObject) set() {
    return new immutable HomSet(source(), target());
  }

  string symbol() {
    import std.array;

    auto s = appender!string;
    s ~= "(";
    foreach (i, a; arg) {
      if (i != 0)
        s ~= "∘";
      s ~= a.symbol();
    }
    s ~= ")";
    return s.data;
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(arg, "ComposedMorphism");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    bool result = false;
    foreach (a; arg)
      result |= a.containsSymbol(s);
    return result || this.isEqual(s);
  }
}

//  ___             _         _     __  __              _    _
// | _ \_ _ ___  __| |_  _ __| |_  |  \/  |___ _ _ _ __| |_ (_)____ __
// |  _/ '_/ _ \/ _` | || / _|  _| | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_| |_| \___/\__,_|\_,_\__|\__| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                                                |_|

immutable class ProductMorphism : ISetMorphism {

  ISetMorphism[] arg;

  this(immutable ISetMorphism[] _arg) {
    // assert(all_same_sources(_arg));
    arg = _arg;
  }

  immutable(ISetObject) source() {
    return arg[0].source();
  }

  immutable(ISetObject) target() {
    return new immutable ProductObject(map!(m => m.target())(arg).array);
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");

    return new immutable ProductElement(map!(m => m(elem))(arg).array);
  }

  immutable(ISetObject) set() {
    return new immutable HomSet(source(), target());
  }

  string symbol() {
    import std.array;

    auto s = appender!string;
    s ~= "(";
    foreach (i, a; arg) {
      if (i != 0)
        s ~= "⊗";
      s ~= a.symbol();
    }
    s ~= ")";
    return s.data;
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(arg, "ProductMorphism");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    bool result = false;
    foreach (a; arg)
      result |= a.containsSymbol(s);
    return result || this.isEqual(s);
  }
}

//  _  _
// | || |___ _ __
// | __ / _ \ '  \
// |_||_\___/_|_|_|

immutable class Hom : ISetMorphism {

  ISetObject[] obj;

  this(immutable ISetObject[] _obj) {
    obj = _obj;
  }

  immutable(ISetObject) source() {
    immutable ISetObject[] _obj = obj;
    return prod(map!(i => homset(_obj[i], _obj[i + 1]))(range(obj.length - 1)).array); // 
  }

  immutable(ISetObject) target() {
    return homset(obj[0], obj[$ - 1]);
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");

    auto e = cast(immutable ProductElement)(elem);
    auto m = cast(immutable ISetMorphism[])(e.arg);
    import std.range;

    return compose(m.retro.array);
  }

  immutable(ISetObject) set() {
    return new immutable HomSet(source(), target());
  }

  string symbol() {
    return "Hom";
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(obj, "Hom");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s);
  }
}

//  ___             _
// | _ \_ _ ___  __| |
// |  _/ '_/ _ \/ _` |
// |_| |_| \___/\__,_|

immutable class Prod : ISetMorphism {

  ISetObject src;
  ISetObject[] trg;

  this(immutable ISetObject _src, immutable ISetObject[] _trg) {
    src = _src;
    trg = _trg;
  }

  immutable(ISetObject) source() {
    auto _src = src;
    return prod(map!(t => homset(_src, t))(trg).array);
  }

  immutable(ISetObject) target() {
    return homset(src, prod(trg));
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");

    auto e = cast(immutable ProductElement)(elem);
    auto m = cast(immutable ISetMorphism[])(e.arg);
    immutable(ISetMorphism)[] mlist = map!(x => cast(immutable ISetMorphism)(x))(m).array;

    return product(mlist);
  }

  immutable(ISetObject) set() {
    return new immutable HomSet(source(), target());
  }

  string symbol() {
    return "Prod";
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(src, trg, "Prod");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s);
  }
}

//  ___          _
// | __|_ ____ _| |
// | _|\ V / _` | |
// |___|\_/\__,_|_|

immutable class Eval : ISetMorphism {

  ISetObject src;
  ISetObject trg;

  this(immutable ISetObject _src, immutable ISetObject _trg) {
    src = _src;
    trg = _trg;
  }

  immutable(ISetObject) source() {
    return prod(homset(src, trg), src);
  }

  immutable(ISetObject) target() {
    return trg;
  }

  immutable(ISetMorphism) opCall(immutable ISetMorphism elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");

    auto e = cast(immutable ProductElement)(elem);
    auto m = cast(immutable ISetMorphism)(e[0]);
    assert(e);
    assert(m);
    return m(e[1]);
  }

  immutable(ISetObject) set() {
    return new immutable HomSet(source(), target());
  }

  string symbol() {
    return "Eval";
  }

  string latex() {
    return symbol();
  }

  ulong toHash() {
    return computeHash(src, trg, "Eval");
  }

  bool containsSymbol(immutable IExpression s) immutable {
    return this.isEqual(s);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////

immutable(ISetMorphism) extractSymbol(immutable(ISetMorphism) expression,
    immutable(ISetMorphism) symbol) {

  if (!expression.containsSymbol(symbol)) {
    return constant(symbol.set(), expression);
  }

  if (symbol.isEqual(expression)) {
    return identity(symbol.set());
  }

  import std.stdio;

  // Element
  {
    auto e = cast(immutable(Element))(expression);
    if (e) {
      if (symbol.isEqual(e)) {
        return identity(e.set());
      }
      else {
        return constant(symbol.set(), e);
      }
    }
  }

  // Evaluated
  {
    auto e = cast(immutable Evaluated)(expression);
    if (e) {
      if (e.morph.containsSymbol(symbol)) {
        auto pr = product(e.morph.extractSymbol(symbol), e.element.extractSymbol(symbol));

        return compose(eval(e.morph.source(), e.morph.target()), pr);
      }
      else {
        return compose(e.morph, extractSymbol(e.element, symbol));
      }
    }
  }

  // ProductElement
  {
    auto e = cast(immutable ProductElement)(expression);
    if (e) {
      import std.array;

      return product(map!(x => extractSymbol(x, symbol))(e.arg).array);
    }
  }

  // Constant Morphism
  {
    auto e = cast(immutable ConstantMorphism)(expression);
    if (e) {

      // auto constant_Const = constant(symbol.set(),
      //     new immutable Constant(e.element.set(), e.source()));
      // auto tmp1 = e.element.extractSymbol(symbol);
      // auto tmp2 = product(constant_Const, tmp1);
      // auto Eval_ = eval(tmp1.target(), expression.set());

      return new immutable Constant(e.target(), e.source());
    }
  }

  // Composed Morphism
  {
    auto e = cast(immutable ComposedMorphism)(expression);
    if (e) {
      import std.range;

      auto pr = product(map!(x => x.extractSymbol(symbol))(e.arg).retro.array);
      auto homObj = [e.arg[$ - 1].source()].chain(map!(x => x.target())(e.arg.retro.array)).array;
      auto Hom_ = new immutable Hom(homObj);

      return compose(Hom_, pr);
    }
  }

  // ProductMorphism
  {
    auto e = cast(immutable ProductMorphism)(expression);
    if (e) {

      auto pr = product(map!(x => x.extractSymbol(symbol))(e.arg).array);
      auto ProdSrc = e.source();
      auto ProdTrg = map!(x => x.target())(e.arg).array;
      auto Prod_ = new immutable Prod(ProdSrc, ProdTrg);

      return compose(Prod_, pr);
    }
  }

  //writeln("Error: could not extract from: ", expression);
  return identity(symbol.set());
}

///////////////////////////////////////////////////////////////////////////////////////////

void print(immutable ISetMorphism morph) {
  import std.stdio;

  writeln(morph.symbol(), ": ", morph.source().symbol(), "→", morph.target.symbol());
}
