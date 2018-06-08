#include <iostream>

#include <meta/type_name.h>

using namespace std;
using namespace mathpp::meta;

int main(){

  cout << type_name<decltype(cout)>() << endl;
  cout << type_name(cout) << endl;

  return 0;
}

