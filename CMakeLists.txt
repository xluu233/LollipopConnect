cmake_minimum_required(VERSION 3.20)

set(PROJECT_NAME "LConnect")
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


#导入Qt相关依赖包
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Gui Widgets Multimedia Quick Svg Network )
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Widgets Multimedia Quick Svg Network )

#check version，上面的find_package必须酱紫写，且必须写成一行，不然${QT_VERSION}无法识别
message(STATUS "[${PROJECT_NAME}] Qt version: ${QT_VERSION}   QT_VERSION_MAJOR: ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}")


#include_directories(${PROJECT_SOURCE_DIR}/include)
#link_directories(${PROJECT_SOURCE_DIR}/libs)
#include_directories(${PROJECT_SOURCE_DIR}/language)
#link_directories(${PROJECT_SOURCE_DIR}/res)

qt_add_executable(${PROJECT_NAME}
        src/main.cpp
)


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


set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        MACOSX_BUNDLE TRUE
        WIN32_EXECUTABLE TRUE
)


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

