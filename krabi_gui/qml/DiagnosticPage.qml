import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    required property var palette

    Rectangle { anchors.fill: parent; color: root.palette.bg }

    GridLayout {
        anchors {
            fill: parent
            margins: 16
        }
        columns: 3
        rowSpacing: 12
        columnSpacing: 12

        DiagnosticSection {
            Layout.fillWidth: true
            Layout.fillHeight: true
            palette: root.palette
            title: "Capteurs"
            items: [
                { name: "Lidar haut",  status: diagnostics.lidarTop    },
                { name: "Lidar bas",   status: diagnostics.lidarBottom  },
                { name: "Caméra",      status: diagnostics.camera       }
            ]
        }

        DiagnosticSection {
            Layout.fillWidth: true
            Layout.fillHeight: true
            palette: root.palette
            title: "Cartes"
            items: [
                { name: "Moteurs",      status: diagnostics.motorsCard    },
                { name: "Actionneurs",  status: diagnostics.actuatorsCard }
            ]
        }

        DiagnosticSection {
            Layout.fillWidth: true
            Layout.fillHeight: true
            palette: root.palette
            title: "Communications"
            items: [
                { name: "Bus CAN",       status: diagnostics.canBus        },
                { name: "Wi-Fi",         status: diagnostics.wifi          },
                { name: "Bus Dynamixel", status: diagnostics.dynamixelBus  }
            ]
        }
    }
}
