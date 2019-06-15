// This calling convention is probably much better
string expand(string code, int N, string separator = ",", string variable = "I") {
  string result = "";
  foreach (I; 0 .. N) {
    if (I != 0)
      result ~= separator;
    import std.array;
    import std.conv;

    result ~= code.replace(variable, to!string(I));
  }

  return result;
}
