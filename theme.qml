import QtQuick 2.0

// Welcome! This is the entry point of the theme; it defines two "views"
// and a way to move (and animate moving) between them.
FocusScope {
    // Loading the fonts here makes them usable in the rest of the theme
    // and can be referred to using their name and weight.
    FontLoader { source: "fonts/OPENSANS.TTF" }
    FontLoader { source: "fonts/OPENSANS-LIGHT.TTF" }

    // The actual views are defined in their own QML files. They activate
    // each other by setting the focus. The details view is glued to the bottom
    // of the collections view, and the collections view to the bottom of the
    // screen for animation purposes (see below).
    CollectionsView {
        id: collectionsView
        anchors.bottom: parent.bottom

        focus: true
        onCollectionSelected: detailsView.focus = true
    }
    DetailsView {
        id: detailsView
        anchors.top: collectionsView.bottom

        currentCollection: collectionsView.currentCollection

        onCancel: collectionsView.focus = true
        onNextCollection: collectionsView.selectNext()
        onPrevCollection: collectionsView.selectPrev()
    }

    // I animate the collection view's bottom anchor to move it to the top of
    // the screen. This, in turn, pulls up the details view.
    states: [
        State {
            when: detailsView.focus
            AnchorChanges {
                target: collectionsView;
                anchors.bottom: parent.top
            }
        }
    ]
    // Add some animations. There aren't any complex State definitions so I just
    // set a generic smooth anchor animation to get the job done.
    transitions: Transition {
        AnchorAnimation {
            duration: 400
            easing.type: Easing.OutQuad
        }
    }
}
