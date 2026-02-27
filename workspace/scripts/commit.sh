#!/bin/bash
# Commit assisté avec Conventional Commits
# Usage: commit.sh [type] [scope] "message"
#        commit.sh                    # Mode interactif

set -e

TYPES=(
    "feat:Nouvelle fonctionnalité"
    "fix:Correction de bug"
    "docs:Documentation"
    "style:Formatage (pas de code)"
    "refactor:Refactoring"
    "perf:Performance"
    "test:Tests"
    "chore:Maintenance/tooling"
    "ci:CI/CD"
    "revert:Annulation"
)

SCOPES=(
    "workspace:Fichiers workspace"
    "scripts:Scripts utilitaires"
    "config:Configuration"
    "memory:Mémoire"
    "tools:Tooling"
    "agents:Agents config"
    "none:Pas de scope"
)

show_types() {
    echo "📋 Types disponibles :"
    for t in "${TYPES[@]}"; do
        IFS=':' read -r type desc <<< "$t"
        printf "  %-10s %s\n" "$type" "$desc"
    done
}

show_scopes() {
    echo "📂 Scopes disponibles :"
    for s in "${SCOPES[@]}"; do
        IFS=':' read -r scope desc <<< "$s"
        printf "  %-10s %s\n" "$scope" "$desc"
    done
}

interactive_mode() {
    echo "🎯 Conventional Commit Helper"
    echo ""
    
    # Show types
    show_types
    echo ""
    
    # Ask for type
    while true; do
        read -rp "Type ? " type
        if echo "${TYPES[@]}" | grep -qw "${type}:"; then
            break
        fi
        echo "❌ Type invalide"
    done
    echo ""
    
    # Show scopes
    show_scopes
    echo ""
    
    # Ask for scope
    read -rp "Scope ? (Entrée pour none) " scope
    scope=${scope:-none}
    if [ "$scope" = "none" ]; then
        scope=""
    fi
    echo ""
    
    # Ask for message
    read -rp "Message : " message
    echo ""
    
    # Ask for body
    read -rp "Corps détaillé ? (Entrée pour ignorer) " body
    
    build_commit "$type" "$scope" "$message" "$body"
}

build_commit() {
    local type=$1
    local scope=$2
    local message=$3
    local body=$4
    
    # Build commit message
    if [ -n "$scope" ]; then
        full_message="$type($scope): $message"
    else
        full_message="$type: $message"
    fi
    
    # Add body if provided
    if [ -n "$body" ]; then
        full_message="$full_message

$body"
    fi
    
    echo "📤 Commit message :"
    echo "---"
    echo "$full_message"
    echo "---"
    echo ""
    
    # Confirm
    read -rp "Confirmer ? [Y/n] " confirm
    if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
        git add -A
        git commit -m "$full_message"
        echo "✅ Commit créé !"
    else
        echo "❌ Annulé"
        exit 1
    fi
}

# Quick mode: commit.sh feat workspace "add new feature"
if [ $# -ge 2 ]; then
    type=$1
    
    # Check if second arg is scope or message
    if [[ "$2" =~ ^(workspace|scripts|config|memory|tools|agents)$ ]]; then
        scope=$2
        message="${*:3}"
    else
        scope=""
        message="${*:2}"
    fi
    
    build_commit "$type" "$scope" "$message" ""
    exit 0
fi

# Interactive mode
interactive_mode
