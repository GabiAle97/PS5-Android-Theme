import QtQuick 2.12
import QtQuick.Layouts 1.11
import SortFilterProxyModel 0.2
import QtMultimedia 5.9
import QtGraphicalEffects 1.12
import QtQuick.Gestures 1.0
import "Lists"
import "utils.js" as Utils

FocusScope {
    id: root

    FontLoader { id: titleFont; source: "assets/fonts/HelveticaNowText-Bold.ttf" }
    FontLoader { id: subtitleFont; source: "assets/fonts/HelveticaNowText-Light.ttf" }
    FontLoader { id: bodyFont; source: "assets/fonts/HelveticaNowText-Regular.ttf" }

    ListLastPlayed  { id: listRecent; max: 10 }
    ListAllGames    { id: listSearch; searchTerm: searchtext }

    property int currentCollection: api.memory.has('Last Collection') ? api.memory.get('Last Collection') : -1
    property int nextCollection: api.memory.has('Last Collection') ? api.memory.get('Last Collection') : -1
    property var currentGame
    property string searchtext

    onNextCollectionChanged: changeCollection()

    function changeCollection() {
        if (nextCollection != currentCollection) {
            currentCollection = nextCollection;
            searchtext = ""
            gameBar.currentIndex = 1;
        }
    }

    function launchGame(game) {
        api.memory.set('Last Collection', currentCollection);
        if (game != null)
            game.launch();
        else
            currentGame.launch();
    }

    property var theme: {
        return {
            main:       "#ffffff",
            secondary:  "#202a44",
            accent:     "#f00980",
            highlight:  "#e3d810",
            text:       "#fff",
            button:     "#f00980"
        }
    }

    states: [
        State { name: "explore" },
        State { name: "allgames" },
        State { name: "topgames" },
        State { name: "gamedetails" },
        State { name: "settings" }
    ]

    property var lastState: []
    property var currentView: gameDetails
    property var nextView: gameDetails
    property string nextState: "gamedetails"
    property bool collectionMenuOpen

    onNextStateChanged: changeState()

    property int currentScreenID: 0
    onCurrentScreenIDChanged: {
        switch(currentScreenID) {
            case -1: explore(); break;
            case -3: allgames(); break;
            case -2: topgames(); break;
            default: gamedetails();
        }
        changeState();
    }

    function changeState() {
        if (nextState != root.state) {
            lastState.push(root.state);
            root.state = nextState;
            currentView = nextView;
            resetLists();
        }
    }

    function explore() {
        nextView = exploreScreen;
        nextState = "explore";
        exploreScreen.menu.opacity = 0;
        exploreScreen.intro.restart();
    }

    function allgames() {
        nextView = gameGrid;
        nextState = "allgames";
        gameGrid.menu.opacity = 0;
        gameGrid.intro.restart();
    }

    function topgames() {
        nextView = gameGrid;
        nextState = "topgames";
        gameGrid.menu.opacity = 0;
        gameGrid.intro.restart();
    }

    function gamedetails() {
        nextView = gameDetails;
        nextState = "gamedetails";
    }

    function search() {
        nextView = searchGrid;
        nextState = "search";
    }

    function navigationMenu() {
        gameDetails.menu.currentIndex = 0;
        gameBar.focus = true;
    }

    function mainView() {
        currentView.focus = true;
    }

    function resetLists() {
        gameGrid.menu.currentIndex = 0;
    }

    Component.onCompleted: {
        currentCollection = api.memory.has('Last Collection') ? api.memory.get('Last Collection') : -1
        api.memory.unset('Last Collection');
    }

    // GESTOS táctiles para cambiar colección
    MultiPointTouchArea {
        anchors.fill: parent
        minimumTouchPoints: 1
        maximumTouchPoints: 1

        GestureHandler {
            gestureType: GestureHandler.Swipe
            onTriggered: {
                if (gesture.horizontalVelocity < -1000) {
                    // Swipe izquierda - siguiente colección
                    sfxToggle.play();
                    navigationMenu();
                    if (currentCollection < api.collections.count - 1) {
                        nextCollection++;
                    } else {
                        nextCollection = -1;
                    }
                } else if (gesture.horizontalVelocity > 1000) {
                    // Swipe derecha - colección anterior
                    sfxToggle.play();
                    navigationMenu();
                    if (currentCollection == -1) {
                        nextCollection = api.collections.count - 1;
                    } else {
                        nextCollection--;
                    }
                }
            }
        }
    }

    // CONTINÚA EL RESTO DEL ARCHIVO SIN CAMBIOS...
    
    // Background, Collection bar, Game bar, Game details, etc...
    // (ya están definidos correctamente en tu archivo original)
    
    // No repito el contenido completo por razones de espacio, ya que no fue modificado

    // SOUND EFFECTS
    SoundEffect { id: sfxNav; source: "assets/sfx/navigation.wav"; volume: 1.0 }
    SoundEffect { id: sfxBack; source: "assets/sfx/back.wav"; volume: 1.0 }
    SoundEffect { id: sfxAccept; source: "assets/sfx/accept.wav" }
    SoundEffect { id: sfxToggle; source: "assets/sfx/toggle.wav" }
}
