#!/bin/bash

#  BuildXCFramework.sh
#  AppSettings
#
#  Created by Federico Gasperini on 19/03/2021.
#  

FRAMEWORK_FOLDER_NAME="${PROJECT_NAME}_XCFramework"
FRAMEWORK_NAME="${PROJECT_NAME}"
FRAMEWORK_PATH="${BUILD_DIR}/${FRAMEWORK_FOLDER_NAME}/${FRAMEWORK_NAME}.xcframework"

SIMULATOR_ARCHIVE_PATH="${DERIVED_FILE_DIR}/${FRAMEWORK_FOLDER_NAME}/simulator.xcarchive"
IOS_DEVICE_ARCHIVE_PATH="${DERIVED_FILE_DIR}/${FRAMEWORK_FOLDER_NAME}/iOS.xcarchive"

rm -rf "${FRAMEWORK_PATH}"
echo "Deleted ${FRAMEWORK_PATH}"
mkdir -p "${FRAMEWORK_PATH}"
echo "Created ${FRAMEWORK_PATH}"
echo "Archiving ${FRAMEWORK_NAME}"
xcodebuild archive -scheme ${FRAMEWORK_NAME} -destination="iOS Simulator" -archivePath "${SIMULATOR_ARCHIVE_PATH}" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ${FRAMEWORK_NAME} -destination="iOS" -archivePath "${IOS_DEVICE_ARCHIVE_PATH}" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
#Creating XCFramework
xcodebuild -create-xcframework -framework ${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -framework ${IOS_DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -output "${FRAMEWORK_PATH}"
rm -rf "${SIMULATOR_ARCHIVE_PATH}"
rm -rf "${IOS_DEVICE_ARCHIVE_PATH}"
open "${BUILD_DIR}/${FRAMEWORK_FOLDER_NAME}"
