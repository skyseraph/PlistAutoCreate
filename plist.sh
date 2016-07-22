#!/bin/bash

APP_NAME=xxx   # Your app name here 
echo appName=$APP_NAME 

ROOT_DIR=$PWD
PLIST=$ROOT_DIR/$APP_NAME/Info.plist

VC=$(/usr/libexec/PlistBuddy -c Print\ :CFBundleVersion $PLIST)
VN=$(/usr/libexec/PlistBuddy -c Print\ :CFBundleShortVersionString $PLIST)

echo PLIST=$PLIST
echo versionCode=$VC versionName=$VN

CONFIG=$1
echo configuration=$CONFIG
if [ "$CONFIG" = "" ]; then
    CONFIG=Debug
    echo use default configuration:$CONFIG
fi

if [ "$CONFIG" != "Debug" ] && [ "$CONFIG" != "Test" ] && [ "$CONFIG" != "Release" ]; then
    echo onfiguration $CONFIG not found!
    exit 1
fi

BUILD_DIR=$ROOT_DIR/build
echo buildDir=$BUILD_DIR

OUTPUT_DIR=$BUILD_DIR/$CONFIG-iphoneos
echo output=$OUTPUT_DIR

IPA_FILE=$OUTPUT_DIR/$APP_NAME-$VN-$CONFIG.ipa
IPA_NAME=$APP_NAME-$VN-$CONFIG
echo IPA_NAME=$IPA_NAME

BUILD_URL=http://xxx/job/xxx     # Your jenkins link, use default port 8080 
BUILD_URLS=https://xxx/job/xxx   # Your jenkins https link, use different port, ex 8088
BUILD_NUMBER=${BUILD_NUMBER}
echo path=$BUILD_URL/$BUILD_NUMBER/artifact/build/$CONFIG-iphoneos/$IPA_NAME

cd "${WORKSPACE}/build/$CONFIG-iphoneos/"
echo "IPA_NAME=$IPA_NAME" > jenkinsUserGlobal.properties

cat << EOF > ${WORKSPACE}/build/$CONFIG-iphoneos/$IPA_NAME.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>items</key>
        <array>
                <dict>
                        <key>assets</key>
                        <array>
                                <dict>
                                        <key>kind</key>
                                        <string>software-package</string>
                                        <key>url</key>
                                        <string>$BUILD_URL/$BUILD_NUMBER/artifact/build/$CONFIG-iphoneos/$IPA_NAME.ipa</string>
                                </dict>
                        </array>
                        <key>metadata</key>
                        <dict>
                                <key>bundle-identifier</key>
                                <string>xxx</string>
                                <key>bundle-version</key>
                                <string>1.0.0</string>
                                <key>kind</key>
                                <string>software</string>
                                <key>title</key>
                                <string>$APP_NAME</string>
                        </dict>
                </dict>
        </array>
</dict>
</plist>
EOF

cat << EOF > ${WORKSPACE}/build/$CONFIG-iphoneos/index.html
<html>
<body>
<p style="text-align:center;">
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
</p>

<h1 style="text-align:center;">
    <a style="font-size:128px;" href="itms-services://?action=download-manifest&url=$BUILD_URLS/$BUILD_NUMBER/artifact/build/$CONFIG-iphoneos/$IPA_NAME.plist">Install App</a>
</h1>
</body>
</html>
EOF
