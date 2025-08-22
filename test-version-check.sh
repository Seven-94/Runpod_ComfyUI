#!/bin/bash
set -e

# Script de test pour la détection automatique de nouvelles versions ComfyUI
# Utilisé pour tester la logique avant les GitHub Actions

echo "🔍 Test de détection de version ComfyUI"
echo "======================================="

# Récupérer la dernière version de ComfyUI depuis GitHub API
echo "📡 Récupération de la dernière version ComfyUI..."
LATEST_COMFYUI=$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/releases/latest | jq -r .tag_name)
echo "   └─ Dernière version: $LATEST_COMFYUI"

# Récupérer notre version actuelle depuis le fichier VERSION
CURRENT_VERSION=$(cat VERSION)
echo "📦 Version actuelle du conteneur: $CURRENT_VERSION"

# Construire le tag de l'image
IMAGE_TAG="${CURRENT_VERSION}-comfyui-${LATEST_COMFYUI}"
echo "🏷️  Tag de l'image qui serait créé: $IMAGE_TAG"

# Simuler la vérification Docker Hub (sans vraie vérification)
echo "🐳 Vérification de l'existence sur Docker Hub..."
echo "   └─ URL à vérifier: https://hub.docker.com/v2/repositories/USERNAME/runpod-comfyui/tags/${IMAGE_TAG}/"

# Vérifier si le Dockerfile contient déjà cette version
DOCKERFILE_VERSION=$(grep "ARG COMFYUI_VERSION=" Dockerfile | cut -d'=' -f2)
echo "📄 Version dans le Dockerfile: $DOCKERFILE_VERSION"

if [ "$DOCKERFILE_VERSION" = "$LATEST_COMFYUI" ]; then
    echo "✅ Le Dockerfile est à jour"
    NEEDS_UPDATE="false"
else
    echo "⚠️  Le Dockerfile doit être mis à jour"
    NEEDS_UPDATE="true"
fi

# Résumé
echo ""
echo "📊 RÉSUMÉ"
echo "========="
echo "Dernière version ComfyUI: $LATEST_COMFYUI"
echo "Version dans Dockerfile:   $DOCKERFILE_VERSION"
echo "Tag d'image:              $IMAGE_TAG"
echo "Mise à jour nécessaire:   $NEEDS_UPDATE"

# Test de mise à jour du Dockerfile (simulation)
if [ "$NEEDS_UPDATE" = "true" ]; then
    echo ""
    echo "🛠️  Simulation de mise à jour du Dockerfile:"
    echo "   sed -i \"s|ARG COMFYUI_VERSION=.*|ARG COMFYUI_VERSION=$LATEST_COMFYUI|g\" Dockerfile"
fi

echo ""
echo "✅ Test terminé!"
