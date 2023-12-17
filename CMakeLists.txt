cmake_minimum_required(VERSION 3.16)
project(LConnect VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 20)

set(CMAKE_PREFIX_PATH "C:/App/Qt/Qt6/6.4.3/mingw_64/bin")

find_package(Qt6 6.2 COMPONENTS
        Core
        Gui
        Quick
        REQUIRED)

include_directories(${PROJECT_SOURCE_DIR}/include)
link_directories(${PROJECT_SOURCE_DIR}/libs)
#include_directories(${PROJECT_SOURCE_DIR}/language)
#link_directories(${PROJECT_SOURCE_DIR}/res)

qt_add_executable(LConnect
        main.cpp
        )

########    获取 qml 文件    ########
file(GLOB_RECURSE QML_PATHS *.qml)
#file(GLOB QML_PATHS qml/*.qml)

foreach(filepath ${QML_PATHS})
    message(${filepath} "\\t" ${CMAKE_CURRENT_SOURCE_DIR})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath}) #.+/(.+)\\\\..*" "\\\\1
    list(APPEND QML_FILES ${filename})
endforeach(filepath)
list(REMOVE_DUPLICATES QML_FILES) #表示删除非第一个重名值

qt_add_qml_module(LConnect
        URI player
        VERSION 1.0
        QML_FILES
        ${QML_FILES}
        )


set_target_properties(LConnect PROPERTIES
        MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        MACOSX_BUNDLE TRUE
        WIN32_EXECUTABLE TRUE
        )

target_link_libraries(LConnect
        PRIVATE
        Qt::Core
        Qt::Gui
        Qt::Quick)

install(TARGETS LConnect
        BUNDLE DESTINATION .
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

