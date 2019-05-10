cmake_minimum_required(VERSION 3.5)

add_compile_options(-std=c++17 -Wno-ignored-attributes)

find_package(Eigen3 REQUIRED)

include_directories(${EIGEN3_INCLUDE_DIR})

include_directories(src)

add_subdirectory(src)
add_subdirectory(test)
