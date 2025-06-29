import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtMultimedia 5.9
import "Lists"
import "utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils

FocusScope {
    id: root

    signal exit

    property alias menu: mainList
    property alias intro: introAnim
    property bool allGamesView: currentCollection == -1
    property var collectionData: !allGamesView ? api.collections.get(currentCollection) : null

    SequentialAnimation {
        id: introAnim
        running: true
        NumberAnimation { target: mainList; property: "opacity"; to: 0; duration: 100 }
        PauseAnimation  { duration: 400 }
    }

    Flickable {
        id: flickArea
        anchors.fill: parent
        contentHeight: mainColumn.height
        interactive: true
        flickableDirection: Flickable.VerticalFlick

        Column {
            id: mainColumn
            width: parent.width

            ListAllGames    { id: listNone;         max: 0 }
            ListAllGames    { id: listAllGames;     max: 15 }
            ListPublisher   { id: listPublisher;    max: 15 }
            ListTopGames    { id: listTopGames;     max: 15 }
            ListLastPlayed  { id: listLastPlayed;   max: 30 }
            ListFavorites   { id: listFavorites }
        }

        MultiPointTouchArea {
            anchors.fill: parent
            minimumTouchPoints: 1
            maximumTouchPoints: 2

            onGestureStarted: {
                // Espacio reservado para gestos multitáctiles futuros
            }
        }
    }
} 
