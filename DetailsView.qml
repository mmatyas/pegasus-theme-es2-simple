import QtQuick 2.7 // note the version: Text padding is used below and that was added in 2.7 as per docs
import "utils.js" as Utils // some helper functions

// The details "view". Consists of some images, a bunch of textual info and a game list.
FocusScope {
    id: root

    // This will be set in the main theme file
    property var currentCollection
    // Shortcuts for the game list's currently selected game
    property alias currentGameIndex: gameList.currentIndex
    readonly property var currentGame: currentCollection.games.get(currentGameIndex)

    // Nothing particularly interesting, see CollectionsView for more comments
    width: parent.width
    height: parent.height
    enabled: focus
    visible: y < parent.height

    signal cancel
    signal nextCollection
    signal prevCollection
    signal launchGame

    // Key handling. In addition, pressing left/right also moves to the prev/next collection.
    Keys.onLeftPressed: prevCollection()
    Keys.onRightPressed: nextCollection()
    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isAccept(event)) {
            event.accepted = true;
            launchGame();
            return;
        }
        if (api.keys.isCancel(event)) {
            event.accepted = true;
            cancel();
            return;
        }
        if (api.keys.isNextPage(event)) {
            event.accepted = true;
            nextCollection();
            return;
        }
        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            prevCollection();
            return;
        }
    }

    // The header ba on the top, with the collection's logo and name
    Rectangle {
        id: header

        readonly property int paddingH: vpx(30) // H as horizontal
        readonly property int paddingV: vpx(22) // V as vertical

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: vpx(115)
        color: "#c5c6c7"

        Image {
            height: parent.height - header.paddingV * 2
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left; leftMargin: header.paddingH
                right: parent.horizontalCenter; rightMargin: header.paddingH
            }
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignLeft

            source: currentCollection.shortName ? "logo/%1.svg".arg(currentCollection.shortName) : ""
            asynchronous: true
        }

        Text {
            text: currentCollection.name
            wrapMode: Text.WordWrap
            font.capitalization: Font.AllUppercase
            font.family: "Open Sans"
            font.pixelSize: vpx(32)
            font.weight: Font.Light // this is how you use the light variant
            horizontalAlignment: Text.AlignRight
            color: "#7b7d7f"

            width: parent.width * 0.35
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right; rightMargin: header.paddingH
            }
        }
    }

    Rectangle {
        id: content
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        color: "#97999a"

        readonly property int paddingH: vpx(30)
        readonly property int paddingV: vpx(40)

        Item {
            id: boxart

            height: vpx(218)
            width: Math.max(vpx(160), Math.min(height * boxartImage.aspectRatio, vpx(320)))
            anchors {
                top: parent.top; topMargin: content.paddingV
                left: parent.left; leftMargin: content.paddingH
            }

            Image {
                id: boxartImage

                readonly property double aspectRatio: (implicitWidth / implicitHeight) || 0

                anchors.fill: parent
                asynchronous: true
                source: currentGame.assets.boxFront || currentGame.assets.logo
                sourceSize { width: 256; height: 256 } // optimization (max size)
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignLeft
            }
        }

        // While the game details could be a grid, I've separated them to two
        // separate columns to manually control thw width of the second one below.
        Column {
            id: gameLabels
            anchors {
                top: boxart.top
                left: boxart.right; leftMargin: content.paddingH
            }

            GameInfoText { text: "Rating:" }
            GameInfoText { text: "Released:" }
            GameInfoText { text: "Developer:" }
            GameInfoText { text: "Publisher:" }
            GameInfoText { text: "Genre:" }
            GameInfoText { text: "Players:" }
            GameInfoText { text: "Last played:" }
            GameInfoText { text: "Play time:" }
        }

        Column {
            id: gameDetails
            anchors {
                top: gameLabels.top
                left: gameLabels.right; leftMargin: content.paddingH
                right: gameList.left; rightMargin: content.paddingH
            }

            // 'width' is set so if the text is too long it will be cut. I also use some
            // JavaScript code to make some text pretty.
            RatingBar { percentage: currentGame.rating }
            GameInfoText { width: parent.width; text: Utils.formatDate(currentGame.release) || "unknown" }
            GameInfoText { width: parent.width; text: currentGame.developer || "unknown" }
            GameInfoText { width: parent.width; text: currentGame.publisher || "unknown" }
            GameInfoText { width: parent.width; text: currentGame.genre || "unknown" }
            GameInfoText { width: parent.width; text: Utils.formatPlayers(currentGame.players) }
            GameInfoText { width: parent.width; text: Utils.formatLastPlayed(currentGame.lastPlayed) }
            GameInfoText { width: parent.width; text: Utils.formatPlayTime(currentGame.playTime) }
        }

        GameInfoText {
            id: gameDescription
            anchors {
                top: boxart.bottom; topMargin: content.paddingV
                left: boxart.left
                right: gameList.left; rightMargin: content.paddingH
                bottom: parent.bottom; bottomMargin: content.paddingV
            }

            text: currentGame.description
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }

        ListView {
            id: gameList
            width: parent.width * 0.35
            anchors {
                top: parent.top; topMargin: content.paddingV
                right: parent.right; rightMargin: content.paddingH
                bottom: parent.bottom; bottomMargin: content.paddingV
            }
            //clip: true

            focus: true

            model: currentCollection.games
            delegate: Rectangle {
                readonly property bool selected: ListView.isCurrentItem
                readonly property color clrDark: "#393a3b"
                readonly property color clrLight: "#97999b"

                width: ListView.view.width
                height: gameTitle.height
                color: selected ? clrDark : clrLight

                Text {
                    id: gameTitle
                    text: modelData.title
                    color: parent.selected ? parent.clrLight : parent.clrDark

                    font.pixelSize: vpx(20)
                    font.capitalization: Font.AllUppercase
                    font.family: "Open Sans"

                    lineHeight: 1.2
                    verticalAlignment: Text.AlignVCenter

                    width: parent.width
                    elide: Text.ElideRight
                    leftPadding: vpx(10)
                    rightPadding: leftPadding
                }
            }

            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 0
            preferredHighlightBegin: height * 0.5 - vpx(15)
            preferredHighlightEnd: height * 0.5 + vpx(15)
        }
    }

    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: vpx(25) * 1.5
        color: header.color
    }
}
