import std.stdio;


string foo(T...)(){

  string s = " ";

  static foreach(I,S;T){
    import std.conv;
    s ~= typeid(S).toString() ~ " " ~ to!string(I) ~ " ";
  }

  return s;
}


int main(){


  writeln(foo!(int, double ,string));



  return 0;
}
