import QtQuick
import FluentUI

Window {
    height: 480
    title: qsTr("Hello World")
    visible: true
    width: 640

    Text {
        id: name
        text: qsTr("Hello")
    }

    FluButton{
        id:flu_btn
        text: "hahha"
        width:200
        height:200
        onClicked:
        {
            console.log("123")
        }
    }
}
