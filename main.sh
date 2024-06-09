#!/bin/bash

# Define base directories
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
REPO_PATH="$HOME/skydevz/learn-ci/grid-game" # Update this to your actual repo path
CACHE_PATH="$HOME/skydevz/learn-ci/test-dd-cache-scripts/dd-cache"

# Delete Derived Data caches
echo "Deleting Derived Data caches..."
rm -rf "$CACHE_PATH/*"

# Clear Derived Data
echo "Clearing Derived Data..."
rm -rf "$DERIVED_DATA_PATH/*"

# Clone `main` branch
echo "Cloning main branch..."
cd "$HOME" # Move to a directory where you can clone the repo
rm -rf "$REPO_PATH" # Remove old repo directory if exists
git clone -b main https://your_repo_url.git "$REPO_PATH" # Replace 'your_repo_url' with your actual repository URL

# Update last modified time based on git
echo "Updating last modified time..."
cd "$REPO_PATH"
git ls-files | xargs touch

# Run `xcodebuild` with `-showBuildTimingSummary` option
echo "Running xcodebuild for main branch..."
xcodebuild -project YourProject.xcodeproj -scheme YourScheme -showBuildTimingSummary clean build # Update with your project details

# Cache Derived Data
echo "Caching Derived Data..."
cp -R "$DERIVED_DATA_PATH" "$CACHE_PATH"

# Clear Derived Data
echo "Clearing Derived Data again..."
rm -rf "$DERIVED_DATA_PATH/*"

# Delete repo
echo "Deleting repository..."
rm -rf "$REPO_PATH"

# Clone any feature branch which is only ahead of main
echo "Cloning feature branch..."
git clone https://your_repo_url.git "$REPO_PATH" # Clone repo
cd "$REPO_PATH"
git checkout feature-branch # Update with your feature branch that is ahead of main

# Update last modified time based on git
echo "Updating last modified time for feature branch..."
git ls-files | xargs touch

# Restore Derived Data from cache
echo "Restoring Derived Data from cache..."
cp -R "$CACHE_PATH/*" "$DERIVED_DATA_PATH"

# Run `xcodebuild` with `-showBuildTimingSummary` option for the feature branch
echo "Running xcodebuild for feature branch..."
xcodebuild -project YourProject.xcodeproj -scheme YourScheme -showBuildTimingSummary clean build # Update with your project details