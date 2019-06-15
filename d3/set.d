import base;
import checks;
import hash;
import meta;

import std.array;
import std.algorithm;

interface ISetElement : ISymbolic {

  immutable(ISetObject) set() immutable;
}

interface ISetObject : ISymbolic {

  bool is_element(immutable ISetElement elem) immutable;
}

interface ISetMorphism : ISymbolic, ISetElement {

  immutable(ISetObject) source() immutable;
  immutable(ISetObject) target() immutable;

  immutable(ISetElement) opCall(immutable ISetElement elem) immutable;
}

//   ___                     _   _
//  / _ \ _ __  ___ _ _ __ _| |_(_)___ _ _  ___
// | (_) | '_ \/ -_) '_/ _` |  _| / _ \ ' \(_-<
//  \___/| .__/\___|_| \__,_|\__|_\___/_||_/__/
//       |_|

immutable(ISetMorphism) compose(Morph...)(immutable Morph morph) {

  enum N = Morph.length;
  enum string mlist = "[" ~ "cast(immutable(ISetMorphism))(morph[J])".expand(N, ",", "J") ~ "]";

  return new immutable ComposedMorphism(mixin(mlist));
}

immutable(ISetMorphism) product(Morph...)(Morph morph) {

  static if (Morph.length >= 2) {
    enum N = Morph.length;
    enum string mlist = "[" ~ "cast(immutable(ISetMorphism))(morph[J])".expand(N, ",", "J") ~ "]";

    return new immutable ProductMorphism(mixin(mlist));
  }else static if(Morph.length==1 && is(Morph[0] : M[], M)){

    return new immutable ProductMorphism(morph);
    
  }else{
    return morph[0];
  }
}

immutable(ISetMorphism) projection(Obj...)(int I, Obj obj) {

  enum N = Obj.length;
  enum string olist = "[" ~ "cast(immutable(ISetObject))(obj[J])".expand(N, ",", "J") ~ "]";

  return new immutable Projection(I, mixin(olist));
}

immutable(ISetMorphism) identity(immutable ISetObject obj) {
  return new immutable Identity(obj);
}

immutable(ISetMorphism) constant(immutable ISetObject src, immutable ISetElement elem) {
  return new immutable ConstantMorphism(src, elem.set(), elem);
}

//  ___ _                   _
// | __| |___ _ __  ___ _ _| |_
// | _|| / -_) '  \/ -_) ' \  _|
// |___|_\___|_|_|_\___|_||_\__|

immutable class Element : ISetElement {

  ISetObject object;
  string sym;

  this(string symbol, immutable ISetObject _object) {
    object = _object;
    sym = symbol;
  }

  immutable(ISetObject) set() {
    return object;
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
}

//  ___          _           _          _
// | __|_ ____ _| |_  _ __ _| |_ ___ __| |
// | _|\ V / _` | | || / _` |  _/ -_) _` |
// |___|\_/\__,_|_|\_,_\__,_|\__\___\__,_|

immutable class Evaluated : ISetElement {

  ISetMorphism morph;
  ISetElement element;

  this(immutable ISetMorphism _morph, immutable ISetElement _elem) {
    morph = _morph;
    element = _elem;
  }

  immutable(ISetObject) set() {
    return morph.target();
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
}

//  ___             _         _   ___ _                   _
// | _ \_ _ ___  __| |_  _ __| |_| __| |___ _ __  ___ _ _| |_
// |  _/ '_/ _ \/ _` | || / _|  _| _|| / -_) '  \/ -_) ' \  _|
// |_| |_| \___/\__,_|\_,_\__|\__|___|_\___|_|_|_\___|_||_\__|

immutable class ProductElement : ISetElement {

  alias arg this;

  ISetElement[] arg;

  this(immutable ISetElement[] _arg) {
    arg = _arg;
  }

  immutable(ISetObject) set() {
    return new immutable ProductObject([arg[0].set()]);
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

  bool is_element(immutable ISetElement elem) {
    return elem.set() == this;
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

//  _____              _           _    ___  _     _        _
// |_   _|__ _ _ _ __ (_)_ _  __ _| |  / _ \| |__ (_)___ __| |_
//   | |/ -_) '_| '  \| | ' \/ _` | | | (_) | '_ \| / -_) _|  _|
//   |_|\___|_| |_|_|_|_|_||_\__,_|_|  \___/|_.__// \___\__|\__|
//                                              |__/

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

  bool is_element(immutable ISetElement elem) {
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
  }

  bool is_element(immutable ISetElement elem) {
    auto m = cast(immutable ISetMorphism)(elem);
    if (m)
      return (m.source() == source()) && (m.target() == target());
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

  immutable(ISetElement) opCall(immutable ISetElement elem) {
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

  immutable(ISetElement) opCall(immutable ISetElement elem) {
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
}

//   ___             _            _     __  __              _    _
//  / __|___ _ _  __| |_ __ _ _ _| |_  |  \/  |___ _ _ _ __| |_ (_)____ __
// | (__/ _ \ ' \(_-<  _/ _` | ' \  _| | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
//  \___\___/_||_/__/\__\__,_|_||_\__| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                                                    |_|

immutable class ConstantMorphism : ISetMorphism {

  ISetObject src;
  ISetObject trg;

  ISetElement element;

  this(immutable ISetObject _src, immutable ISetObject _trg, immutable ISetElement elem) {
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

  immutable(ISetElement) opCall(immutable ISetElement elem) {
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

  immutable(ISetMorphism) opCall(immutable ISetElement elem) {
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

  immutable(ISetElement) opCall(immutable ISetElement elem) {
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
}

//   ___                                _   __  __              _    _
//  / __|___ _ __  _ __  ___ ___ ___ __| | |  \/  |___ _ _ _ __| |_ (_)____ __
// | (__/ _ \ '  \| '_ \/ _ (_-</ -_) _` | | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
//  \___\___/_|_|_| .__/\___/__/\___\__,_| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|                                     |_|

immutable class ComposedMorphism : ISetMorphism {

  ISetMorphism[] arg;

  this(immutable ISetMorphism[] _arg) {
    assert(are_composable(_arg));
    arg = _arg;
  }

  immutable(ISetObject) source() {
    return arg[$ - 1].source();
  }

  immutable(ISetObject) target() {
    return arg[0].target();
  }

  immutable(ISetElement) opCall(immutable ISetElement elem) {
    assert(source().is_element(elem), "Input is not in the `Source` of the morphism!");

    immutable(ISetElement)[] e;
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
}

//  ___             _         _     __  __              _    _
// | _ \_ _ ___  __| |_  _ __| |_  |  \/  |___ _ _ _ __| |_ (_)____ __
// |  _/ '_/ _ \/ _` | || / _|  _| | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_| |_| \___/\__,_|\_,_\__|\__| |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                                                |_|

immutable class ProductMorphism : ISetMorphism {

  ISetMorphism[] arg;

  this(immutable ISetMorphism[] _arg) {
    assert(all_same_sources(_arg));
    arg = _arg;
  }

  immutable(ISetObject) source() {
    return arg[0].source();
  }

  immutable(ISetObject) target() {
    return new immutable ProductObject(map!(m => m.target())(arg).array);
  }

  immutable(ISetElement) opCall(immutable ISetElement elem) {
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
}

///////////////////////////////////////////////////////////////////////////////////////////

immutable(ISetMorphism) extractSymbol(immutable(ISymbolic) expression, immutable(ISetElement) symbol) {

  if(symbol.isEqual(expression)){
    return identity(symbol.set());
  }

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
      return compose(e.morph, extractSymbol(e.element, symbol));
    }
  }

  // ProductElement
  {
    auto e = cast(immutable ProductElement)(expression);
    if (e) {
      import std.array;

      //auto mlist = ;
      return product(map!(x => extractSymbol(x, symbol))(e.arg).array);
    }
  }

  // 

  return identity(symbol.set());
}

///////////////////////////////////////////////////////////////////////////////////////////

void print(immutable ISetMorphism morph) {
  import std.stdio;

  writeln(morph.symbol(), ": ", morph.source().symbol(), "→", morph.target.symbol());
}
