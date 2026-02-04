import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  // Plugin API (injected by the settings dialog system)
  property var pluginApi: null

  // Local state for editing
  property string editLauncher: pluginApi?.pluginSettings?.launcher || "xdg-open"

  spacing: Style.marginM

  // Calibre db
  ColumnLayout {
      NLabel {
          enabled: root.active
          label: pluginApi?.tr("settings.launcher.title") || "Launcher"
          description: pluginApi?.tr("settings.launcher.description") || "The program used to open book files"
      }

      NTextInput {
          enabled: root.active
          Layout.fillWidth: true
          placeholderText: "xdg-open"
          text: root.editLauncher
          onTextChanged: root.editLauncher = text
      }
  }


  // Required: Save function called by the dialog
  function saveSettings() {
    pluginApi.pluginSettings.launcher = root.editLauncher;
    pluginApi.saveSettings();
  }
}
