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

            // ROS diagnostics card — built manually so ListView can fill height
            Rectangle {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                color:        root.palette.surface
                radius:       10
                border.color: root.palette.border
                border.width: 1

                ColumnLayout {
                    anchors { fill: parent; margins: 16 }
                    spacing: 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text:            "ROS"
                        color:           root.palette.textPri
                        font.pixelSize:  14
                        font.weight:     Font.DemiBold
                        font.letterSpacing: 1
                    }

                    Rectangle {
                        Layout.fillWidth:   true
                        Layout.topMargin:   10
                        Layout.bottomMargin: 10
                        height: 1
                        color:  root.palette.border
                    }

                    ListView {
                        id: rosList
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        clip:    true
                        model:   diagnostics.rosItems
                        spacing: 0

                        delegate: DiagnosticItem {
                            required property var modelData
                            width:   rosList.width
                            palette: root.palette
                            name:    modelData.name
                            status:  modelData.ok
                            warning: modelData.warning
                            value:   modelData.message
                        }

                        Text {
                            anchors.centerIn: parent
                            visible:          rosList.count === 0
                            text:             "Aucun diagnostic reçu"
                            color:            root.palette.textSec
                            font.pixelSize:   13
                        }
                    }
                }
            }

            DiagnosticSection {
                Layout.fillWidth:        false
                Layout.preferredWidth:   180
                Layout.fillHeight:       true
                palette: root.palette
                title: "Système"

                DiagnosticItem { Layout.fillWidth: true; palette: root.palette; name: "Bus CAN"; status: diagnostics.canBus }
                DiagnosticItem { Layout.fillWidth: true; palette: root.palette; name: "Wi-Fi";   status: diagnostics.wifi;  value: diagnostics.wifiIp }
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
