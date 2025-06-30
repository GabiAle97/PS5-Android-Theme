import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtMultimedia 5.9
import "Lists"
import "utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils

FocusScope {
id: root

    // Pull in our custom lists and define
    ListAllGames    { id: listNone;         max: 0 }
    ListAllGames    { id: listAllGames;     max: 15 }
    ListPublisher   { id: listPublisher;    max: 15; publisher: gameData ? gameData.publisher : "" }
    ListTopGames    { id: listTopGames;     max: 15 }
    ListLastPlayed  { id: listLastPlayed;   max: 15 }

    property var gameData: listLastPlayed.games.get(currentGameIndex)
    property alias menu: mainList

    signal exit

    onGameDataChanged: {
        mainList.opacity = 0;
        introAnim.restart();
    }

    SequentialAnimation {
    id: introAnim

        running: true
        NumberAnimation { target: mainList; property: "opacity"; to: 0; duration: 100 }
        PauseAnimation  { duration: 400 }
        ParallelAnimation {
            NumberAnimation { target: mainList; property: "opacity"; from: 0; to: 1; duration: 400;
                easing.type: Easing.OutCubic;
                easing.amplitude: 2.0;
                easing.period: 1.5 
            }
            NumberAnimation { target: mainList; property: "y"; from: 50; to: 0; duration: 400;
                easing.type: Easing.OutCubic;
                easing.amplitude: 2.0;
                easing.period: 1.5 
            }
        }
    }

    ObjectModel {
    id: mainModel

        Item {
        id: featuredRecentGame

            width: parent.width
            height: vpx(500)
            property bool selected: ListView.isCurrentItem && root.focus

            Image {
            id: favelogo

                width: vpx(300)
                anchors { 
                    top: parent.top
                    bottom: gameNav.top; bottomMargin: vpx(50)
                    left: parent.left;
                }
                property var logoImage:  gameData ?
                    gameData.collections.get(0).shortName === "retropie" ? 
                        gameData.assets.boxFront 
                    : 
                        (gameData.collections.get(0).shortName === "steam") ? 
                            Utils.logo(gameData) 
                        : 
                            gameData.assets.logo
                : ""

                source: gameData ? logoImage || "" : ""
                sourceSize: Qt.size(parent.width, parent.height)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                verticalAlignment: Image.AlignBottom
            }

            Text {
            id: gameName

                text: gameData ? !gameData.assets.logo ? gameData.title : "" : ""
                font.pixelSize: vpx(40)
                font.family: titleFont.name
                anchors {
                    bottom: favelogo.bottom; 
                    left: parent.left;
                }
                color: theme.text
            }

            ObjectModel {
            id: gameNavModel

                Button {
                id: playButton  

                    width: vpx(225)
                    isSelected: featuredRecentGame.selected && ListView.isCurrentItem

                    onActivated: { 
                        sfxAccept.play();
                        launchGame(gameData); 
                    }
                }

                Button {
                id: favButton  

                    width: vpx(50)
                    isSelected: featuredRecentGame.selected && ListView.isCurrentItem
                    icon: "assets/images/Favorites.png"
                    onActivated: { 
                        sfxToggle.play();
                        gameData.favorite = !gameData.favorite;
                    }
                    hlColor: gameData ? gameData.favorite ? theme.highlight : "white" : "white"
                }
            }

            ListView {
            id: gameNav

                width: vpx(500)
                height: vpx(50)
                anchors { 
                    top: parent.top; topMargin: vpx(350)
                    left: parent.left
                }
                focus: featuredRecentGame.selected
                orientation: ListView.Horizontal
                spacing: vpx(10)
                model: gameNavModel
                keyNavigationWraps: true

//                MultiPointTouchArea {
//                    anchors.fill: parent
//
//                    onReleased: {
//                        const dx = touchPoints[0].startX - touchPoints[0].x;
//                        if (Math.abs(dx) > 40) {
//                            if (dx > 0) {
//                                sfxNav.play();
//                                gameNav.incrementCurrentIndex();
//                            } else {
//                                sfxNav.play();
//                                gameNav.decrementCurrentIndex();
//                            }
//                        }
//                    }
//                }
            }

            Image {
            id: boxart

                width: vpx(350)
                height: vpx(300)
                anchors {
                    bottom: gameNav.bottom
                    right: parent.right
                }
                source: gameData ? Utils.boxArt(gameData) : ""
                sourceSize: Qt.size(parent.width, parent.height)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                horizontalAlignment: Image.AlignRight
                verticalAlignment: Image.AlignBottom
            }
        }

        Item {
        id: gamedetails

            property bool selected: ListView.isCurrentItem
            opacity: selected ? 1 : 0.5
            width: vpx(600)
            height: vpx(300)

            Text {
            id: detailsTitle

                text: gameData ? gameData.title : ""
                font.family: subtitleFont.name
                font.pixelSize: vpx(20)
                font.bold: true
                color: theme.text
                anchors { left: parent.left; top: parent.top; topMargin: vpx(5) }
                height: vpx(50)
            }

            PegasusUtils.AutoScroll {
            id: gameDescription

                anchors {
                    top: detailsTitle.bottom;
                    left: parent.left; 
                    right: parent.right;
                    bottom: parent.bottom; bottomMargin: vpx(30)
                }

                Text {
                    width: parent.width
                    text: gameData && (gameData.summary || gameData.description) ? gameData.description || gameData.summary : "No description available"
                    font.pixelSize: vpx(16)
                    font.family: bodyFont.name
                    color: theme.text
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                }
            }
        }

        HorizontalList {
        id: recentList

            property bool selected: ListView.isCurrentItem && root.focus
            property var currentList
            collectionData: listPublisher.games

            width: mainList.width
            height: vpx(300)

            title: gameData ? "More by " + gameData.publisher : ""

            focus: selected
        }
    }

    ListView {
    id: mainList

        width: parent.width;
        height: parent.height;

        anchors {
            left: parent.left; leftMargin: vpx(125)
            right: parent.right; rightMargin: vpx(125)
        }

        model: mainModel
        focus: true

        preferredHighlightBegin: vpx(50)
        preferredHighlightEnd: parent.height - vpx(60)
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem 
        highlightMoveDuration: 100

//        MultiPointTouchArea {
//            anchors.fill: parent
//
//            onReleased: {
//                const dy = touchPoints[0].startY - touchPoints[0].y;
//                if (Math.abs(dy) > 50) {
//                    if (dy > 0) {
//                        sfxNav.play(); 
//                        mainList.incrementCurrentIndex();
//                    } else {
//                        if (mainList.currentIndex === 0) {
//                            sfxBack.play();
//                            root.exit();
//                        } else {
//                            sfxNav.play(); 
//                            mainList.decrementCurrentIndex();
//                        }
//                    }
//                }
//            }
//        }
    }
}
