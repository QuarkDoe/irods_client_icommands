
set( CMAKE_C_COMPILER "clang" )
set( CMAKE_CXX_COMPILER "clang++" )
# set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} " )
# set( CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} " )
# set( CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} " )
add_compile_options( -Wall -Wextra -Werror -Wno-unused-function -Wno-unused-parameter )
# add_compile_options( -nostdinc++ -Wall -Wextra -Werror -Wno-unused-function -Wno-unused-parameter )
# link_libraries(c++abi)
