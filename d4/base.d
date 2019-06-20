
/**
 * Anything that has a symbol.
 */
interface ISymbolic  {
  string symbol() immutable;
  string latex() immutable;

  ulong toHash() immutable;

  final string toString() immutable{
    return symbol();
  }

  final bool isEqual(immutable ISymbolic s) immutable {
    return toHash() == s.toHash();
  }
}

interface IExpression : ISymbolic{

  bool containsSymbol(immutable IExpression s) immutable;
}

