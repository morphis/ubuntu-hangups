import QtQuick 2.0
import Ubuntu.Components 1.2
//import Ubuntu.Web 0.2
import com.canonical.Oxide 1.0

 Page {
    title: i18n.tr("Authenticate with Google")
    visible: false

    property string usContext: "messaging://"

    Column {
        id: infoContainer
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: units.gu(2)
        spacing: units.gu(1)
        height: childrenRect.height + units.gu(1)

        visible: height !== 0 && opacity !== 0

        Behavior on height {
            NumberAnimation {duration: 100}
        }

        Behavior on opacity {
            NumberAnimation {duration: 90}
        }

        function hide() {
            height = 0;
        }

        FlexibleLabel {
            text: i18n.tr("In order to use Hangups you need to authenticate this app with Google")
        }

        Row {
            anchors.margins: units.gu(1)
            spacing: units.gu(1)
            width: parent.width

            Button {
                text: i18n.tr("About")
                color: UbuntuColors.blue
                onClicked: pageStack.push(aboutPage)
            }

            Button {
                text: i18n.tr("Got it")
                color: UbuntuColors.green
                onClicked: {
                    infoContainer.hide();
                }
            }


        }

    }

    Item {
        id: webviewContainer
        anchors.top: infoContainer.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        WebView {
            id: webview
            visible: !loading
            anchors.fill: parent
            property bool approved: false
            context: webcontext

            function getHTML(callback) {
                var req = webview.rootFrame.sendMessage(usContext, "GET_HTML", {})
                req.onreply = function (msg) {
                    callback(msg.html);
                }
                req.onerror = function (code, explanation) {
                    console.log("Error " + code + ": " + explanation)
                }
            }

            function getAuthCode(callback) {
                var req = webview.rootFrame.sendMessage(usContext, "GET_AUTH_CODE", {})
                req.onreply = function (msg) {
                    callback(msg.code);
                }
                req.onerror = function (code, explanation) {
                    console.log("Error " + code + ": " + explanation)
                }
            }

            function onApproved() {
                if (!approved) {
                    finishedIcon.opacity = 1;
                    infoContainer.opacity = 0;
                    approved = true;
                    visible = false;
                }
            }

            Component.onCompleted: {
                py.call('backend.get_login_url', [], function(result){
                    webview.url = result;
                });
            }

            onLoadingChanged: {
                if (loadProgress === 100 && url.toString().lastIndexOf('https://accounts.google.com/o/oauth2/approval', 0) === 0) {
                    onApproved();
                }
            }

            onLoadProgressChanged: {
            }

        }

        WebContext {
            id: webcontext
            userScripts: [
                UserScript {
                    context: usContext
                    url: Qt.resolvedUrl("oxide-user.js")
                }
            ]
        }

        ActivityIndicator {
            id: loadingIndicator
            anchors.bottom: loadingInfo.top
            anchors.bottomMargin: units.gu(1)
            anchors.horizontalCenter: parent.horizontalCenter
            running: webview.loading
            visible: webview.loading
        }

        Label {
            id: loadingInfo
            anchors.centerIn: parent
            text: i18n.tr("Loading, please wait ...")
            visible: webview.loading
        }

    }

    Rectangle {
        id: finishedIcon
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 1000 }
        }

        Behavior on y {
            SmoothedAnimation { duration: 1000 }
        }

        anchors.horizontalCenter: parent.horizontalCenter
        y: if (opacity === 1) {parent.height/2 - height} else { parent.height/2 - height/2 }

        width: if (parent.width<=256) { parent.width/2 } else { 256/2 }
        height: width
        color: UbuntuColors.green
        border.color: UbuntuColors.warmGrey
        border.width: 1
        radius: width*0.5

        Icon {
             anchors.centerIn: parent
             width: parent.width/2
             height: width
             name: "ok"
             color: "white"
        }
    }

    Label {
        id: successLabel
        opacity: if (finishedIcon.opacity === 1) { 1 } else { 0 }
        Behavior on opacity {
            NumberAnimation { duration: 1000 }
        }

        anchors.top: finishedIcon.bottom
        anchors.topMargin: units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter

        text: i18n.tr("Welcome to Hangups!")
        fontSize: "large"
    }

    Button {
        opacity: if (finishedIcon.opacity === 1) { 1 } else { 0 }
        Behavior on opacity {
            NumberAnimation { duration: 1000 }
        }

        anchors.top: successLabel.bottom
        anchors.topMargin: units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("Get started")
        color: UbuntuColors.green
        onClicked: {
            webview.getAuthCode(function callback(code) {
                pageStack.clear();
                pageStack.push(loadingPage);
                py.call('backend.auth_with_code', [code])
            });
        }

    }

}
