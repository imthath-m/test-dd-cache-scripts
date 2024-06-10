#!/bin/bash

# Define base directories
CURRENT_FOLDER="$HOME/dd_exp"
DERIVED_DATA_PATH="$HOME/dd_exp/Build/DerivedData"
REPO_NAME="glass-app"
REPO_PATH="$HOME/dd_exp/$REPO_NAME"
CACHE_FOLDER="$HOME/dd_exp/dd-tar-cache"
CACHE_FILE="dd.tar"
TIME_RESTORE_SCRIPT="git-restore-mtime.py"

# Delete Derived Data caches
echo "Deleting Derived Data caches at $CACHE_FOLDER..."
rm -rf $CACHE_FOLDER

# Clear Derived Data
echo "Clearing Derived Data at $DERIVED_DATA_PATH..."
rm -rf $DERIVED_DATA_PATH

# Clone `main` branch
echo "Cloning main branch at $REPO_PATH..."
cd $CURRENT_FOLDER
rm -rf $REPO_NAME # Remove old repo directory if exists
git clone --single-branch -b ci/main-test --depth 10 git@gecgithub01.walmart.com:walmart-ios/glass-app.git

# Update last modified time based on git
echo "Updating last modified time..."
#cp $CURRENT_FOLDER/$TIME_RESTORE_SCRIPT $REPO_PATH/$TIME_RESTORE_SCRIPT
cd $REPO_PATH
python3 $HOME/dd_exp/test-dd-cache-scripts/$TIME_RESTORE_SCRIPT

# Run `xcodebuild` with `-hsowBuildTimingSummary` option
echo "Running xcodebuild for main branch..."
time xcodebuild -project 'markets/chile/Walmart-cl.xcodeproj' \
-scheme 'Walmart-cl' \
-configuration 'Debug' \
-sdk 'iphonesimulator' \
-destination 'platform=iOS Simulator,OS=17.2,name=iPhone 15' \
-derivedDataPath $DERIVED_DATA_PATH \
-showBuildTimingSummary \
-allowProvisioningUpdates \ 
CODE_SIGNING_ALLOWED=NO \
build | sed -n -e '/Build Timing Summary/,$p'

# # Cache Derived Data
echo "Caching Derived Data..."
cd $HOME/dd_exp/Build
mkdir -p $CACHE_FOLDER && tar cfPp $CACHE_FOLDER/$CACHE_FILE --format posix DerivedData

# Clear Derived Data
echo "Clearing Derived Data again..."
rm -rf $DERIVED_DATA_PATH

# Delete repo
echo "Deleting repository..."
rm -rf $REPO_PATH

# Clone any feature branch which is only ahead of main
echo "Cloning feature branch..."
cd $CURRENT_FOLDER
git clone --single-branch -b ci/feature-test --depth 10 git@gecgithub01.walmart.com:walmart-ios/glass-app.git
cd $REPO_PATH

# Restore DD based on cache
cd $HOME/dd_exp/Build
tar xPpf $CACHE_FOLDER/$CACHE_FILE
ls -ltrh $HOME/dd_exp/Build

# Update last modified time based on git
echo "Updating last modified time..."
cd $REPO_PATH
python3 $HOME/dd_exp/test-dd-cache-scripts/$TIME_RESTORE_SCRIPT

# Run `xcodebuild` with `-showBuildTimingSummary` option for the feature branch
echo "Running xcodebuild for feature branch..."
time xcodebuild -project 'markets/chile/Walmart-cl.xcodeproj' \
-scheme 'Walmart-cl' \
-configuration 'Debug' \
-sdk 'iphonesimulator' \
-destination 'platform=iOS Simulator,OS=17.2,name=iPhone 15' \
-derivedDataPath $DERIVED_DATA_PATH \
-showBuildTimingSummary \
-allowProvisioningUpdates \ 
CODE_SIGNING_ALLOWED=NO \
build | sed -n -e '/Build Timing Summary/,$p'