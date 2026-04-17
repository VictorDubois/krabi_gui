import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    required property var palette

    Rectangle { anchors.fill: parent; color: root.palette.bg }

    ColumnLayout {
        anchors { fill: parent; margins: 16 }
        spacing: 12

        RowLayout {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            spacing: 12

            DiagnosticSection {
                Layout.fillWidth: true
                Layout.fillHeight: true
                palette: root.palette
                title: "Capteurs"

                DiagnosticItem { Layout.fillWidth: true; palette: root.palette; name: "Lidar haut";  status: diagnostics.lidarTop    }
                DiagnosticItem { Layout.fillWidth: true; palette: root.palette; name: "Lidar bas";   status: diagnostics.lidarBottom  }
                DiagnosticItem { Layout.fillWidth: true; palette: root.palette; name: "Caméra";      status: diagnostics.camera       }
            }

            DiagnosticSection {
                Layout.fillWidth: true
                Layout.fillHeight: true
                palette: root.palette
                title: "Cartes"

                DiagnosticItem { Layout.fillWidth: true; palette: root.palette; name: "Moteurs";     status: diagnostics.motorsCard    }
                DiagnosticItem { Layout.fillWidth: true; palette: root.palette; name: "Actionneurs"; status: diagnostics.actuatorsCard }
            }

            DiagnosticSection {
                Layout.fillWidth: true
                Layout.fillHeight: true
                palette: root.palette
                title: "Communications"

                DiagnosticItem { Layout.fillWidth: true; palette: root.palette; name: "Bus CAN";       status: diagnostics.canBus       }
                DiagnosticItem { Layout.fillWidth: true; palette: root.palette; name: "Wi-Fi";         status: diagnostics.wifi         }
                DiagnosticItem { Layout.fillWidth: true; palette: root.palette; name: "Bus Dynamixel"; status: diagnostics.dynamixelBus }
            }
        }

        DiagnosticSection {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            palette: root.palette
            title: "Batteries"

            DiagnosticItem {
                Layout.fillWidth: true
                palette: root.palette
                name:   "Batterie puissance"
                status: !isNaN(robotStatus.powerVoltage) && robotStatus.powerPercentage >= 0.2
                value:  isNaN(robotStatus.powerVoltage)
                        ? "—"
                        : robotStatus.powerVoltage.toFixed(2) + " V   "
                          + (robotStatus.powerPercentage * 100).toFixed(0) + " %"
            }

            DiagnosticItem {
                Layout.fillWidth: true
                palette: root.palette
                name:   "Batterie électronique"
                status: !isNaN(robotStatus.elecVoltage) && robotStatus.elecPercentage >= 0.2
                value:  isNaN(robotStatus.elecVoltage)
                        ? "—"
                        : robotStatus.elecVoltage.toFixed(2) + " V   "
                          + (robotStatus.elecPercentage * 100).toFixed(0) + " %"
            }
        }
    }
}
