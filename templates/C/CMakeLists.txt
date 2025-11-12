cmake_minimum_required(VERSION 4.1.0)

set(PROJECT_NAME
    C
)

project(${PROJECT_NAME})

set(SRC_FILES
    src/main.c
)

add_executable(${PROJECT_NAME} ${SRC_FILES})

target_include_directories(${PROJECT_NAME} PUBLIC lib/)