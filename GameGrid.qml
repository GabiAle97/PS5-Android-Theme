import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtMultimedia 5.9
import "Lists"
import "utils.js" as Utils

FocusScope {
id: root

    property alias menu: gamegrid
    property alias intro: introAnim
    property var currentState
    property int numColumns : 4

    signal exit

    // Pull in our custom lists and define
    ListAllGames    { id: listNone;        max: 0 }
    ListAllGames    { id: listAllGames; }
    ListFavorites   { id: listFavorites; }
    ListLastPlayed  { id: listLastPlayed; }
    ListTopGames    { id: listTopGames; }

    property var currentList: {
        switch (currentState) {
            case "allgames":
                return listAllGames;
                break;
            case "topgames": 
                return listTopGames;
                break;
            default:
                return listAllGames;
        }
    }

    visible: false
    onVisibleChanged: {
        if (visible) {
            gamegrid.opacity = 0;
            introAnim.restart();
        }
    }

    SequentialAnimation {
    id: introAnim

        running: true
        NumberAnimation { target: gamegrid; property: "opacity"; to: 0; duration: 100 }
        PauseAnimation  { duration: 400 }
        ParallelAnimation {
            NumberAnimation { target: gamegrid; property: "opacity"; from: 0; to: 1; duration: 400;
                easing.type: Easing.OutCubic;
                easing.amplitude: 2.0;
                easing.period: 1.5 
            }
            NumberAnimation { target: gamegrid; property: "y"; from: 50; to: 0; duration: 400;
                easing.type: Easing.OutCubic;
                easing.amplitude: 2.0;
                easing.period: 1.5 
            }
        }
    }

    Component {
    id: gridHeader 

        Item {
            height: vpx(100)
        }
    }

    GridView {
    id: gamegrid

        width: parent.width;
        height: parent.height;

        anchors {
            left: parent.left; leftMargin: vpx(125)
            right: parent.right; rightMargin: vpx(125)
        }

        focus: true
        cellWidth: width / numColumns
        cellHeight: vpx(250)

        preferredHighlightBegin: vpx(100)
        preferredHighlightEnd: parent.height
        highlightRangeMode: ListView.ApplyRange
        header: gridHeader
        model: currentList.games
        delegate: boxartDelegate

        Component {
        id: boxartDelegate

            GridItem {
            id: delegatecontainer

                selected:   GridView.isCurrentItem && root.focus
                gameData:   modelData
                width:      GridView.view.cellWidth
                height:     GridView.view.cellHeight
                radius:     vpx(2)

                TapHandler {
                    onTapped: {                    
                        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                            event.accepted = true;
                            sfxBack.play();
                            exit();
                        }

                        if (api.keys.isDetails(event) && !event.isAutoRepeat) {
                            event.accepted = true;
                            sfxToggle.play();
                            modelData.favorite = !modelData.favorite;
                        }
                    }
                }
            }
        }

        property int col: currentIndex % 4;

        // GESTOS EN VEZ DE TECLAS
        MultiPointTouchArea {
            anchors.fill: parent
            minimumTouchPoints: 1
            maximumTouchPoints: 1

            property real startX
            property real startY
            property bool handled: false

            onPressed: (touchPoints) => {
                if (touchPoints.length === 1) {
                    startX = touchPoints[0].x;
                    startY = touchPoints[0].y;
                    handled = false;
                }
            }

            onReleased: (touchPoints) => {
                if (touchPoints.length === 1 && !handled) {
                    var dx = touchPoints[0].x - startX;
                    var dy = touchPoints[0].y - startY;

                    if (Math.abs(dx) > Math.abs(dy)) {
                        if (dx > 40) {
                            sfxNav.play();
                            gamegrid.moveCurrentIndexLeft();
                        } else if (dx < -40) {
                            sfxNav.play();
                            gamegrid.moveCurrentIndexRight();
                        }
                    } else {
                        if (dy > 40) {
                            if (gamegrid.currentIndex >= numColumns) {
                                sfxNav.play();
                                gamegrid.moveCurrentIndexUp();
                            } else {
                                sfxBack.play();
                                root.exit();
                            }
                        } else if (dy < -40) {
                            sfxNav.play();
                            gamegrid.moveCurrentIndexDown();
                        }
                    }

                    handled = true;
                }
            }
        }
    }
}
