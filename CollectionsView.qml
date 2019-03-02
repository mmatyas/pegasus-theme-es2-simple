import QtQuick 2.0

// The collections view consists of two carousels, one for the collection logo bar
// and one for the background images. They should have the same number of elements
// to be kept in sync.
FocusScope {
    id: root

    // This element has the same size as the whole screen (ie. its parent).
    // Because this screen itself will be moved around when a collection is
    // selected, I've used width/height instead of anchors.
    width: parent.width
    height: parent.height
    enabled: focus // do not receive key/mouse events when unfocused
    visible: y + height >= 0 // optimization: do not render the item when it's not on screen

    signal collectionSelected

    // Shortcut for the currently selected collection. They will be used
    // by the Details view too, for example to show the collection's logo.
    property alias currentCollectionIndex: logoAxis.currentIndex
    readonly property var currentCollection: logoAxis.model.get(logoAxis.currentIndex)

    // These functions can be called by other elements of the theme if the collection
    // has to be changed manually. See the connection between the Collection and
    // Details views in the main theme file.
    function selectNext() {
        logoAxis.incrementCurrentIndex();
    }
    function selectPrev() {
        logoAxis.decrementCurrentIndex();
    }

    // The carousel of background images. This isn't the item we control with the keys,
    // however it reacts to mouse and so should still update the Index.
    Carousel {
        id: bgAxis

        anchors.fill: parent
        itemWidth: width

        model: api.collections
        delegate: bgAxisItem
        currentIndex: logoAxis.currentIndex

        highlightMoveDuration: 500 // it's moving a little bit slower than the main bar
    }
    Component {
        // Either the image for the collection or a single colored rectangle
        id: bgAxisItem

        Item {
            width: root.width
            height: root.height
            visible: PathView.onPath // optimization: do not draw if not visible

            Rectangle {
                anchors.fill: parent
                color: "#777"
                visible: realBg.status != Image.Ready // optimization: only draw if the image did not load (yet)
            }
            Image {
                id: realBg
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop // fill the screen without black bars
                source: modelData.shortName ? "bg/%1_art_blur.png".arg(modelData.shortName) : ""
                asynchronous: true
            }
        }
    }

    // I've put the main bar's parts inside this wrapper item to change the opacity
    // of the background separately from the carousel. You could also use a Rectangle
    // with a color that has alpha value.
    Item {
        id: logoBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: vpx(170)

        // Background
        Rectangle {
            anchors.fill: parent
            color: "#fff"
            opacity: 0.85
        }
        // The main carousel that we actually control
        Carousel {
            id: logoAxis

            anchors.fill: parent
            itemWidth: vpx(480)

            model: api.collections
            delegate: CollectionLogo {
                longName: modelData.name
                shortName: modelData.shortName
            }

            focus: true

            Keys.onPressed: {
                if (event.isAutoRepeat)
                    return;

                if (api.keys.isNextPage(event)) {
                    event.accepted = true;
                    incrementCurrentIndex();
                }
                else if (api.keys.isPrevPage(event)) {
                    event.accepted = true;
                    decrementCurrentIndex();
                }
            }

            onItemSelected: root.collectionSelected()
        }
    }

    // Game count bar -- like above, I've put it in an Item to separately control opacity
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: logoBar.bottom
        height: label.height * 1.5

        Rectangle {
            anchors.fill: parent
            color: "#ddd"
            opacity: 0.85
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: "%1 GAMES AVAILABLE".arg(currentCollection.games.count)
            color: "#333"
            font.pixelSize: vpx(25)
            font.family: "Open Sans"
        }
    }
}
