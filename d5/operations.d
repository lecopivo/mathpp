
abstract class Operation{
  
  string opName() immutable;
  string symbol() immutable;
  string latex() immutable;
  
  ulong arity() immutable;
}




/// Future tests for operations...

bool isCommutative(immutable Operation op){
  return false;
}

bool distributesOver(immutable Operation op1, immutable Operation op2){
  return op1.distributesOverFromLeft(op2) && op1.distributesOverFromRight(op2);
}

bool distributesOverFromLeft(immutable Operation op1, immutable Operation op2){
  return false;
}

bool distributesOverFromRight(immutable Operation op1, immutable Operation op2){
  return false;
}

