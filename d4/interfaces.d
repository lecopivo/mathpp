import base;
import category;

interface ICategorical {
  immutable(ICategory) category() immutable;
}

//   ___  _     _        _
//  / _ \| |__ (_)___ __| |_
// | (_) | '_ \| / -_) _|  _|
//  \___/|_.__// \___\__|\__|
//           |__/

interface IObject : ISymbolic, ICategorical {
  immutable(IMorphism) identity() immutable;
}

interface ISetObject : IObject {
  bool isElement(immutable IMorphism morph) immutable;
}

interface IHomSet : ISetObject {
  immutable(IObject) source() immutable;
  immutable(IObject) target() immutable;
}

interface IOpObject(string op) : IObject {
  int size() immutable;
  immutable(IObject) opIndex(int I) immutable;
}

interface IProductObject : IOpObject!"✕" {
  immutable(IMorphism) projection(int I) immutable;
}

interface ISumObject : IOpObject!"⊕" {
  immutable(IMorphism) injection(int I) immutable;
}

interface ITensorProductObject : IOpObject!"⊗" {
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


bool isInitialObjectIn(immutable IObject obj, immutable ICategory cat) {
  return cat.hasInitialObject() && cat.initialObject().isEqual(obj);
}

bool isTerminalObjectIn(immutable IObject obj, immutable ICategory cat) {
  return cat.hasTerminalObject() && cat.terminalObject().isEqual(obj);
}


//  __  __              _    _
// |  \/  |___ _ _ _ __| |_ (_)____ __
// | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
// |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
//                |_|

interface IMorphism : IExpression, ICategorical {

  immutable(IObject) source() immutable;
  immutable(IObject) target() immutable;
}

interface ISetMorphism : IMorphism {
  immutable(ISetMorphism) opCall(immutable ISetMorphism morph) immutable;
}

interface IOpMorphism(string op) : IMorphism {
  int size() immutable;
  immutable(IMorphism) opIndex(int I) immutable;
}

interface IProductMorphism : IOpMorphism!"✕"{
  
}

interface ISumMorphism : IOpMorphism!"⊕"{
  
}

interface ITensorProductMorphism : IOpMorphism!"⊗"{
  
}

//   ___      _
//  / __|__ _| |_ ___ __ _ ___ _ _ _  _
// | (__/ _` |  _/ -_) _` / _ \ '_| || |
//  \___\__,_|\__\___\__, \___/_|  \_, |
//                   |___/         |__/

interface ICategory : ISymbolic {

  final bool isObject(immutable IObject obj) immutable {
    return meet([this, obj.category()]).isEqual(this);
  }

  final bool isMorphism(immutable IMorphism morph) immutable {
    return meet([this, morph.category()]).isEqual(this);
  }

  string arrow() immutable;
  string latexArrow() immutable;

  final immutable(IMorphism) compose(immutable IMorphism[] morph) immutable {
    assert(morph.are_composable_in(Set), "Morphisms are not composable");
    return new immutable ComposedMorphism(this, morph);
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

  immutable(IObject) initialObject() immutable;
  immutable(IObject) terminalObject() immutable;
  
  immutable(IMorphism) initialMorphism(immutable IObject obj) immutable;
  immutable(IMorphism) terminalMorphism(immutable IObject obj) immutable;

  immutable(IProductMorphism) productObject(immutable IObject[] obj) immutable;
  immutable(ISumMorphism) sumObject(immutable IObject[] obj) immutable;

  immutable(IProductMorphism) product(immutable IMorphism[] morph) immutable;
  immutable(ISumMorphism) sum(immutable IMorphism[] morph) immutable;
}
