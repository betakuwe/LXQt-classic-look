/***************************************************************************
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com>
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 2.8
import QtQuick.Controls 2.8
import QtQuick.Controls 1.4 as Q1
import QtQuick.Controls.Styles 1.4
import SddmComponents 2.0
import "."

Rectangle {
    id: container
    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }
    FontLoader { id: loginfont; source: "LiberationSans-Regular.ttf" }
    FontLoader { id: loginfontbold; source: "LiberationSans-Bold.ttf" }

    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = "steelblue"
            errorMessage.text = textConstants.loginSucceeded
        }

        onLoginFailed: {
            password.text = ""
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }
    }

    Background {
        anchors.fill: parent
        source: config.background
        fillMode: Image.Stretch
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        //visible: primaryScreen

        Clock2 {
            id: clock
            anchors.bottomMargin: 64
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            color: "#eaf5f9"
            timeFont.family: loginfontbold.name
        }

        Image {
            id: rectangle
            anchors.centerIn: parent
            width: 520
            height: 197

            source: "promptbox.svg"

            Column {
                id: mainColumn
                anchors.left: parent.left
                anchors.leftMargin: 8
                spacing: 8
                Text {
                    color: "white"
                    topPadding: 6
                    bottomPadding: 28
                    width: parent.width
                    text: "Login @ %1".arg(sddm.hostName)
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                    font.family: loginfontbold.name
                    font.bold: true
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHLeft
                }
                
                Grid {
                    leftPadding: 28
                    bottomPadding: 8
                    columns: 2
                    spacing: 2
                    Text {
                        id: lblLoginName
                        width: 96
                        height: 30
                        text: "User Name:"
                        font.family: loginfont.name
                        verticalAlignment: Text.AlignVCenter
                    }
                    TextField {
                        id: name
                        width: 348;
                        height: 28
                        text: userModel.lastUser
                        font.pixelSize: 14
                        
                        background: Image {
                            source: "input.svg"
                        }

                        KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                    Text {
                        id: lblLoginPassword
                        width: 96
                        height: 30
                        text: "Password:"
                        font.family: loginfont.name
                        verticalAlignment: Text.AlignVCenter
                    }
                    TextField {
                        id: password
                        width: 348;
                        height: 28
                        font.pixelSize: 14
                        echoMode: TextInput.Password
                        
                        background: Image {
                            source: "input.svg"
                        }

                        KeyNavigation.backtab: name; KeyNavigation.tab: loginButton

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }


                Column {
                    width: parent.width
                    
                    Text {
                        id: errorMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: textConstants.prompt
                        font.pixelSize: 12
                        font.family: loginfont.name
                    }
                }

                Row {
                    spacing: 16
                    anchors.horizontalCenter: parent.horizontalCenter
//                     anchors.bottom: parent.bottom
                    
//                     property int btnWidth: Math.max(loginButton.implicitWidth,
//                                                     shutdownButton.implicitWidth,
//                                                     rebootButton.implicitWidth, 80) + 8
                    
                    Q1.Button {
                        id: loginButton
                        text: textConstants.login
                        style: ButtonStyle {
                            background: Image {
                                source: control.pressed ? "buttondown.svg" : "buttonup.svg"
                            }
                        }
                        onClicked: sddm.login(name.text, password.text, sessionIndex)
                        KeyNavigation.backtab: password; KeyNavigation.tab: shutdownButton
                    }
                    

                    Q1.Button {
                        id: shutdownButton
                        text: textConstants.shutdown
                        style: ButtonStyle {
                            background: Image {
                                source: control.pressed ? "buttondown.svg" : "buttonup.svg"
                            }
                        }

                        onClicked: sddm.powerOff()
                        KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
                    }

                    Q1.Button {
                        id: rebootButton
                        text: textConstants.reboot
                        style: ButtonStyle {
                            background: Image {
                                source: control.pressed ? "buttondown.svg" : "buttonup.svg"
                            }
                        }

                        onClicked: sddm.reboot()
                        KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
