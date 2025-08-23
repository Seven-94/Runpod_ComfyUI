#!/bin/bash
echo "🔧 CORRECTION DU REPOSITORY GIT COMFYUI"
echo "======================================"

cd /workspace/ComfyUI

echo "📋 État actuel du repository Git:"
if [ -d ".git" ]; then
    echo "✅ Répertoire .git présent"
    
    if git remote get-url origin >/dev/null 2>&1; then
        echo "✅ Remote origin configuré: $(git remote get-url origin)"
    else
        echo "❌ Remote origin non configuré"
    fi
    
    echo "Branches disponibles:"
    git branch -a 2>/dev/null || echo "❌ Impossible de lister les branches"
    
    echo "Branche actuelle:"
    git branch --show-current 2>/dev/null || echo "❌ Aucune branche active"
else
    echo "❌ Répertoire .git absent"
fi

echo ""
echo "🚀 Reconfiguration du repository Git..."

# Sauvegarder les modifications locales s'il y en a
if [ -d ".git" ]; then
    echo "Sauvegarde des modifications locales..."
    git add . 2>/dev/null || true
    git stash push -m "Backup before git reconfiguration" 2>/dev/null || true
fi

# Supprimer l'ancien .git
echo "Suppression de l'ancien repository Git..."
rm -rf .git

# Réinitialiser le repository Git
echo "Réinitialisation du repository Git..."
git init

# Ajouter le remote origin
echo "Configuration du remote origin..."
git remote add origin https://github.com/comfyanonymous/ComfyUI.git

# Fetch toutes les branches et tags
echo "Récupération des branches distantes..."
if git fetch --all --tags; then
    echo "✅ Fetch réussi"
    echo "Branches distantes disponibles:"
    git branch -r
else
    echo "❌ Échec du fetch"
    exit 1
fi

# Vérifier que origin/master existe
echo "Vérification de l'existence d'origin/master..."
if git show-ref --verify --quiet refs/remotes/origin/master; then
    echo "✅ origin/master trouvé"
else
    echo "❌ origin/master non trouvé"
    echo "Branches distantes disponibles:"
    git branch -r
    exit 1
fi

# Checkout de la branche master
echo "Configuration de la branche master..."
if git show-ref --verify --quiet refs/heads/master; then
    echo "Branche master locale existe déjà"
    git checkout master
    echo "✅ Basculé sur la branche master existante"
else
    echo "Création de la branche master..."
    if git checkout -b master origin/master; then
        echo "✅ Branche master créée et configurée"
    else
        echo "❌ Échec de la création de la branche master"
        exit 1
    fi
fi

# S'assurer que la branche master suit origin/master
echo "Configuration du tracking de la branche master..."
if git branch --set-upstream-to=origin/master master; then
    echo "✅ Tracking configuré"
else
    echo "⚠️ Échec de la configuration du tracking"
fi

# Vérification finale
echo ""
echo "✅ VÉRIFICATION FINALE:"
echo "Remote origin: $(git remote get-url origin)"
echo "Branche actuelle: $(git branch --show-current)"
echo "Branches disponibles:"
git branch -a

echo ""
echo "🎉 Correction terminée!"
echo "ComfyUI-Manager devrait maintenant pouvoir effectuer les mises à jour."
echo ""
echo "📋 Pour tester:"
echo "1. Redémarrez ComfyUI"
echo "2. Rafraîchissez votre navigateur"
echo "3. Essayez la fonction de mise à jour dans ComfyUI-Manager"
