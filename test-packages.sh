#!/bin/bash
set -e

echo "🔧 Test d'installation séquentielle des packages..."

# Packages de base (peu de risques)
BASIC_PACKAGES="einops safetensors jupyterlab ipywidgets"

# Packages à risque (compilation CUDA)
RISKY_PACKAGES="flash-attn triton xformers"

# Package suspect
SUSPECT_PACKAGE="torch-audio-addons"

echo "📦 Installation des packages de base..."
pip install $BASIC_PACKAGES
echo "✅ Packages de base installés avec succès"

echo "🔥 Test du package suspect..."
if pip install $SUSPECT_PACKAGE; then
    echo "✅ $SUSPECT_PACKAGE installé avec succès"
else
    echo "❌ $SUSPECT_PACKAGE a échoué - probable cause de l'erreur"
fi

echo "⚡ Installation des packages à risque un par un..."
for package in $RISKY_PACKAGES; do
    echo "Installation de $package..."
    if pip install $package --no-build-isolation; then
        echo "✅ $package installé avec succès"
    else
        echo "❌ $package a échoué"
        exit 1
    fi
done
