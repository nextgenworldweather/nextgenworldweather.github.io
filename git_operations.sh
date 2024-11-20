#!/bin/bash
# Enhanced Git push script with advanced conflict resolution
# Version 2.1.0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Conflict resolution function
resolve_conflicts() {
    echo -e "${YELLOW}Conflicts detected. Starting interactive resolution...${NC}"

    # List conflicting files
    echo "Conflicting files:"
    conflicting_files=$(git diff --name-only --diff-filter=U)
    
    if [ -z "$conflicting_files" ]; then
        echo "No conflicts found."
        return 0
    fi

    echo "$conflicting_files"

    # Conflict resolution menu
    while true; do
        echo -e "${YELLOW}Conflict Resolution Options:${NC}"
        echo "1. Open conflicting files in VS Code"
        echo "2. Use 'git mergetool'"
        echo "3. Manually resolve conflicts"
        echo "4. Abort merge"
        read -p "Select option (1-4): " choice

        case $choice in
            1)
                code .
                manual_resolution_prompt
                break
                ;;
            2)
                git mergetool
                merge_complete
                break
                ;;
            3)
                manual_resolution_prompt
                break
                ;;
            4)
                git merge --abort
                echo -e "${RED}Merge aborted.${NC}"
                exit 1
                ;;
            *)
                echo -e "${RED}Invalid option. Try again.${NC}"
                ;;
        esac
    done
}

manual_resolution_prompt() {
    echo -e "${YELLOW}IMPORTANT: After resolving conflicts:${NC}"
    echo "1. Remove conflict markers (<<<<<<<, =======, >>>>>>>)"
    echo "2. Save files"
    echo "3. Stage resolved files with 'git add'"
    echo "4. Complete merge with 'git commit'"
    read -p "Press Enter when ready to continue..."
    merge_complete
}

merge_complete() {
    git status
    read -p "Have you resolved all conflicts? (y/n): " confirmed
    if [[ "$confirmed" =~ ^[Yy]$ ]]; then
        git add .
        git commit -m "Resolved merge conflicts"
    else
        resolve_conflicts
    fi
}

advanced_push() {
    # Check for uncommitted changes
    if [[ -z $(git status -s) ]]; then
        echo -e "${YELLOW}No local changes to commit.${NC}"
        return 0
    fi

    # Interactive commit message
    while true; do
        read -p "Enter commit message: " commitMessage
        if [ -n "$commitMessage" ]; then
            break
        fi
        echo -e "${RED}Commit message cannot be empty.${NC}"
    done

    # Fetch latest changes
    echo -e "${GREEN}Fetching latest changes...${NC}"
    git fetch origin

    # Stage and commit changes
    git add .
    git commit -m "$commitMessage"

    # Push with conflict handling
    if ! git push origin main; then
        echo -e "${YELLOW}Push failed. Attempting to resolve...${NC}"
        if ! git pull --rebase origin main; then
            resolve_conflicts
        fi
        
        git push origin main
    fi

    echo -e "${GREEN}Push completed successfully.${NC}"
}

# Execute the push function
advanced_push