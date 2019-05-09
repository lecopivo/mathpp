#pragma once

#include "meta_utils.h"
#include "category_utils.h"
#include <iostream>

template <class Category, class Object> void test_object(Object const&) {
  std::cout << "Is `" << type_name<Object>() << "` object of `"
            << type_name<Category>() << "`: "
            << Category::template is_object<Object> << std::endl;
}

template<class Category, class Morph>
void test_morphism(Morph const&){
  std::cout << "Is `" << type_name<Morph>() << "` morphism of `"
            << type_name<Category>() << "`: "
            << Category::template is_morphism<Morph> << std::endl;
  
}

template<class Category, class Morph2, class Morph1>
void test_morphism(Morph2 const&, Morph1 const&){
  std::cout << "Are morphisms `" << type_name<Morph1>() << "` and `" << type_name<Morph2>() << "` composable in `"
            << type_name<Category>() << "`: "
            << are_composable<Category, Morph2, Morph1> << std::endl;
  
}

