import QtQuick 2.7 // note the version: Text padding is used below and that vas added in 2.7 as per docs
import "utils.js" as Utils // some helper functions

// The details "view". Consists of some images, a bunch of textual info and a game list.
FocusScope {
    id: root

    // Nothing particularly interesting, see CollectionsView for more comments
    width: parent.width
    height: parent.height
    enabled: focus
    visible: y < parent.height

    signal cancel

    // Key handling. In addition, pressing left/right also moves to the prev/next collection.
    Keys.onLeftPressed: api.collectionList.decrementIndex()
    Keys.onRightPressed: api.collectionList.incrementIndex()
    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isAccept(event.key)) {
            event.accepted = true;
            api.currentGame.launch();
            return;
        }
        if (api.keys.isCancel(event.key)) {
            event.accepted = true;
            cancel();
            return;
        }
        if (api.keys.isAccept(event.key)) {
            event.accepted = true;
            api.currentGame.launch();
            return;
        }
        if (api.keys.isNextPage(event.key)) {
            event.accepted = true;
            api.collectionList.incrementIndex();
            return;
        }
        if (api.keys.isPrevPage(event.key)) {
            event.accepted = true;
            api.collectionList.decrementIndex();
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

            source: "logo/%1.svg".arg(api.collectionList.current.shortName)
            asynchronous: true
        }

        Text {
            text: api.collectionList.current.name
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

        Image {
            id: boxart

            height: vpx(218)
            anchors {
                top: parent.top; topMargin: content.paddingV
                left: parent.left; leftMargin: content.paddingH
            }

            asynchronous: true
            source: api.currentGame.assets.boxFront || api.currentGame.assets.logo
            sourceSize { width: 256; height: 256 } // optimization (max size)
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignLeft
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
            RatingBar { percentage: api.currentGame.rating }
            GameInfoText { width: parent.width; text: Utils.formatDate(api.currentGame.release) || "unknown" }
            GameInfoText { width: parent.width; text: api.currentGame.developer || "unknown" }
            GameInfoText { width: parent.width; text: api.currentGame.publisher || "unknown" }
            GameInfoText { width: parent.width; text: api.currentGame.genre || "unknown" }
            GameInfoText { width: parent.width; text: Utils.formatPlayers(api.currentGame.players) }
            GameInfoText { width: parent.width; text: Utils.formatLastPlayed(api.currentGame.lastPlayed) }
            GameInfoText { width: parent.width; text: Utils.formatPlayTime(api.currentGame.playTime) }
        }

        GameInfoText {
            id: gameDescription
            anchors {
                top: boxart.bottom; topMargin: content.paddingV
                left: boxart.left
                right: gameList.left; rightMargin: content.paddingH
                bottom: parent.bottom; bottomMargin: content.paddingV
            }

            text: api.currentGame.description
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

            model: api.currentCollection.gameList.model
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

            currentIndex: api.currentCollection.gameList.index
            onCurrentIndexChanged: api.currentCollection.gameList.index = currentIndex

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