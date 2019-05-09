cmake_minimum_required(VERSION 2.8.11)

message("My compilation flags are ${CMAKE_CXX_FLAGS}")

add_compile_options(-std=c++17)

add_executable(main main.cpp)
add_executable(universe_test universe_test.cpp)
add_executable(set_test set_test.cpp)
