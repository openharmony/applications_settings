# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(Settings)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_compile_options(-fstack-protector-strong -D_FORTIFY_SOURCE=2 -O2 -fPIC)
add_link_options(-Wl,-z,relro,-z,now,-z,noexecstack -Wl,--build-id=none -s)

add_library(native SHARED ./kernel/kernel.cpp)
target_link_libraries(native PUBLIC libace_napi.z.so libhilog_ndk.z.so)