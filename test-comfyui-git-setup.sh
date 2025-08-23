#!/bin/bash
echo "🧪 TEST RAPIDE DE CONFIGURATION GIT COMFYUI"
echo "============================================"

# Créer un répertoire de test temporaire
TEST_DIR="/tmp/comfyui-git-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📂 Test dans: $TEST_DIR"
echo ""

# Simuler la procédure d'installation
echo "1️⃣ Initialisation du repository Git..."
git init

echo "2️⃣ Ajout du remote origin..."
git remote add origin https://github.com/comfyanonymous/ComfyUI.git

echo "3️⃣ Fetch des branches distantes..."
if git fetch --all --tags; then
    echo "✅ Fetch réussi"
else
    echo "❌ Échec du fetch"
    exit 1
fi

echo "4️⃣ Vérification d'origin/master..."
if git show-ref --verify --quiet refs/remotes/origin/master; then
    echo "✅ origin/master trouvé"
else
    echo "❌ origin/master non trouvé"
    echo "Branches disponibles:"
    git branch -r
    exit 1
fi

echo "5️⃣ Création de la branche master locale..."
if git checkout -b master origin/master; then
    echo "✅ Branche master créée avec succès"
else
    echo "❌ Échec de création de la branche master"
    exit 1
fi

echo "6️⃣ Configuration du tracking..."
if git branch --set-upstream-to=origin/master master; then
    echo "✅ Tracking configuré"
else
    echo "❌ Échec du tracking"
    exit 1
fi

echo "7️⃣ Vérification finale..."
echo "Branche actuelle: $(git branch --show-current)"
echo "Upstream: $(git rev-parse --abbrev-ref master@{upstream})"

echo ""
echo "🎉 TEST RÉUSSI!"
echo "La configuration Git fonctionne correctement."
echo ""
echo "🧹 Nettoyage..."
cd /
rm -rf "$TEST_DIR"
echo "✅ Répertoire de test supprimé"
