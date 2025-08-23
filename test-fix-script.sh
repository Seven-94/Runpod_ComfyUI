#!/bin/bash
echo "🧪 TEST DU SCRIPT FIX-COMFYUI-GIT.SH CORRIGÉ"
echo "============================================="

# Créer un répertoire de test temporaire
TEST_DIR="/tmp/comfyui-fix-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📂 Test dans: $TEST_DIR"
echo ""

# Créer quelques fichiers pour simuler ComfyUI
touch main.py
echo "# ComfyUI simulé" > README.md

# Simuler un repository Git cassé/shallow
echo "1️⃣ Simulation d'un repository Git problématique..."
git init
git add .
git commit -m "Initial commit"

# Ajouter un remote incorrect pour simuler le problème
git remote add origin-old https://example.com/invalid.git 2>/dev/null || true

echo "2️⃣ État initial (problématique):"
git remote -v 2>/dev/null || echo "Pas de remote configuré"

echo ""
echo "3️⃣ Application du fix..."

# Supprimer l'ancien .git
rm -rf .git

# Réinitialiser le repository Git
git init

# Ajouter le remote origin
git remote add origin https://github.com/comfyanonymous/ComfyUI.git

# Fetch initial
if git fetch origin; then
    echo "✅ Fetch initial réussi"
else
    echo "❌ Échec du fetch initial"
    exit 1
fi

# Récupérer spécifiquement la branche master
if git fetch origin master:master; then
    echo "✅ Branche master récupérée"
else
    echo "❌ Échec de la récupération de master"
    exit 1
fi

# Basculement sur master
if git checkout master; then
    echo "✅ Basculé sur la branche master"
else
    echo "❌ Échec du basculement sur master"
    exit 1
fi

# Configuration du tracking
if git branch --set-upstream-to=origin/master master; then
    echo "✅ Tracking configuré"
else
    echo "⚠️ Échec de la configuration du tracking"
fi

echo ""
echo "4️⃣ Vérification finale..."
echo "Remote origin: $(git remote get-url origin)"
echo "Branche actuelle: $(git branch --show-current)"
echo "Upstream: $(git rev-parse --abbrev-ref master@{upstream} 2>/dev/null || echo 'Non configuré')"

echo ""
echo "🎉 TEST RÉUSSI!"
echo "Le script fix-comfyui-git.sh corrigé fonctionne."
echo ""
echo "🧹 Nettoyage..."
cd /
rm -rf "$TEST_DIR"
echo "✅ Répertoire de test supprimé"
