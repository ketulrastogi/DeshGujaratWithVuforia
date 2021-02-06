# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

project(VuforiaSample)

# Setup properties used below
set(VUFORIA_ENGINE ${CMAKE_CURRENT_LIST_DIR}/../../../../../../..)

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library(ANDROID_LIBRARY android)
find_library(GLES3_LIBRARY GLESv3)
find_library(LOG_LIBRARY log)

# Locate the Vuforia Engine library
add_library(VUFORIA_LIBRARY SHARED IMPORTED)
set_property(TARGET VUFORIA_LIBRARY PROPERTY IMPORTED_LOCATION
        ${VUFORIA_ENGINE}/build/lib/${ANDROID_ABI}/libVuforia.so)

# Configure building the app library
add_library(
    VuforiaSample
    SHARED

    # Cross platform source
    ../../../../../CrossPlatform/AppController.cpp
    ../../../../../CrossPlatform/MathUtils.cpp
    ../../../../../CrossPlatform/tiny_obj_loader.cpp

    # Android native sources
    GLESRenderer.cpp
    GLESUtils.cpp
    VuforiaWrapper.cpp
    )

target_include_directories(
    VuforiaSample
    PUBLIC

    ../../../../../CrossPlatform
    ${VUFORIA_ENGINE}/build/include
    ${GLES2_INCLUDE_DIR}
    )

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries(
    VuforiaSample

    ${ANDROID_LIBRARY}
    ${LOG_LIBRARY}
    ${GLES3_LIBRARY}
    VUFORIA_LIBRARY
    )
