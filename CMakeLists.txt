cmake_minimum_required(VERSION 3.16)

project(dji_psdk_vendor LANGUAGES C CXX)

add_definitions(-D_GNU_SOURCE)

## Compile as C++11, supported in ROS Kinetic and newer
# add_compile_options(-std=c++11)

find_package(ament_cmake REQUIRED)
find_package(PkgConfig REQUIRED)

set(PSDK_PLATFORM "" CACHE STRING "Target platform: raspberry_pi or nvidia_jetson")
if (NOT PSDK_PLATFORM AND DEFINED ENV{CI})
    set(PSDK_PLATFORM "raspberry_pi")
    set(PSDK_PLATFORM_DIR "raspberry_pi")
    message(STATUS "CI detected: defaulting PSDK_PLATFORM to raspberry_pi")
elseif (NOT PSDK_PLATFORM)
    message(FATAL_ERROR "PSDK_PLATFORM is not set. Please set it to your target platform (e.g., nvidia_jetson, raspberry_pi).")
elseif(PSDK_PLATFORM STREQUAL "nvidia_jetson")
    set(PSDK_PLATFORM_DIR "nvidia_jetson")
elseif(PSDK_PLATFORM STREQUAL "raspberry_pi")
    set(PSDK_PLATFORM_DIR "raspberry_pi")
    message(STATUS "C++ PSDK platform not available on Raspberry Pi; psdk_vendor_cpp will not be built")
else()
    message(FATAL_ERROR "Unsupported PSDK_PLATFORM: ${PSDK_PLATFORM}. Supported platforms are 'nvidia_jetson' and 'raspberry_pi'.")
endif()

# C source directories
set(PSDK_CORE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/psdk_lib/include")
set(PSDK_C_MODULES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/samples/sample_c/module_sample")
set(PSDK_C_COMMON_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/samples/sample_c/platform/linux/common")
set(PSDK_C_HAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/hal")
set(PSDK_C_APP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/application")

# C source files
file(GLOB_RECURSE PSDK_C_MODULES_SOURCES
    CONFIGURE_DEPENDS
    # "${PSDK_C_MODULES_DIR}/utils/*.c"
    "${PSDK_C_MODULES_DIR}/*.c"
)
file(GLOB_RECURSE PSDK_C_COMMON_SOURCES
    CONFIGURE_DEPENDS
    "${PSDK_C_COMMON_DIR}/*.c"
)
file(GLOB_RECURSE PSDK_C_HAL_SOURCES
    CONFIGURE_DEPENDS
    "${PSDK_C_HAL_DIR}/*.c"
)
file(GLOB_RECURSE PSDK_C_APP_SOURCES
    CONFIGURE_DEPENDS
    "${PSDK_C_APP_DIR}/*.c"
)

# C++ source directories
# set(PSDK_CPP_MODULES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/samples/sample_c++/module_sample")
# set(PSDK_CPP_COMMON_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/samples/sample_c++/platform/linux/common")
# set(PSDK_CPP_HAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/samples/sample_c++/platform/linux/${PSDK_PLATFORM_DIR}/hal")
# set(PSDK_CPP_APP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/samples/sample_c++/platform/linux/${PSDK_PLATFORM_DIR}/application")

# C++ source files
# if (PSDK_PLATFORM STREQUAL "nvidia_jetson")
#     file(GLOB_RECURSE PSDK_CPP_MODULES_SOURCES
#         "${PSDK_CPP_MODULES_DIR}/utils/*.c"
#         "${PSDK_CPP_MODULES_DIR}/utils/*.cpp"
#     )
#     file(GLOB_RECURSE PSDK_CPP_COMMON_SOURCES
#         "${PSDK_CPP_COMMON_DIR}/*.c"
#         "${PSDK_CPP_COMMON_DIR}/*.cpp"
#     )
#     file(GLOB_RECURSE PSDK_CPP_HAL_SOURCES
#         "${PSDK_CPP_HAL_DIR}/*.c"
#         "${PSDK_CPP_HAL_DIR}/*.cpp"
#     )
#     file(GLOB_RECURSE PSDK_CPP_APP_SOURCES
#         "${PSDK_CPP_APP_DIR}/*.c"
#         "${PSDK_CPP_APP_DIR}/*.cpp"
#     )
# endif()

# Create static libraries
add_library(psdk_vendor_c STATIC
    ${PSDK_C_MODULES_SOURCES}
    ${PSDK_C_COMMON_SOURCES}
    ${PSDK_C_HAL_SOURCES}
    ${PSDK_C_APP_SOURCES}
)

# if (PSDK_PLATFORM STREQUAL "nvidia_jetson")
#     add_library(psdk_vendor_cpp STATIC
#         ${PSDK_CPP_MODULES_SOURCES}
#         ${PSDK_CPP_COMMON_SOURCES}
#         ${PSDK_CPP_HAL_SOURCES}
#         ${PSDK_CPP_APP_SOURCES}
#     )
#     # add_dependencies(psdk_vendor_cpp ${catkin_EXPORTED_TARGETS})
# endif()

# Include directories
# Include directories
target_include_directories(psdk_vendor_c
    PRIVATE
        ${PSDK_C_MODULES_DIR}
        ${PSDK_C_APP_DIR}

    PUBLIC
        # Build interface
        $<BUILD_INTERFACE:${PSDK_CORE_DIR}>
        $<BUILD_INTERFACE:${PSDK_C_COMMON_DIR}>
        $<BUILD_INTERFACE:${PSDK_C_HAL_DIR}>
        $<BUILD_INTERFACE:${PSDK_C_APP_DIR}>
        $<BUILD_INTERFACE:${PSDK_C_MODULES_DIR}>

        # Install interface
        $<INSTALL_INTERFACE:include/${PROJECT_NAME}/Payload-SDK/psdk_lib/include>
        $<INSTALL_INTERFACE:include/${PROJECT_NAME}/Payload-SDK/samples/sample_c/platform/linux/common>
        $<INSTALL_INTERFACE:include/${PROJECT_NAME}/Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/hal>
        $<INSTALL_INTERFACE:include/${PROJECT_NAME}/Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/application>
        $<INSTALL_INTERFACE:include/${PROJECT_NAME}/Payload-SDK/samples/sample_c/module_sample>
)

# TODO update this for ros2
# if (PSDK_PLATFORM STREQUAL "nvidia_jetson")
#     target_include_directories(psdk_vendor_cpp
#         PRIVATE
#             ${PSDK_CPP_MODULES_DIR}
#             ${PSDK_CPP_APP_DIR}
#         PUBLIC
#             ${PSDK_CORE_DIR}
#             ${PSDK_CPP_COMMON_DIR}
#             ${PSDK_CPP_HAL_DIR}
#     )
# endif()
#end TODO

# Imported libraries
if (CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
    set(PSDK_CORE_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/psdk_lib/lib/aarch64-linux-gnu-gcc")
elseif (CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    set(PSDK_CORE_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Payload-SDK/psdk_lib/lib/x86_64-linux-gnu-gcc")
else()
    message(FATAL_ERROR "Unsupported architecture: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

if (CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
  target_compile_definitions(psdk_vendor_c PUBLIC SYSTEM_ARCH_LINUX PLATFORM_ARCH_aarch64=1)
elseif (CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
  target_compile_definitions(psdk_vendor_c PUBLIC SYSTEM_ARCH_LINUX PLATFORM_ARCH_x86_64=1)
endif()

if (NOT EXISTS ${PSDK_CORE_LIB_DIR}/libpayloadsdk.a)
    message(FATAL_ERROR
        "DJI Payload SDK core library not found at: ${PSDK_CORE_LIB_DIR}/libpayloadsdk.a\n"
    )
endif()

add_library(payloadsdk STATIC IMPORTED)
set_target_properties(payloadsdk PROPERTIES
    IMPORTED_LOCATION "${PSDK_CORE_LIB_DIR}/libpayloadsdk.a"
)
set(PSDK_PAYLOADSDK_PATH
  "${PSDK_CORE_LIB_DIR}/libpayloadsdk.a"
  CACHE INTERNAL "DJI Payload SDK static library"
)
set_target_properties(psdk_vendor_c PROPERTIES
  C_STANDARD 99
  C_STANDARD_REQUIRED YES
)
target_compile_options(psdk_vendor_c PUBLIC -pthread)


# if (PSDK_PLATFORM STREQUAL "nvidia_jetson")
#     target_link_libraries(psdk_vendor_cpp
#         PUBLIC
#             pthread
#             m
#             usb-1.0
#     )
# endif()

pkg_check_modules(FFMPEG REQUIRED
    libavcodec
    libavformat
    libavutil
    libswscale
)

# find_package(FFMPEG REQUIRED)
message(STATUS "Found FFMPEG installed in the system")
message(STATUS " - Includes: ${FFMPEG_INCLUDE_DIRS}")
message(STATUS " - Libraries: ${FFMPEG_LIBRARIES}")

execute_process(
    COMMAND ffmpeg -version
    OUTPUT_VARIABLE FFMPEG_VERSION_RAW
)

# Extract major version, allowing for 'n4.x.x' or '4.x.x'
string(REGEX MATCH "ffmpeg version[ \t]+n?([0-9]+)" _ "${FFMPEG_VERSION_RAW}")

if (NOT CMAKE_MATCH_1)
    message(FATAL_ERROR
        "Failed to parse ffmpeg version from:\n${FFMPEG_VERSION_RAW}"
    )
endif()

set(FFMPEG_MAJOR_VERSION "${CMAKE_MATCH_1}")

if (FFMPEG_MAJOR_VERSION LESS 3)
    message(FATAL_ERROR
        "Unsupported FFMPEG version: ${FFMPEG_MAJOR_VERSION}.x — need at least 3.x"
    )
else()
    message(WARNING " - FFMPEG version: ${FFMPEG_MAJOR_VERSION}.x accepted on Melodic/Bionic")
endif()

target_link_libraries(psdk_vendor_c PUBLIC ${FFMPEG_LIBRARIES})
target_include_directories(psdk_vendor_c PUBLIC ${FFMPEG_INCLUDE_DIRS})
target_compile_definitions(psdk_vendor_c PUBLIC FFMPEG_INSTALLED)
# if (PSDK_PLATFORM STREQUAL "nvidia_jetson")
#     target_link_libraries(psdk_vendor_cpp PUBLIC ${FFMPEG_LIBRARIES})
#     target_include_directories(psdk_vendor_cpp PUBLIC ${FFMPEG_INCLUDE_DIRS})
#     target_compile_definitions(psdk_vendor_cpp PUBLIC FFMPEG_INSTALLED)
# endif ()

pkg_check_modules(OPUS REQUIRED opus)
message(STATUS "Found OPUS installed in the system")
message(STATUS " - Includes: ${OPUS_INCLUDE_DIRS}")
message(STATUS " - Libraries: ${OPUS_LIBRARIES}")

target_link_libraries(psdk_vendor_c PUBLIC ${OPUS_LIBRARIES})
target_include_directories(psdk_vendor_c PUBLIC ${OPUS_INCLUDE_DIRS})
target_compile_definitions(psdk_vendor_c PUBLIC OPUS_INSTALLED)
# if (PSDK_PLATFORM STREQUAL "nvidia_jetson")
#     target_link_libraries(psdk_vendor_cpp PUBLIC ${OPUS_LIBRARIES})
#     target_include_directories(psdk_vendor_cpp PUBLIC ${OPUS_INCLUDE_DIRS})
#     target_compile_definitions(psdk_vendor_cpp PUBLIC OPUS_INSTALLED)
# endif ()

pkg_check_modules(LIBUSB REQUIRED libusb-1.0)
message(STATUS "Found LIBUSB installed in the system")
message(STATUS " - Includes: ${LIBUSB_INCLUDE_DIRS}")
message(STATUS " - Libraries: ${LIBUSB_LIBRARIES}")

target_link_libraries(psdk_vendor_c PUBLIC ${LIBUSB_LIBRARIES})
target_include_directories(psdk_vendor_c PUBLIC ${LIBUSB_INCLUDE_DIRS})
target_compile_definitions(psdk_vendor_c PUBLIC LIBUSB_INSTALLED)
# if (PSDK_PLATFORM STREQUAL "nvidia_jetson")
#     target_link_libraries(psdk_vendor_cpp PUBLIC ${LIBUSB_LIBRARIES})
#     target_include_directories(psdk_vendor_cpp PUBLIC ${LIBUSB_INCLUDE_DIRS})   
#     target_compile_definitions(psdk_vendor_cpp PUBLIC LIBUSB_INSTALLED)
# endif ()

# set(DJI_EXPORT_INCLUDE_DIRS
#   Payload-SDK/psdk_lib/include
#   Payload-SDK/samples/sample_c/platform/linux/common
#   Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/hal
#   Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/application
#   Payload-SDK/samples/sample_c/module_sample
# )


# Link system libraries
target_link_libraries(psdk_vendor_c
    PUBLIC
        payloadsdk
        pthread
        m
        dl
        usb-1.0
)

# # Catkin package
# catkin_package(
#     INCLUDE_DIRS ${DJI_EXPORT_INCLUDE_DIRS}
#     LIBRARIES 
#         psdk_vendor_c
#         payloadsdk
#         dl
#         pthread
#         m
#         ${LIBUSB_LIBRARIES}
#         ${FFMPEG_LIBRARIES}
#         ${OPUS_LIBRARIES}
# )

# Install static libraries
# if (PSDK_PLATFORM STREQUAL "nvidia_jetson")
#     install(TARGETS
#         psdk_vendor_c
#         psdk_vendor_cpp
#         ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
#     )
# else()
#     install(TARGETS
#         psdk_vendor_c
#         ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
#     )
# endif()

install(
    TARGETS psdk_vendor_c
    EXPORT export_${PROJECT_NAME}

    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install include files
# file(GLOB_RECURSE DJI_ALL_HEADERS
#     Payload-SDK/psdk_lib/include/*.h
#     Payload-SDK/samples/sample_c/platform/linux/common/**/*.h
#     Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/hal/*.h
# )

# # headers -> include
# install(FILES ${DJI_ALL_HEADERS}
#   DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
# )

install(
    DIRECTORY Payload-SDK/psdk_lib/include/
    DESTINATION include/${PROJECT_NAME}/Payload-SDK/psdk_lib/include
)

install(DIRECTORY Payload-SDK/samples/sample_c/platform/linux/common/
  DESTINATION include/${PROJECT_NAME}/Payload-SDK/samples/sample_c/platform/linux/common
)

install(
    DIRECTORY Payload-SDK/samples/sample_c/module_sample/
    DESTINATION include/${PROJECT_NAME}/Payload-SDK/samples/sample_c/module_sample
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
)

install(DIRECTORY Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/hal/
  DESTINATION include/${PROJECT_NAME}/Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/hal
)

install(DIRECTORY Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/application/
  DESTINATION include/${PROJECT_NAME}/Payload-SDK/samples/sample_c/platform/linux/${PSDK_PLATFORM_DIR}/application
)

# DJI core archive -> lib
install(
    FILES "${PSDK_CORE_LIB_DIR}/libpayloadsdk.a"
    DESTINATION lib
)


ament_export_targets(
    export_${PROJECT_NAME}
    HAS_LIBRARY_TARGET
)

ament_package(
    CONFIG_EXTRAS cmake/dji_psdk_vendor-extras.cmake
)