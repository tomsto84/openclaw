#!/bin/bash
# Git workflow helper - Feature branch workflow avec Conventional Commits
# Usage: git-workflow.sh <command> [args]

set -e

REPO_DIR="/Users/openclaw/.openclaw"
REPO="tomsto84/openclaw"

cd "$REPO_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${BLUE}Git Workflow - Feature Branch Strategy${NC}"
    echo ""
    echo "Usage: git-workflow.sh <command> [args]"
    echo ""
    echo -e "${YELLOW}Workflow:${NC}"
    echo "  branch → work → commit → push → PR → merge"
    echo ""
    echo -e "${YELLOW}Commands:${NC}"
    echo "  branch <type>/<name>   Create feature branch"
    echo "  commit [type] [scope] [msg]  Commit with Conventional Commits"
    echo "  push                   Push current branch"
    echo "  pr                     Create PR for current branch"
    echo "  merge                  Merge via PR (prompts for confirmation)"
    echo "  sync                   Sync with main (rebase)"
    echo "  status                 Show git status"
    echo "  switch <branch>        Switch to branch"
    echo "  done                   Commit + push + create PR"
    echo "  help                   Show this help"
    echo ""
    echo -e "${YELLOW}Branch prefixes:${NC}"
    echo "  feat/     - New feature"
    echo "  fix/      - Bug fix"
    echo "  docs/     - Documentation"
    echo "  chore/    - Maintenance"
    echo "  refactor/ - Refactoring"
    echo "  test/     - Tests"
    echo ""
    echo -e "${YELLOW}Commit types:${NC}"
    echo "  feat fix docs style refactor perf test chore ci revert"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  git-workflow.sh branch feat/add-calendar-sync"
    echo "  git-workflow.sh commit feat workspace \"add calendar integration\""
    echo "  git-workflow.sh done"
    echo "  git-workflow.sh merge"
}

validate_branch_name() {
    local name=$1
    if [[ ! "$name" =~ ^(feat|fix|docs|chore|refactor|test|hotfix)/[a-z0-9-]+$ ]]; then
        echo -e "${RED}❌ Invalid branch name format${NC}"
        echo ""
        echo "Must be: <type>/<description>"
        echo ""
        echo "Types: feat, fix, docs, chore, refactor, test, hotfix"
        echo "Description: lowercase, hyphens only"
        echo ""
        echo "Examples:"
        echo "  feat/add-calendar-sync"
        echo "  fix/memory-leak-parser"
        echo "  docs/api-reference"
        exit 1
    fi
}

get_commit_type() {
    local branch=$1
    if [[ "$branch" =~ ^(feat|fix|docs|chore|refactor|test|hotfix)/ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "chore"
    fi
}

create_branch() {
    local branch_name=$1
    
    validate_branch_name "$branch_name"
    
    # Stash any current changes
    if ! git diff --quiet HEAD 2>/dev/null || ! git diff --cached --quiet HEAD 2>/dev/null; then
        echo -e "${YELLOW}💾 Stashing current changes...${NC}"
        git stash push -m "Auto-stash before $branch_name"
    fi
    
    # Switch to main and pull
    git checkout main 2>/dev/null || git checkout -b main
    
    echo -e "${BLUE}📥 Pulling latest main...${NC}"
    git pull origin main
    
    # Create and switch to new branch
    git checkout -b "$branch_name"
    echo ""
    echo -e "${GREEN}✅ Created branch: $branch_name${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Make your changes"
    echo "  2. git-workflow.sh commit <type> <scope> \"message\""
    echo "  3. git-workflow.sh done"
}

commit_changes() {
    local type="${1:-}"
    local scope="${2:-}"
    local message="${3:-}"
    
    # If no args, use interactive commit helper
    if [ -z "$type" ]; then
        ~/workspace/scripts/commit.sh
        return 0
    fi
    
    # Validate type
    local valid_types="feat fix docs style refactor perf test chore ci revert"
    if [[ ! " $valid_types " =~ " $type " ]]; then
        echo -e "${RED}❌ Invalid commit type: $type${NC}"
        echo "Valid types: $valid_types"
        exit 1
    fi
    
    # Build commit message
    if [ -n "$scope" ]; then
        full_message="$type($scope): $message"
    else
        full_message="$type: $message"
    fi
    
    if git diff --quiet HEAD && git diff --cached --quiet HEAD; then
        echo -e "${YELLOW}ℹ️ No changes to commit${NC}"
        return 0
    fi
    
    git add -A
    git commit -m "$full_message"
    echo -e "${GREEN}✅ Committed: $full_message${NC}"
}

push_branch() {
    local branch=$(git branch --show-current)
    
    if [ "$branch" = "main" ]; then
        echo -e "${RED}❌ Cannot push to main directly${NC}"
        echo "Create a feature branch first: git-workflow.sh branch feat/xxx"
        exit 1
    fi
    
    git push -u origin "$branch"
    echo -e "${GREEN}✅ Pushed $branch to origin${NC}"
}

create_pr() {
    local branch=$(git branch --show-current)
    
    if [ "$branch" = "main" ]; then
        echo -e "${RED}❌ Cannot create PR from main${NC}"
        exit 1
    fi
    
    # Get commit message for PR title (first line only)
    local title=$(git log -1 --pretty=%s)
    
    # Build PR body
    local body="🤖 Automated PR from \`$branch\`

## Changes
$(git log main..HEAD --oneline --no-decorate | sed 's/^/- /')

---
*Generated by git-workflow.sh*"
    
    local pr_url=$(gh pr create --repo "$REPO" --title "$title" --body "$body" --base main --head "$branch")
    echo -e "${GREEN}✅ Created PR: $pr_url${NC}"
}

merge_branch() {
    local branch=$(git branch --show-current)
    
    if [ "$branch" = "main" ]; then
        echo -e "${RED}❌ Already on main. Switch to a feature branch.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}⚠️ About to merge '$branch' to main${NC}"
    echo ""
    echo "Commits to be merged:"
    git log main..HEAD --oneline --no-decorate | sed 's/^/  /'
    echo ""
    read -rp "Continue with merge? [y/N] " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}❌ Merge cancelled${NC}"
        exit 0
    fi
    
    # Push first
    git push origin "$branch"
    
    # Create PR and merge
    local title=$(git log -1 --pretty=%s)
    local pr_url=$(gh pr create --repo "$REPO" --title "$title" --body "Ready to merge $branch" --base main --head "$branch")
    local pr_number=$(echo "$pr_url" | grep -oE '[0-9]+$')
    
    echo -e "${BLUE}🔄 Merging PR #$pr_number...${NC}"
    gh pr merge "$pr_number" --repo "$REPO" --squash --delete-branch
    
    # Switch back to main
    git checkout main
    git pull origin main
    
    echo ""
    echo -e "${GREEN}✅ Merged $branch to main${NC}"
}

sync_branch() {
    local branch=$(git branch --show-current)
    
    echo -e "${BLUE}🔄 Syncing with main...${NC}"
    git fetch origin
    
    if ! git pull origin main --rebase; then
        echo -e "${RED}⚠️ Rebase failed. Resolve conflicts manually.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Synced with main${NC}"
}

show_status() {
    local branch=$(git branch --show-current)
    
    echo -e "${BLUE}=== Repository Status ===${NC}"
    echo ""
    echo -e "Branch: ${YELLOW}$branch${NC}"
    echo ""
    
    if [ "$branch" != "main" ]; then
        echo -e "${BLUE}Commits ahead of main:${NC}"
        git log main..HEAD --oneline --no-decorate 2>/dev/null | head -5 || echo "  (none)"
        echo ""
    fi
    
    echo -e "${BLUE}Modified files:${NC}"
    git status --short
    echo ""
    
    echo -e "${BLUE}Recent commits:${NC}"
    git log --oneline -3
}

switch_branch() {
    local target=$1
    
    if [ -z "$target" ]; then
        echo -e "${RED}❌ Branch name required${NC}"
        exit 1
    fi
    
    # Stash changes if any
    if ! git diff --quiet HEAD 2>/dev/null || ! git diff --cached --quiet HEAD 2>/dev/null; then
        echo -e "${YELLOW}💾 Stashing changes...${NC}"
        git stash
    fi
    
    git checkout "$target"
    echo -e "${GREEN}✅ Switched to $target${NC}"
}

done_workflow() {
    local branch=$(git branch --show-current)
    
    if [ "$branch" = "main" ]; then
        echo -e "${RED}❌ Cannot run 'done' on main${NC}"
        echo "Create a feature branch first"
        exit 1
    fi
    
    echo -e "${BLUE}🚀 Running 'done' workflow...${NC}"
    echo ""
    
    # If no commits yet, suggest one
    if git diff --quiet HEAD && git diff --cached --quiet HEAD; then
        echo -e "${YELLOW}No changes to commit${NC}"
        return 0
    fi
    
    # Auto-detect commit type from branch name
    local auto_type=$(get_commit_type "$branch")
    
    echo -e "Suggested commit type: ${YELLOW}$auto_type${NC}"
    echo ""
    
    # Use commit helper if interactive
    if [ -t 0 ]; then
        ~/workspace/scripts/commit.sh
    else
        # Non-interactive fallback
        git add -A
        git commit -m "$auto_type: update from $branch"
    fi
    
    push_branch
    create_pr
    
    echo ""
    echo -e "${GREEN}🎉 Done! Review and merge when ready.${NC}"
    echo "To merge: git-workflow.sh merge"
}

# Main
case "${1:-help}" in
    branch|b)
        create_branch "$2"
        ;;
    commit|c)
        shift
        commit_changes "$@"
        ;;
    push|p)
        push_branch
        ;;
    pr)
        create_pr
        ;;
    merge|m)
        merge_branch
        ;;
    sync|s)
        sync_branch
        ;;
    status|st)
        show_status
        ;;
    switch|sw)
        switch_branch "$2"
        ;;
    done|d)
        done_workflow
        ;;
    help|h|*)
        show_help
        ;;
esac
