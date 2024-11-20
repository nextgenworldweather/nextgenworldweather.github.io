#!/bin/bash
# Enhanced Git operations script for Linux with advanced features
# Usage: ./git_operations.sh push/pull/status

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed."
    exit 1
fi

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function push_changes() {
    # Check for uncommitted changes
    if [[ -z $(git status -s) ]]; then
        echo -e "${YELLOW}No changes to commit.${NC}"
        exit 0
    fi

    echo -e "${YELLOW}Enter your commit message:${NC}"
    read -r commitMessage

    if [ -z "$commitMessage" ]; then
        echo -e "${RED}Error: Commit message cannot be empty.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Checking repository status...${NC}"
    git fetch origin

    echo -e "${GREEN}Pushing changes to GitHub...${NC}"
    git add .
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to stage changes.${NC}"
        exit 1
    fi

    git commit -m "$commitMessage"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Commit failed.${NC}"
        exit 1
    fi

    git push origin main
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Push failed. Attempting to pull and merge...${NC}"
        git pull --rebase origin main
        if [ $? -ne 0 ]; then
            echo -e "${RED}Merge failed. Resolve conflicts manually.${NC}"
            exit 1
        fi
        git push origin main
    fi

    echo -e "${GREEN}Push successful!${NC}"
}

function pull_changes() {
    echo -e "${GREEN}Fetching latest changes...${NC}"
    git fetch origin

    echo -e "${GREEN}Pulling changes from GitHub...${NC}"
    git pull origin main
    if [ $? -ne 0 ]; then
        echo -e "${RED}Pull failed. Possible merge conflicts.${NC}"
        echo "Try resolving conflicts manually or use 'git mergetool'."
        exit 1
    fi

    echo -e "${GREEN}Pull successful!${NC}"
}

function check_status() {
    echo -e "${GREEN}Checking Git repository status...${NC}"
    git status
}

# Main script execution
case "$1" in
    push)
        push_changes
        ;;
    pull)
        pull_changes
        ;;
    status)
        check_status
        ;;
    *)
        echo "Usage: $0 [push|pull|status]"
        echo
        echo "Options:"
        echo "  push   - Stage, commit, and push changes"
        echo "  pull   - Fetch and merge changes from remote"
        echo "  status - Check git repository status"
        exit 1
        ;;
esac