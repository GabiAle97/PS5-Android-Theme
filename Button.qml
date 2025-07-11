import QtQuick 2.12
import QtGraphicalEffects 1.12

Item {
    id: root

    property bool isSelected
    property string icon: ""
    property alias text: buttonText.text
    property string hlColor: "white"

    height: vpx(50)

    signal activated

    TapHandler {
        acceptedDevices: PointerDevice.TouchScreen | PointerDevice.Mouse
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: {
            activated()
        }
    }
    
    ItemOutline {
        id: outline 
        anchors.fill: container
        radius: height / 2
        show: isSelected
    }

    Rectangle {
        id: container
        width: parent.width
        height: vpx(50)
        radius: height / 2
        opacity: isSelected ? 1 : 0.05
        color: isSelected ? hlColor : "white"
    }

    Text {
        id: buttonText
        text: "Play"
        font.pixelSize: vpx(18)
        font.family: bodyFont.name
        font.bold: true
        color: isSelected ? "black" : hlColor
        anchors.fill: container
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: icon == ""
    }

    Image {
        id: iconImage
        source: icon
        sourceSize: Qt.size(parent.width, parent.height)
        anchors.fill: container
        anchors.margins: vpx(17)
        asynchronous: true
        visible: false
    }

    ColorOverlay {
        anchors.fill: iconImage
        source: iconImage
        color: isSelected ? "black" : hlColor
        visible: icon != ""
    }
}
