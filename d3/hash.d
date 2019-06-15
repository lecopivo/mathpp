long sdbm(long x, long y) {
  return y + (x << 6) + (x << 16) - x;
}

ulong sdbm(string str) {
  import std.conv;

  long hash = 0;

  foreach (s; str) {
    hash = sdbm(hash, to!long(s));
  }

  return cast(ulong)(hash);
}

ulong computeHash(X...)(X x) {

  ulong hashOfChoice(string str) {
    return sdbm(str);
  }

  ulong hash(Y)(Y y) {
    import std.traits;

    static if (hasMember!(Y, "toHash")) {
      return y.toHash();
    }
    else static if (is(Y == string)) {
      return hashOfChoice(y);
    }
    else static if (is(Y : T[], T)) {

      long result = 0;
      foreach (z; y) {
	result = sdbm(result, hash(z));
      }
      return result;
    }
    else {
      return cast(ulong)(y);
    }
  }

  long result = 0;
  static foreach(t; x){
    result = sdbm(result, hash(t));
  }

  return result;
}
