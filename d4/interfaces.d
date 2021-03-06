import category;

// interface ICategorical {
//   immutable(ICategory) category() immutable;
// }

//  ___ _                   _
// | __| |___ _ __  ___ _ _| |_
// | _|| / -_) '  \/ -_) ' \  _|
// |___|_\___|_|_|_\___|_||_\__|

/** 
 * Element of a set
 */
interface IElement : ISymbolic {

  /**
   * Gives a set where this element belongs to.
   */
  immutable(IObject) set() immutable;

  bool containsSymbol(immutable IElement s) immutable;
  immutable(IMorphism) extractElement(immutable IElement elem) immutable;

  immutable(IElement) opCall(immutable IElement elem) immutable;
}

interface IOpElement : IElement {
  string opName() immutable;
  string operation() immutable;
  string latexOperation() immutable;

  ulong size() immutable;
  immutable(IElement)[] args() immutable;
  immutable(IElement) opIndex(ulong I) immutable;
}

//   ___  _     _        _
//  / _ \| |__ (_)___ __| |_
// | (_) | '_ \| / -_) _|  _|
//  \___/|_.__// \___\__|\__|
//           |__/

interface IObject : ISymbolic{
  final immutable(IMorphism) identity() immutable {
    return new immutable Identity(this);
  }

  bool isElement(immutable IElement elem) immutable;
  bool isSubsetOf(immutable IObject obj) immutable;

  immutable(ICategory) category() immutable;
}

interface IHomSet : IObject {
  immutable(ICategory) morphismCategory() immutable;

  immutable(IObject) source() immutable;
  immutable(IObject) target() immutable;
}

interface IOpObject : IObject {

  string operation() immutable;
  string latexOperation() immutable;

  ulong size() immutable;
  immutable(IObject)[] args() immutable;
  immutable(IObject) opIndex(ulong I) immutable;
}

interface IProductObject : IOpObject {
  immutable(IMorphism) projection(ulong I) immutable;
}

interface ISumObject : IOpObject {
  immutable(IMorphism) injection(ulong I) immutable;
}

interface ITensorProductObject : IOpObject {
}

interface IInitialObject : IObject {

  immutable(IMorphism) initialMorphism(immutable IObject obj) immutable;
}

interface ITerminalObject : IObject {

  immutable(IMorphism) terminalMorphism(immutable IObject obj) immutable;
}

//   ___  _     _        _        _           _
//  / _ \| |__ (_)___ __| |_   __| |_  ___ __| |__ ___
// | (_) | '_ \| / -_) _|  _| / _| ' \/ -_) _| / /(_-<
//  \___/|_.__// \___\__|\__| \__|_||_\___\__|_\_\/__/
//           |__/

bool isOpObject(string op)(immutable IObject obj) {
  if (cast(immutable IOpObject!(op))(obj)) {
    return true;
  }
  else {
    return false;
  }
}

bool isProductObject(immutable IObject obj) {
  if (cast(immutable IProductObject)(obj)) {
    return true;
  }
  else {
    return false;
  }
}

bool isSumObject(immutable IObject obj) {
  if (cast(immutable ISumObject)(obj)) {
    return true;
  }
  else {
    return false;
  }
}

bool isHomSet(immutable IObject obj) {
  if (cast(immutable IHomSet)(obj)) {
    return true;
  }
  else {
    return false;
  }
}

//  __  __              _    _
// |  \/  |___ _ _ _ __| |_ (_)____ __
// | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|

interface IMorphism : IElement{
  immutable(ICategory) category() immutable;
  
  immutable(IHomSet) set() immutable;

  immutable(IObject) source() immutable;
  immutable(IObject) target() immutable;

  //immutable(IElement) opCall(immutable IElement) immutable;
}

interface IOpMorphism : IMorphism {

  string opName() immutable;
  string operation() immutable;
  string latexOperation() immutable;

  ulong size() immutable;
  immutable(IMorphism)[] args() immutable;
  immutable(IMorphism) opIndex(ulong I) immutable;
}


interface IProductMorphism : IOpMorphism {

  immutable(IProductObject) target() immutable;

}

bool isComposedMorphism(immutable IMorphism morph) {
  if (cast(immutable ComposedMorphism)(morph)) {
    return true;
  }
  else {
    return false;
  }
}

bool isProductMorphism(immutable IMorphism morph) {
  if (cast(immutable IProductMorphism)(morph)) {
    return true;
  }
  else {
    return false;
  }
}

// interface ISumMorphism : IOpMorphism{

//   final string operation() immutable{
//     return "⊕";
//   }

//   final string latexOperation() immutable{
//     return "\\oplus";
//   }
// }

// interface ITensorProductMorphism : IOpMorphism{

//   final string operation() immutable{
//     return "⊗";
//   }

//   final string latexOperation() immutable{
//     return "\\otimes";
//   }
// }

//   ___      _
//  / __|__ _| |_ ___ __ _ ___ _ _ _  _
// | (__/ _` |  _/ -_) _` / _ \ '_| || |
//  \___\__,_|\__\___\__, \___/_|  \_, |
//                   |___/         |__/

interface ICategory : ISymbolic {

  final bool isObject(immutable IObject obj) immutable {
    return obj.isIn(this); //meet([this, obj.category()]).isEqual(this);
  }

  final bool isMorphism(immutable IMorphism morph) immutable {
    return morph.isIn(this); //meet([this, morph.category()]).isEqual(this);
  }

  string arrow() immutable;
  string latexArrow(string over = "") immutable;

  final immutable(IOpMorphism) compose(immutable IMorphism[] morph) immutable {
    assert(morph.areComposableIn(Set), "Morphisms are not composable");
    return new immutable ComposedMorphism(morph);
  }

  bool hasHomSet() immutable;
  bool hasInitialObject() immutable;
  bool hasTerminalObject() immutable;
  bool hasTensorProduct() immutable;
  bool hasProduct() immutable;
  bool hasSum() immutable;

  //bool hasNProduct() immutable;
  //bool hasNSum() immutable;
  //bool hasNTensorProduct() immtable;

  final immutable(IHomSet) homSet(immutable IObject src, immutable IObject trg) immutable {
    return new immutable HomSet(this, src, trg);
  }

  immutable(IInitialObject) initialObject() immutable;
  immutable(ITerminalObject) terminalObject() immutable;

  immutable(IMorphism) initialMorphism(immutable IObject obj) immutable;
  immutable(IMorphism) terminalMorphism(immutable IObject obj) immutable;

  immutable(IProductObject) productObject(immutable IObject[] obj) immutable;
  immutable(ISumObject) sumObject(immutable IObject[] obj) immutable;

  immutable(IOpMorphism) product(immutable IMorphism[] morph) immutable;
  immutable(IOpMorphism) sum(immutable IMorphism[] morph) immutable;
}
