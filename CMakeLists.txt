# Set the minimum version of CMake required
cmake_minimum_required(VERSION 3.10)

# Project name and version
project(WindowSwitchRemap VERSION 1.0)

# Create the executable from the source files
add_executable(${PROJECT_NAME} main.m)

# Link the necessary frameworks for macOS
find_library(Quartz_FRAMEWORK Quartz REQUIRED)
find_library(COCOA_FRAMEWORK Cocoa REQUIRED)

# Link the Quartz framework and set target properties
target_link_libraries(${PROJECT_NAME} PRIVATE
    ${Quartz_FRAMEWORK}
    ${COCOA_FRAMEWORK}
    "-framework ApplicationServices"
)

# Set macOS-specific properties
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE YES
    MACOSX_BUNDLE_INFO_PLIST_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
    MACOSX_BUNDLE_ICON_FILE WindowSwitchRemap.icns
)

file (COPY ${CMAKE_CURRENT_SOURCE_DIR}/WindowSwitchRemap.icns DESTINATION ${CMAKE_BINARY_DIR}/WindowSwitchRemap.app/Contents/Resources/)

# Set the output directory for the executable
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Enable the building of a .app bundle (optional)
set(CMAKE_OSX_ARCHITECTURES x86_64;arm64)
