import QtQuick 2.0

// The rating bar is a 5-stars bar set to a percentage. It's actually
// two images set on a repeating pattern.
Item {
    property real percentage

    readonly property int starHeight: vpx(26)

    height: starHeight
    width: 5 * height

    // tiling on the left side
    Image {
        width: parent.width * percentage
        height: parent.height

        source: "assets/star_filled.svg"
        sourceSize { width: starHeight; height: starHeight } // to make tiling work, the heights must match
        asynchronous: true

        fillMode: Image.TileHorizontally
        horizontalAlignment: Image.AlignLeft
    }

    // tiling from the right
    Image {
        width: parent.width * (1.0 - percentage)
        height: parent.height
        anchors.right: parent.right

        source: "assets/star_hollow.svg"
        sourceSize { width: starHeight; height: starHeight }
        asynchronous: true

        fillMode: Image.TileHorizontally
        horizontalAlignment: Image.AlignRight
    }
}
