import nonsense;


interface ISymbolic  {
  // string symbol() immutable;
  // string latex() immutable;

  // ulong toHash() immutable;

  // final string toString() immutable{
  //   return symbol();
  // }

  // final bool isEqual(immutable ISymbolic s) immutable {
  //   return toHash() == s.toHash();
  // }
}

interface IOpResult(X){

  string opName() immutable;
  string operation() immutable;
  string latexOperation() immutable;

  ulong size() immutable;
  immutable(X) opIndex(ulong I) immutable;
}

interface IProductObject : IOpResult!(CObject){

}

interface IProductMorphism : IOpResult!(Morphism){

}
