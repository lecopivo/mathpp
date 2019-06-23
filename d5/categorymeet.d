import nonsense;

//   ___      _                           __  __         _
//  / __|__ _| |_ ___ __ _ ___ _ _ _  _  |  \/  |___ ___| |_
// | (__/ _` |  _/ -_) _` / _ \ '_| || | | |\/| / -_) -_)  _|
//  \___\__,_|\__\___\__, \___/_|  \_, | |_|  |_\___\___|\__|
//                   |___/         |__/

immutable(Category) meet(immutable Category cat1, immutable Category cat2) {

  // Right now we assume total ordering on categories
  if(cat1.isSubCategoryOf(cat2)){
    return cat2;
  }else{
    return cat1;
  }
}

immutable(Category) meet(immutable Category[] cat) {
  assert(cat.length != 0);
  if (cat.length == 1)
    return cat[0];
  else
    return meet(cat[0], meet(cat[1 .. $]));
}
