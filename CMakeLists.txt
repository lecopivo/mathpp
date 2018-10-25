cmake_minimum_required(VERSION 3.5)

set(CMAKE_CXX_FLAGS -std=c++17)

include_directories(src)

add_subdirectory(src)
add_subdirectory(test)
