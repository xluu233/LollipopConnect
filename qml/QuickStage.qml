import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import FluentUI
import lcomponent

FluWindow{
    id:window
    title: "FluentUI"
    width: 960
    height: 600
    minimumWidth: 520
    minimumHeight: 200
    launchMode: FluWindowType.SingleTask
    fitsAppBarWindows: true
    appBar: FluAppBar {
        height: 30
        darkText: Lang.dark_mode
        showDark: true
        darkClickListener:(button)=>handleDarkChanged(button)
        closeClickListener: ()=>{dialog_close.open()}
        z:7
    }

    FluContentDialog{
        id:dialog_close
        title:"退出"
        message:"确定要退出程序吗？"
        positiveText:"退出"
        neutralText:"取消"
        buttonFlags: FluContentDialogType.NeutralButton | FluContentDialogType.PositiveButton
        onPositiveClicked:{
            FluApp.exit(0)
        }
    }

    SystemTrayIcon {
        id:system_tray
        visible: true
        icon.source: "qrc:/example/res/image/favicon.ico"
        tooltip: "FluentUI"
        menu: Menu {
            MenuItem {
                text: "退出"
                onTriggered: {
                    FluApp.exit()
                }
            }
        }
        onActivated: (reason)=>{
            if(reason === SystemTrayIcon.Trigger){
                window.show()
                window.raise()
                window.requestActivate()
            }
        }
    }

    Timer{
        id:timer_window_hide_delay
        interval: 150
        onTriggered: {
            window.hide()
        }
    }

    function handleDarkChanged(button){
        if(!FluTheme.enableAnimation || window.fitsAppBarWindows === false){
            changeDark()
        }else{
            if(loader_reveal.sourceComponent){
                return
            }
            loader_reveal.sourceComponent = com_reveal
            var target = window.layoutContainer()
            var pos = button.mapToItem(target,0,0)
            var mouseX = pos.x
            var mouseY = pos.y
            var radius = Math.max(distance(mouseX,mouseY,0,0),distance(mouseX,mouseY,target.width,0),distance(mouseX,mouseY,0,target.height),distance(mouseX,mouseY,target.width,target.height))
            var reveal = loader_reveal.item
            reveal.start(reveal.width*Screen.devicePixelRatio,reveal.height*Screen.devicePixelRatio,Qt.point(mouseX,mouseY),radius)
        }
    }

    function changeDark(){
        if(FluTheme.dark){
            FluTheme.darkMode = FluThemeType.Light
        }else{
            FluTheme.darkMode = FluThemeType.Dark
        }
    }

    function distance(x1,y1,x2,y2){
        return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
    }

    FluLoader{
        id:loader_reveal
        anchors.fill: parent
    }

    Component{
        id:com_reveal
        CircularReveal{
            id:reveal
            target:window.layoutContainer()
            anchors.fill: parent
            onAnimationFinished:{
                //动画结束后释放资源
                loader_reveal.sourceComponent = undefined
            }
            onImageChanged: {
                changeDark()
            }
        }
    }

}