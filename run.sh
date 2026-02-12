#!/bin/bash

# OpenCut Pro - Run Script
# This script builds and runs the Open Video Editor

set -e

echo "🎬 OpenCut Pro - Build & Run"
echo "=============================="
echo ""

# Ensure we're using Swift 6.2.3 or later
if command -v swiftly &> /dev/null; then
    echo "📦 Setting up Swift toolchain..."
    swiftly use 6.2.3 --global-default 2>/dev/null || true
fi

echo "✅ Using Swift $(swift --version | head -1)"
echo ""

# Clean previous build if requested
if [ "$1" == "--clean" ]; then
    echo "🧹 Cleaning previous build..."
    swift package clean
    rm -rf .build/debug .build/release
    echo "✅ Clean complete"
    echo ""
fi

# Build the project
echo "🔨 Building OpenCut Pro..."
swift build -c release

echo ""
echo "✅ Build successful!"
echo ""

# Run the executable
echo "🚀 Starting OpenCut Pro..."
echo ""
.build/release/open-video-editor "$@"
