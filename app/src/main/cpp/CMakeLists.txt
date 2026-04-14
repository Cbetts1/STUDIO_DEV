cmake_minimum_required(VERSION 3.22.1)
project(bootstrap C CXX)

add_library(
    bootstrap
    SHARED
    bootstrap.c
)

target_link_libraries(bootstrap android log)
