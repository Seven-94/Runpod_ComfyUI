#!/bin/bash
echo "🔍 DIAGNOSTIC DE CONFIGURATION GIT COMFYUI"
echo "=========================================="

cd /workspace/ComfyUI

echo "📋 Informations sur le repository Git:"
echo "--------------------------------------"

if [ -d ".git" ]; then
    echo "✅ Répertoire .git présent"
    
    # Vérification du remote origin
    if git remote get-url origin >/dev/null 2>&1; then
        echo "✅ Remote origin configuré: $(git remote get-url origin)"
    else
        echo "❌ Remote origin non configuré"
    fi
    
    # Vérification des branches
    echo ""
    echo "Branches locales:"
    git branch 2>/dev/null || echo "❌ Impossible de lister les branches locales"
    
    echo ""
    echo "Branches distantes:"
    git branch -r 2>/dev/null || echo "❌ Impossible de lister les branches distantes"
    
    echo ""
    echo "Branche actuelle:"
    current_branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$current_branch" ]; then
        echo "✅ $current_branch"
    else
        echo "❌ Aucune branche active"
    fi
    
    # Vérification de la branche master
    echo ""
    echo "Configuration de la branche master:"
    if git show-ref --verify --quiet refs/heads/master; then
        echo "✅ Branche master existe localement"
        
        # Vérifier le tracking upstream
        upstream=$(git rev-parse --abbrev-ref master@{upstream} 2>/dev/null)
        if [ -n "$upstream" ]; then
            echo "✅ Upstream configuré: $upstream"
        else
            echo "⚠️ Upstream non configuré pour master"
        fi
    else
        echo "❌ Branche master absente"
    fi
    
    # Vérification des remotes
    echo ""
    echo "Status du repository:"
    git status --porcelain=v1 2>/dev/null || echo "❌ Impossible d'obtenir le status"
    
    # Test de connectivité
    echo ""
    echo "Test de connectivité GitHub:"
    if git ls-remote --exit-code origin HEAD >/dev/null 2>&1; then
        echo "✅ Connexion GitHub OK"
    else
        echo "❌ Problème de connexion GitHub"
    fi
    
else
    echo "❌ Répertoire .git absent - ComfyUI ne peut pas être mis à jour"
fi

echo ""
echo "🔧 RECOMMANDATIONS:"
echo "==================="

if [ ! -d ".git" ]; then
    echo "❌ CRITIQUE: Repository Git non initialisé"
    echo "   Solution: Exécuter /opt/scripts/fix-comfyui-git.sh"
elif ! git show-ref --verify --quiet refs/heads/master; then
    echo "❌ CRITIQUE: Branche master manquante"
    echo "   Solution: Exécuter /opt/scripts/fix-comfyui-git.sh"
elif ! git rev-parse --abbrev-ref master@{upstream} >/dev/null 2>&1; then
    echo "⚠️ ATTENTION: Configuration upstream manquante"
    echo "   Solution: git branch --set-upstream-to=origin/master master"
else
    echo "✅ Configuration Git correcte pour les mises à jour ComfyUI-Manager"
fi

echo ""
echo "Pour corriger automatiquement les problèmes, exécutez:"
echo "cd /workspace && /opt/scripts/fix-comfyui-git.sh"
