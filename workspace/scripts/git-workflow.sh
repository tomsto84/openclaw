#!/bin/bash
# Git workflow helper - Feature branch workflow

set -e

REPO_DIR="/Users/openclaw/.openclaw"
REPO="tomsto84/openclaw"

cd "$REPO_DIR"

show_help() {
    echo "Usage: git-workflow.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  branch <type>/<name>  - Create a new feature branch (feat/fix/chore/docs)"
    echo "  commit [message]      - Commit current changes (auto-message if empty)"
    echo "  push                  - Push current branch to origin"
    echo "  pr                    - Create a PR for current branch"
    echo "  merge                 - Merge current branch to main (via PR)"
    echo "  sync                  - Pull latest main and rebase current branch"
    echo "  status                - Show current git status"
    echo "  switch <branch>       - Switch to branch (stash changes if needed)"
    echo "  done                  - Shortcut: commit, push, create PR"
    echo ""
    echo "Examples:"
    echo "  git-workflow.sh branch feat/add-calendar-sync"
    echo "  git-workflow.sh commit \"Add calendar integration\""
    echo "  git-workflow.sh done"
    echo "  git-workflow.sh merge"
}

create_branch() {
    local branch_name=$1
    
    # Validate branch name format
    if [[ ! "$branch_name" =~ ^(feat|fix|chore|docs|refactor|test)/ ]]; then
        echo "❌ Branch name must start with feat/, fix/, chore/, docs/, refactor/, or test/"
        echo "   Example: feat/add-calendar-sync"
        exit 1
    fi
    
    # Stash any current changes
    if ! git diff --quiet HEAD || ! git diff --cached --quiet HEAD; then
        echo "💾 Stashing current changes..."
        git stash push -m "Auto-stash before switching to $branch_name"
    fi
    
    # Switch to main and pull
    git checkout main 2>/dev/null || git checkout -b main
    git pull origin main
    
    # Create and switch to new branch
    git checkout -b "$branch_name"
    echo "✅ Created and switched to branch: $branch_name"
}

commit_changes() {
    local message="${1:-$(date +'%Y-%m-%d %H:%M') - auto commit}"
    
    if git diff --quiet HEAD && git diff --cached --quiet HEAD; then
        echo "ℹ️ No changes to commit"
        return 0
    fi
    
    git add -A
    git commit -m "$message"
    echo "✅ Committed: $message"
}

push_branch() {
    local branch=$(git branch --show-current)
    git push -u origin "$branch"
    echo "✅ Pushed $branch to origin"
}

create_pr() {
    local branch=$(git branch --show-current)
    local pr_url
    
    # Get commit message for PR title
    local title=$(git log -1 --pretty=%s)
    
    pr_url=$(gh pr create --repo "$REPO" --title "$title" --body "📝 Changes from $branch" --base main --head "$branch")
    echo "✅ Created PR: $pr_url"
}

merge_branch() {
    local branch=$(git branch --show-current)
    
    if [ "$branch" = "main" ]; then
        echo "❌ Already on main. Switch to a feature branch first."
        exit 1
    fi
    
    # Push first
    git push origin "$branch"
    
    # Create PR and merge
    local pr_url=$(gh pr create --repo "$REPO" --title "$branch" --body "📝 Ready to merge $branch" --base main --head "$branch")
    local pr_number=$(echo "$pr_url" | grep -oE '[0-9]+$')
    
    gh pr merge "$pr_number" --repo "$REPO" --squash --delete-branch
    
    # Switch back to main
    git checkout main
    git pull origin main
    
    echo "✅ Merged $branch to main"
}

sync_branch() {
    local branch=$(git branch --show-current)
    
    git fetch origin
    git pull origin main --rebase || {
        echo "⚠️ Rebase failed. Resolve conflicts manually."
        exit 1
    }
    echo "✅ Synced with main"
}

show_status() {
    echo "=== Git Status ==="
    git status
    echo ""
    echo "=== Recent commits ==="
    git log --oneline -5
    echo ""
    echo "=== Branch ==="
    git branch -vv
}

switch_branch() {
    local target=$1
    
    # Stash changes if any
    if ! git diff --quiet HEAD || ! git diff --cached --quiet HEAD; then
        echo "💾 Stashing changes..."
        git stash
    fi
    
    git checkout "$target"
    echo "✅ Switched to $target"
}

done_workflow() {
    commit_changes
    push_branch
    create_pr
    echo ""
    echo "🎉 Done! PR created. Review and merge when ready."
}

# Main
case "${1:-help}" in
    branch|b)
        create_branch "$2"
        ;;
    commit|c)
        commit_changes "$2"
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
