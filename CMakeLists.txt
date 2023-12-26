cmake_minimum_required(VERSION 3.20)

set(PROJECT_NAME "LollipopConnect")
project(${PROJECT_NAME} VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)

# check arch
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(BUILD_CPU_ARCH x64)
else()
    set(BUILD_CPU_ARCH x86)
endif()
message(STATUS "[${PROJECT_NAME}] BUILD_CPU_ARCH:${BUILD_CPU_ARCH}")

set(PROJECT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

#这里在Clion中需要配置
set(CMAKE_PREFIX_PATH "C:/App/Qt/Qt6/6.4.3/msvc2019_64")
#set(Qt_DIR "C:/App/Qt/Qt6/6.4.3/msvc2019_64/lib/cmake")


#导入Qt相关依赖包
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Gui Widgets Multimedia Quick Svg Network )
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Widgets Multimedia Quick Svg Network )

#check version，上面的find_package必须酱紫写，且必须写成一行，不然${QT_VERSION}无法识别
message(STATUS "[${PROJECT_NAME}] Qt version: ${QT_VERSION}   QT_VERSION_MAJOR: ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}")


#include_directories(${PROJECT_SOURCE_DIR}/include)
#link_directories(${PROJECT_SOURCE_DIR}/libs)
#include_directories(${PROJECT_SOURCE_DIR}/language)
#link_directories(${PROJECT_SOURCE_DIR}/res)

set(UTIL_SOURCE
    src/log/Log.h
    src/log/Log.cpp
    src/util/singleton.h
    src/util/SettingsHelper.h
    src/util/SettingsHelper.cpp
)
source_group(util FILES ${UTIL_SOURCE})

set(COMPONENT_SOURCE
    src/component/CircularReveal.cpp
    src/component/CircularReveal.h
    src/component/FileWatcher.cpp
    src/component/FileWatcher.h
    src/component/FpsItem.cpp
    src/component/FpsItem.h
        src/component/stdafx.h
)
source_group(component FILES ${COMPONENT_SOURCE})

# all sources
set(QC_PROJECT_SOURCES
    src/main.cpp
    ${UTIL_SOURCE}
    ${COMPONENT_SOURCE}
)

qt_add_executable(${PROJECT_NAME} ${QC_PROJECT_SOURCES})


if(QT_VERSION VERSION_GREATER_EQUAL "6.2")
    #遍历所有qml文件
    file(GLOB_RECURSE QML_PATHS "qml/*.qml")
    foreach(filepath ${QML_PATHS})
        message("add qml file: " ${filepath})
        string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath}) #.+/(.+)\\\\..*" "\\\\1
        list(APPEND qml_files ${filename})
    endforeach(filepath)
    list(REMOVE_DUPLICATES qml_files) #表示删除非第一个重名值


    #遍历所有资源文件
    #file(GLOB_RECURSE RES_PATHS *.png *.jpg *.svg *.ico *.ttf *.webp *.obj)
    file(GLOB_RECURSE RES_PATHS *.png *.jpg *.svg)
    foreach(filepath ${RES_PATHS})
        message("add res file: " ${filepath})
        string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
        list(APPEND resource_files ${filename})
    endforeach(filepath)

    #如果是Qt6.2以上，则使用qt_add_qml_module添加资源文件
    #如果是Qt6.2以下，则使用qrc添加资源文件
    qt_add_qml_module(${PROJECT_NAME}
        URI "lconnect"
        VERSION 1.0
        QML_FILES ${qml_files}
        RESOURCES ${resource_files}
        RESOURCE_PREFIX "/"
    )

    #OpenGL Shader代码
    file(GLOB_RECURSE GLSL_PATHS "res/shader/*.glsl")
    foreach(filepath ${GLSL_PATHS})
        message("add glsl file: " ${filepath})
        string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
        list(APPEND shaders_files ${filename})
    endforeach(filepath)

    qt6_add_resources(${PROJECT_NAME} "shaders"
            PREFIX "/"
            FILES ${shaders_files}
    )





else()
    message(${PROJECT_NAME} "  add resource error!! qt version must >= 6.2")
endif()


#
# fluent_ui
#
if(QT_VERSION VERSION_GREATER_EQUAL "6.2")
    # windows
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        # 这里以动态库的方式引入
        set(FluentUI_LibPath "${CMAKE_CURRENT_SOURCE_DIR}/third_party/FluentUI/windows")
        #set(FluentUI_LibPath "C:/App/Qt/Qt6/6.4.3/msvc2019_64/qml/FluentUI")
        target_link_directories(${PROJECT_NAME} PUBLIC ${FluentUI_LibPath})
        message("FluentUI lib: " ${FluentUI_LibPath})
        #debug模式：fluentuiplugind   release模式：fluentuiplugin
        target_link_libraries(${PROJECT_NAME} PRIVATE fluentuiplugind)
    endif()

    # MacOS
    if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    endif()

    # Linux
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    endif()

endif()


#
# plantform deps
#

# windows
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    # ffmpeg
    # include
    set(FFMPEG_INCLUDE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/third_party/ffmpeg-6.1-msvc-build-share/${BUILD_CPU_ARCH}/include")
    target_include_directories(${PROJECT_NAME} PRIVATE ${FFMPEG_INCLUDE_PATH})

    # link
    set(FFMPEG_LIB_PATH "${CMAKE_CURRENT_SOURCE_DIR}/third_party/ffmpeg-6.1-msvc-build-share/${BUILD_CPU_ARCH}/bin")
    target_link_directories(${PROJECT_NAME} PUBLIC ${FFMPEG_LIB_PATH})

    message("ffmpeg lib path: " ${FFMPEG_LIB_PATH})

    target_link_libraries(${PROJECT_NAME} PRIVATE
        avcodec
        avdevice
        avfilter
        avformat
        avutil
        postproc
        swresample
        swscale
    )

    # copy
#    set(THIRD_PARTY_PATH "${CMAKE_CURRENT_SOURCE_DIR}/third_party")
#    set(FFMPEG_BIN_PATH "${THIRD_PARTY_PATH}/ffmpeg-6.1-msvc-build-share/${BUILD_CPU_ARCH}/bin")
#    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${FFMPEG_BIN_PATH}/avcodec-60.dll" "${QSC_DEPLOY_PATH}"
#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${FFMPEG_BIN_PATH}/avdevice-60.dll" "${QSC_DEPLOY_PATH}"
#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${FFMPEG_BIN_PATH}/avfilter-9.dll" "${QSC_DEPLOY_PATH}"
#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${FFMPEG_BIN_PATH}/avformat-60.dll" "${QSC_DEPLOY_PATH}"
#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${FFMPEG_BIN_PATH}/avutil-58.dll" "${QSC_DEPLOY_PATH}"
#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${FFMPEG_BIN_PATH}/postproc-57.dll" "${QSC_DEPLOY_PATH}"
#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${FFMPEG_BIN_PATH}/swresample-4.dll" "${QSC_DEPLOY_PATH}"
#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${FFMPEG_BIN_PATH}/swscale-7.dll" "${QSC_DEPLOY_PATH}"

#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${THIRD_PARTY_PATH}/adb/win/adb.exe" "${QSC_DEPLOY_PATH}"
#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${THIRD_PARTY_PATH}/adb/win/AdbWinApi.dll" "${QSC_DEPLOY_PATH}"
#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${THIRD_PARTY_PATH}/adb/win/AdbWinUsbApi.dll" "${QSC_DEPLOY_PATH}"

#        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${THIRD_PARTY_PATH}/scrcpy-server" "${QSC_DEPLOY_PATH}"
#    )

endif()


#set_target_properties(${PROJECT_NAME} PROPERTIES
#        MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
#        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
#        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
#        MACOSX_BUNDLE TRUE
#        WIN32_EXECUTABLE TRUE
#)


target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Svg
    Qt${QT_VERSION_MAJOR}::Network
)

install(TARGETS ${PROJECT_NAME}
        BUNDLE DESTINATION .
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

