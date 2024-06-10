#!/bin/bash

# Define base directories
CURRENT_FOLDER="$PWD"
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
REPO_NAME="grid-game"
REPO_PATH="$HOME/skydevz/learn-ci/$REPO_NAME" # Update this to your actual repo path
CACHE_FOLDER="dd-tar-cache"
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
cd ..
rm -rf $REPO_NAME # Remove old repo directory if exists
git clone -b main https://github.com/imthath-m/grid-game.git

# Update last modified time based on git
echo "Updating last modified time..."
cp $CURRENT_FOLDER/$TIME_RESTORE_SCRIPT $REPO_PATH/$TIME_RESTORE_SCRIPT
cd $REPO_PATH
python3 $TIME_RESTORE_SCRIPT

# Run `xcodebuild` with `-hsowBuildTimingSummary` option
echo "Running xcodebuild for main branch..."
xcodebuild -project 'GridGame.xcodeproj' \
-scheme 'GridGame' \
-configuration 'Debug' \
-sdk 'iphonesimulator' \
-destination 'platform=iOS Simulator,OS=17.2,name=iPhone 15' \
-showBuildTimingSummary \
build

# # Cache Derived Data
echo "Caching Derived Data..."
cd $CURRENT_FOLDER
mkdir -p $CACHE_FOLDER && tar cfPp $CACHE_FOLDER/$CACHE_FILE --format posix $DERIVED_DATA_PATH

# Clear Derived Data
echo "Clearing Derived Data again..."
rm -rf $DERIVED_DATA_PATH

# Delete repo
echo "Deleting repository..."
rm -rf $REPO_PATH

# Clone any feature branch which is only ahead of main
echo "Cloning feature branch..."
cd ..
git clone -b feature https://github.com/imthath-m/grid-game.git
cd $REPO_PATH

# Update last modified time based on git
echo "Updating last modified time for feature branch..."
git ls-files | xargs touch

# Update last modified time based on git
echo "Updating last modified time..."
cp $CURRENT_FOLDER/$TIME_RESTORE_SCRIPT $REPO_PATH/$TIME_RESTORE_SCRIPT
cd $REPO_PATH
python3 $TIME_RESTORE_SCRIPT

# Set DD based on cache
cd $CURRENT_FOLDER
tar xvPpf $CACHE_FOLDER/$CACHE_FILE

# Run `xcodebuild` with `-showBuildTimingSummary` option for the feature branch
echo "Running xcodebuild for feature branch..."
xcodebuild -project 'GridGame.xcodeproj' \
-scheme 'GridGame' \
-configuration 'Debug' \
-sdk 'iphonesimulator' \
-destination 'platform=iOS Simulator,OS=17.2,name=iPhone 15' \
-showBuildTimingSummary \
build