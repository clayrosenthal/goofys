#!/bin/bash
set -euo pipefail

REPO="clayrosenthal/goofys"
BINARY="goofys"

# Require a version tag as argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v0.24.0"
    exit 1
fi

VERSION="$1"

# Verify gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is required. Install it from https://cli.github.com/"
    exit 1
fi

# Verify we're in a clean git state
if [ -n "$(git status --porcelain)" ]; then
    echo "Error: Working directory is not clean. Commit or stash changes first."
    exit 1
fi

# Create and push the tag
echo "Creating tag ${VERSION}..."
git tag -a "${VERSION}" -m "Release ${VERSION}"
git push fork "${VERSION}"

# Build binaries
echo "Building binaries..."
make build-all

# Create the GitHub release with both binaries
echo "Creating GitHub release ${VERSION}..."
gh release create "${VERSION}" \
    --repo "${REPO}" \
    --title "${VERSION}" \
    --generate-notes \
    "${BINARY}-linux-amd64#${BINARY}-linux-amd64" \
    "${BINARY}-linux-arm64#${BINARY}-linux-arm64"

echo "Release ${VERSION} published: https://github.com/${REPO}/releases/tag/${VERSION}"
