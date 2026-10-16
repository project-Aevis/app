import QtQuick
import HtMusic

Item {
    id: root

    readonly property string pageBrowseId: Browser.page && Browser.page.source ? Browser.page.source.browseId : ""
    readonly property string tabBrowseId: (Browser.section === 2 && Browser.libraryTabs && Browser.libraryTab >= 0 && Browser.libraryTab < Browser.libraryTabs.length)
        ? (Browser.libraryTabs[Browser.libraryTab].browseId || "") : ""

    readonly property bool isSongsPage: pageBrowseId === "FEmusic_liked_videos" || tabBrowseId === "FEmusic_liked_videos"
    readonly property bool isAlbumsPage: pageBrowseId === "FEmusic_liked_albums" || tabBrowseId === "FEmusic_liked_albums"
    readonly property bool isArtistsPage: pageBrowseId === "FEmusic_library_corpus_track_artists" || tabBrowseId === "FEmusic_library_corpus_track_artists"

    readonly property bool modalActive: (isSongsPage && songsPage.item && songsPage.item.modalActive)
        || (isAlbumsPage && albumsPage.item && albumsPage.item.modalActive)
        || (isArtistsPage && artistsPage.item && artistsPage.item.modalActive)
        || (browsePage.item && browsePage.item.modalActive)

    Loader {
        id: songsPage
        anchors.fill: parent
        active: root.isSongsPage
        visible: active
        sourceComponent: SongsPage {
            page: Browser.page
        }
    }

    Loader {
        id: albumsPage
        anchors.fill: parent
        active: root.isAlbumsPage
        visible: active
        sourceComponent: AlbumsPage {
            page: Browser.page
        }
    }

    Loader {
        id: artistsPage
        anchors.fill: parent
        active: root.isArtistsPage
        visible: active
        sourceComponent: ArtistsPage {
            page: Browser.page
        }
    }

    Loader {
        id: browsePage
        anchors.fill: parent
        active: !root.isSongsPage && !root.isAlbumsPage && !root.isArtistsPage
        visible: active
        sourceComponent: BrowsePage {}
    }
}
