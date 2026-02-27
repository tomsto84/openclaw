#!/bin/bash
# Auto-sync script: crée une PR et merge automatiquement les changements locaux

set -e

REPO_DIR="/Users/openclaw/.openclaw"
REPO="tomsto84/openclaw"
BRANCH_PREFIX="auto-sync"

cd "$REPO_DIR"

# Vérifier s'il y a des changements
if git diff --quiet HEAD && git diff --cached --quiet HEAD; then
    exit 0
fi

# Créer une branche avec timestamp
BRANCH_NAME="${BRANCH_PREFIX}-$(date +%Y%m%d-%H%M%S)"
git checkout -b "$BRANCH_NAME"

# Commit tous les changements
git add -A
git commit -m "auto: sync workspace changes $(date +%Y-%m-%d\ %H:%M)"

# Push la branche
git push origin "$BRANCH_NAME"

# Créer la PR
PR_URL=$(gh pr create --repo "$REPO" --title "Auto-sync: $(date +%Y-%m-%d\ %H:%M)" --body "🤖 Sync automatique des changements du workspace" --base main --head "$BRANCH_NAME")

# Extraire le numéro de PR
PR_NUMBER=$(echo "$PR_URL" | grep -oE '[0-9]+$')

# Attendre un peu que la PR soit prête
sleep 2

# Essayer de merger - si ça échoue, on tente un merge direct
if ! gh pr merge "$PR_NUMBER" --repo "$REPO" --squash --delete-branch 2>/dev/null; then
    # Fallback: merger via l'API si auto-merge échoue
    echo "⚠️ Auto-merge failed, trying direct merge..."
    gh api "repos/$REPO/pulls/$PR_NUMBER/merge" -X PUT -F merge_method=squash >/dev/null || true
fi

# Retourner sur main
git checkout main
git pull origin main

# Nettoyer les branches locales mortes
git fetch --prune origin
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d 2>/dev/null || true
git branch -D "$BRANCH_NAME" 2>/dev/null || true

echo "✅ Sync terminé: $PR_URL"
