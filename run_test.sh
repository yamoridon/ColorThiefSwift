#!/bin/sh

xcodebuild test -workspace Example/ColorThiefSwift.xcworkspace -scheme ColorThiefSwift-Example -sdk iphonesimulator10.2 -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' ONLY_ACTIVE_ARCH=NO
