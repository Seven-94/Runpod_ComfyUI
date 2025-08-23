#!/bin/bash
echo "🧪 TEST DE LA NOUVELLE APPROCHE PRE_START.SH"
echo "============================================="

# Créer un répertoire de test temporaire
TEST_DIR="/tmp/comfyui-prestart-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📂 Test dans: $TEST_DIR"
echo ""

# Simuler la procédure du pre_start.sh
echo "1️⃣ Initialisation du repository Git..."
git init

echo "2️⃣ Ajout du remote origin..."
git remote add origin https://github.com/comfyanonymous/ComfyUI.git

echo "3️⃣ Fetch initial des branches..."
if git fetch origin; then
    echo "✅ Fetch initial réussi"
else
    echo "❌ Échec du fetch initial"
    exit 1
fi

echo "4️⃣ Récupération spécifique de la branche master..."
if git fetch origin master:master; then
    echo "✅ Branche master récupérée"
else
    echo "❌ Impossible de récupérer la branche master"
    exit 1
fi

echo "5️⃣ Basculement sur master..."
if git checkout master; then
    echo "✅ Basculé sur master"
else
    echo "❌ Impossible de basculer sur master"
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
echo "La nouvelle approche fonctionne correctement."
echo ""
echo "🧹 Nettoyage..."
cd /
rm -rf "$TEST_DIR"
echo "✅ Répertoire de test supprimé"
