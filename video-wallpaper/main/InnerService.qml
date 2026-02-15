import QtQuick

import qs.Commons
import qs.Services.UI

import "../common"

Item {
    id: root
    required property var pluginApi


    /***************************
    * PROPERTIES
    ***************************/
    // Required properties
    required property string screenName

    required property var         getThumbPath
    required property FolderModel thumbFolderModel

    // Monitor specific properties
    readonly property string currentWallpaper:  pluginApi?.pluginSettings?.[screenName]?.currentWallpaper  || ""
    readonly property string noctaliaWallpaper: pluginApi?.pluginSettings?.[screenName]?.noctaliaWallpaper || ""

    // Global properties
    readonly property bool enabled:         pluginApi?.pluginSettings?.enabled || false
    readonly property bool thumbCacheReady: pluginApi?.pluginSettings?.thumbCacheRead || false

    // Local properties
    property bool saving: false

    // Signals
    signal oldWallpapersSaved


    /***************************
    * FUNCTIONS
    ***************************/
    function saveOldWallpapers() {
        if (pluginApi == null || saving) return;

        saving = true;

        if(!thumbCacheReady) {
            Qt.callLater(saveOldWallpapers);
        }

        const currentWallpaper = WallpaperService.currentWallpapers[root.screenName];

        if (thumbFolderModel.indexOf(currentWallpaper) === -1) {
            saveTimer.save("noctaliaWallpaper", currentWallpaper);
            Logger.d("video-wallpaper", "Saving old wallpapers...");
        }

        oldWallpapersSaved();

        saving = false;
    }

    function applyOldWallpapers() {
        WallpaperService.changeWallpaper(noctaliaWallpaper, screenName);
        Logger.d("video-wallpaper", "Applying the old wallpapers...");
    }


    /***************************
    * EVENTS
    ***************************/
    onCurrentWallpaperChanged: {
        if (pluginApi == null) return;

        if (root.enabled && root.currentWallpaper != "") {
            root.saveOldWallpapers();
        } else {
            root.applyOldWallpapers();
        }
    }

    onEnabledChanged: {
        if (pluginApi == null) return;

        if (root.enabled && root.currentWallpaper != "") {
            root.saveOldWallpapers();
        } else {
            root.applyOldWallpapers();
        }
    }

    Component.onDestruction: {
        applyOldWallpapers();
    }

    /***************************
    * COMPONENTS
    ***************************/
    SaveTimer {
        id: saveTimer
        pluginApi: root.pluginApi
        screenName: root.screenName
    }
}
