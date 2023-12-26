import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

Item {
    id: app

    // Connections{
    //     target: FluTheme
    //     function onDarkModeChanged(){
    //         SettingsHelper.saveDarkMode(FluTheme.darkMode)
    //     }
    // }
    //
    // Connections{
    //     target: FluApp
    //     function onUseSystemAppBarChanged(){
    //         SettingsHelper.saveUseSystemAppBar(FluApp.useSystemAppBar)
    //     }
    // }


    Component.onCompleted: {
        FluApp.init(app)
        FluApp.windowIcon = "qrc:/lconnect/res/image/favicon.ico"
        // FluApp.useSystemAppBar = SettingsHelper.getUseSystemAppBar()
        // FluTheme.darkMode = SettingsHelper.getDarkMode()
        FluApp.useSystemAppBar = false
        FluTheme.darkMode = false
        FluTheme.enableAnimation = true
        FluApp.routes = {
            "/":"qrc:/lconnect/qml/QuickStage.qml",
            "/file":"qrc:/lconnect/qml/FileControlStage.qml",
            "/setting":"qrc:/lconnect/qml/SettingStage.qml",
            "/about":"qrc:/lconnect/qml/AboutMe.qml",
        }
        FluApp.initialRoute = "/"
        FluApp.run()
    }

}
