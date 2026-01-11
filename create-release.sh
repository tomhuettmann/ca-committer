#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if version argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo "Usage: ./create-release.sh <version>"
    echo "Example: ./create-release.sh 1.0.0"
    exit 1
fi

VERSION=$1
TAG="v${VERSION}"

# Validate version format (basic semver check)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format${NC}"
    echo "Version must be in format: X.Y.Z (e.g., 1.0.0)"
    exit 1
fi

echo -e "${YELLOW}Creating release for version ${VERSION}${NC}\n"

# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}Error: Working directory is not clean${NC}"
    echo "Please commit or stash your changes first"
    git status --short
    exit 1
fi

# Check if on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}Warning: Not on main branch (currently on: ${CURRENT_BRANCH})${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update version in CoAuthorCommitter.swift
echo -e "${GREEN}→${NC} Updating version in CoAuthorCommitter.swift..."
sed -i '' "s/version: \".*\"/version: \"${VERSION}\"/" Sources/Application/CoAuthorCommitter.swift

# Verify the change
if grep -q "version: \"${VERSION}\"" Sources/Application/CoAuthorCommitter.swift; then
    echo -e "${GREEN}✓${NC} Version updated successfully"
else
    echo -e "${RED}Error: Failed to update version${NC}"
    exit 1
fi

# Show the diff
echo -e "\n${YELLOW}Changes:${NC}"
git diff Sources/Application/CoAuthorCommitter.swift

# Confirm
echo
read -p "Commit and create tag ${TAG}? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Aborted. Resetting changes...${NC}"
    git checkout Sources/Application/CoAuthorCommitter.swift
    exit 0
fi

# Commit version bump
echo -e "\n${GREEN}→${NC} Committing version bump..."
git add Sources/Application/CoAuthorCommitter.swift
git commit -m "bump version to ${VERSION}"

# Create tag
echo -e "${GREEN}→${NC} Creating tag ${TAG}..."
git tag -a "${TAG}" -m "Release ${VERSION}"

# Push
echo -e "\n${YELLOW}Ready to push!${NC}"
echo "This will push:"
echo "  - Commit with version bump"
echo "  - Tag ${TAG}"
echo
read -p "Push to origin? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}→${NC} Pushing to origin..."
    git push origin main
    git push origin "${TAG}"
    
    echo -e "\n${GREEN}✓ Release ${VERSION} created successfully!${NC}"
    echo -e "GitHub Actions will now build and publish the release."
    echo -e "Check: https://github.com/tomhuettmann/ca-committer/actions"
else
    echo -e "\n${YELLOW}Not pushed.${NC}"
    echo "To push manually:"
    echo "  git push origin main"
    echo "  git push origin ${TAG}"
fi
