#
# Copyright (c) 2008-2022 the Urho3D project.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

if (NOT CMAKE_PROJECT_NAME STREQUAL Urho3D AND NOT URHO3D_AS_SUBMODULE)
    # Set CMake minimum version
    cmake_minimum_required (VERSION 3.10.2)

    # Set project name
    project (Urho3D-ExternalProject-tolua++)

    # Set CMake modules search path
    set (CMAKE_MODULE_PATH ${URHO3D_CMAKE_MODULE})

    # Include UrhoCommon.cmake module after setting project name
    include (UrhoCommon)

    # When performing Xcode CI build suppress all the warnings for 3rd party libraries because there are just too many of them
    if (XCODE AND DEFINED ENV{CI})
        set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w")
    endif ()

    # Add dependency targets
    add_subdirectory (${BAKED_CMAKE_SOURCE_DIR}/Source/ThirdParty/Lua host/Lua)
    add_subdirectory (${BAKED_CMAKE_SOURCE_DIR}/Source/ThirdParty/toluapp/src/lib host/toluapp)
endif ()

# Define target name
set (TARGET_NAME tolua++)

# Define generated source files
if (URHO3D_UPDATE_SOURCE_TREE)
    set (UPDATE_COMMAND COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/generated/toluabind.c ${CMAKE_CURRENT_SOURCE_DIR}/toluabind.c)
endif ()
file (GLOB TOLUA lua/*.lua)
add_custom_command (OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/generated/toluabind.c
    COMMAND ${URHO3D_BUILD_DIR}/bin/tool/tolua++ -o ${CMAKE_CURRENT_BINARY_DIR}/generated/toluabind.c -H ${CMAKE_CURRENT_BINARY_DIR}/generated/toluabind.h -n tolua tolua_scons.pkg 2>${NULL_DEVICE} || ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_SOURCE_DIR}/toluabind.c ${CMAKE_CURRENT_BINARY_DIR}/generated/toluabind.c
    ${UPDATE_COMMAND}
    DEPENDS ${TOLUA} tolua_scons.pkg
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generating toluabind.c and toluabind.h. Warning: tolua++ is built using the original toluabind.c. To use the newly generated one, build once with URHO3D_UPDATE_SOURCE_TREE=1 to update toluabind.c and then rebuild a second time to build tolua++ using it.")

# Define source files. Will use the old toluabind.c even with URHO3D_UPDATE_SOURCE_TREE, so we must either build tolua++ twice or have the user run the build twice.
define_source_files (EXTRA_CPP_FILES tolua.c toluabind.c)

# Define dependency libs
set (LIBS toluapp Lua)
if (NOT MSVC)
    list (APPEND LIBS m)
endif ()
set (INCLUDE_DIRS ../../include ../../../../ThirdParty/Lua/src)

# Setup target
setup_executable (TOOL NODEPS)
if (TARGET Lua)
    add_dependencies (${TARGET_NAME} Lua)
endif ()

# Wrapper target for tolua++ executable to be used externally.
add_custom_target (tolua++bin DEPENDS tolua++ ${CMAKE_CURRENT_BINARY_DIR}/generated/toluabind.c)

