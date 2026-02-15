pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.Commons
import qs.Services.UI
import qs.Widgets

import "../common"

ColumnLayout {
    id: root
    required property var pluginApi


    /***************************
    * PROPERTIES
    ***************************/
    required property string screenName
    required property bool   thumbCacheReady

    readonly property string currentWallpaper: pluginApi?.pluginSettings?.[screenName]?.currentWallpaper || ""
    readonly property bool   monitorSpecific:  pluginApi?.pluginSettings?.monitorSpecific || false

    anchors.fill: parent


    /***************************
    * COMPONENTS
    ***************************/
    // Wallpapers folder content
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true

        color: Color.mSurfaceVariant;
        radius: Style.radiusS;

        ColumnLayout {
            anchors.fill: parent
            visible: !root.thumbCacheReady
            spacing: Style.marginS

            NText {
                text: root.pluginApi?.tr("panel.loading") || "Loading..."
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                pointSize: Style.fontSizeL
                font.weight: Font.Bold
            }
        }

        ColumnLayout {
            anchors.fill: parent
            visible: root.thumbCacheReady
            spacing: Style.marginS

            NGridView {
                id: gridView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Style.marginXXS

                property int columns: Math.max(1, Math.floor(availableWidth / 300));
                property int itemSize: Math.floor(availableWidth / columns)

                cellWidth: itemSize
                // For now all wallpapers are shown in a 16:9 ratio
                cellHeight: Math.floor(itemSize * (9/16))

                model: folderModel.ready && root.thumbCacheReady ? folderModel.files : 0

                // Wallpaper
                delegate: Item {
                    id: wallpaper
                    required property string modelData
                    width: gridView.cellWidth
                    height: gridView.cellHeight

                    NImageRounded {
                        id: wallpaperImage
                        anchors {
                            fill: parent
                            margins: Style.marginXXS
                        }

                        radius: Style.radiusXS

                        borderWidth: {
                            if (root.thumbCacheReady && root.currentWallpaper == wallpaper.modelData) return Style.borderM;
                            else return 0;
                        }
                        borderColor: Color.mPrimary;

                        imagePath: {
                            if (root.thumbCacheReady && root.pluginApi.mainInstance != null) return root.pluginApi.mainInstance.getThumbPath(wallpaper.modelData);
                            else return "";
                        }
                        fallbackIcon: "alert-circle"

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent

                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true;

                            onClicked: {
                                if(root.pluginApi.mainInstance == null) {
                                    Logger.e("video-wallpaper", "Can't change background because pluginApi or main instance doesn't exist!");
                                    return;
                                }

                                // Check that the monitor object exists.
                                if (root.pluginApi.pluginSettings[root.screenName] === undefined) {
                                    root.pluginApi.pluginSettings[root.screenName] = {};
                                }

                                root.pluginApi.pluginSettings[root.screenName].currentWallpaper = wallpaper.modelData;
                                root.pluginApi.saveSettings();
                            }

                            onEntered: TooltipService.show(wallpaperImage, wallpaper.modelData, "auto", 100);
                            onExited: TooltipService.hideImmediately();
                        }
                    }
                }
            }

        }
    }

    ToolRow {
        pluginApi:       root.pluginApi
        monitorSpecific: root.monitorSpecific
        screenName:      root.screenName
    }
}
