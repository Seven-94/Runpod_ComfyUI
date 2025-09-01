#!/bin/bash
set -e

echo "Initialisation de ComfyUI pour RunPod..."

# Vérification de compatibilité CUDA/Driver
echo "Vérification de la compatibilité des drivers NVIDIA..."
if ! nvidia-smi &>/dev/null; then
    echo "❌ ERREUR: nvidia-smi non accessible"
    exit 1
fi

# Vérifier la version du driver NVIDIA
DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
echo "Driver NVIDIA détecté: $DRIVER_VERSION"

# Les drivers 545+ supportent CUDA 12.9
DRIVER_MAJOR=$(echo $DRIVER_VERSION | cut -d. -f1)
if [ "$DRIVER_MAJOR" -lt 545 ]; then
    echo "⚠️  AVERTISSEMENT: Driver NVIDIA $DRIVER_VERSION détecté"
    echo "   Ce serveur pourrait ne pas supporter CUDA 12.9 optimalement"
    echo "   Si vous rencontrez des erreurs, redémarrez le pod pour obtenir un serveur avec drivers plus récents"
fi

# Étape 1: S'assurer que le dossier de base existe
mkdir -p /workspace/ComfyUI

# Étape 2: Installer ou mettre à jour ComfyUI
if [ ! -f "/workspace/ComfyUI/main.py" ]; then
    echo "Installation initiale de ComfyUI depuis l'image Docker..."
    # Copier depuis l'image Docker
    if ! cp -r /opt/ComfyUI/* /workspace/ComfyUI/ 2>/dev/null; then
        echo "ERREUR: Impossible de copier les fichiers ComfyUI"
        exit 1
    fi
    if ! cp -r /opt/ComfyUI/.* /workspace/ComfyUI/ 2>/dev/null; then
        echo "AVERTISSEMENT: Impossible de copier tous les fichiers cachés (normal)"
    fi
    echo "ComfyUI installé avec succès"
fi

# Étape 2.1: Mise à jour automatique vers le dernier tag
# echo "Mise à jour du code ComfyUI vers la dernière version..."
# cd /workspace/ComfyUI
# if [ -d ".git" ]; then
#     git fetch origin
#     git fetch --tags
#     latest_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
#     git checkout $latest_tag
#     git reset --hard $latest_tag
#     echo "ComfyUI mis à jour sur le tag : $latest_tag"
#     if [ -f "comfyui_version.py" ]; then
#         echo "Version ComfyUI utilisée :"
#         grep __version__ comfyui_version.py
#     fi
# else
#     echo "Avertissement : /workspace/ComfyUI n'est pas un dépôt git, mise à jour impossible."
#     if [ -f "comfyui_version.py" ]; then
#         echo "Version ComfyUI actuelle :"
#         grep __version__ comfyui_version.py
#     fi
# fi

# Étape 2.2: Installation de HuggingFace Hub pour le téléchargement de modèles
echo "Installation/mise à jour de HuggingFace Hub..."
pip install huggingface_hub[hf_transfer] --quiet
echo "✅ HuggingFace Hub installé avec support de téléchargement rapide"

# Étape 3: Création des répertoires pour les modèles s'ils n'existent pas
mkdir -p /workspace/ComfyUI/models/{checkpoints,clip,clip_vision,controlnet,diffusers,embeddings,loras,upscale_models,vae,unet,text_encoders,diffusion_models,style_models}
mkdir -p /workspace/ComfyUI/input
mkdir -p /workspace/ComfyUI/output
mkdir -p /workspace/ComfyUI/custom_nodes

# Étape 4: Copier les fichiers de configuration
if ! cp -f /opt/comfyui_templates/nginx.conf /workspace/ComfyUI/nginx.conf; then
    echo "ERREUR: Impossible de copier nginx.conf"
    exit 1
fi
if ! cp -f /opt/comfyui_templates/extra_model_paths.yml /workspace/ComfyUI/extra_model_paths.yml; then
    echo "ERREUR: Impossible de copier extra_model_paths.yml"
    exit 1
fi

# Étape 5: Installation des extensions essentielles
echo "Vérification des extensions essentielles..."

# Installation de ComfyUI Manager
if [ ! -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Manager" ]; then
    echo "Installation de ComfyUI-Manager..."
    if ! cp -r /opt/comfyui_extensions/ComfyUI-Manager /workspace/ComfyUI/custom_nodes/; then
        echo "ERREUR: Impossible d'installer ComfyUI-Manager"
        exit 1
    fi
else
    echo "ComfyUI-Manager déjà installé"
fi

# Installation de ComfyUI-Crystools
if [ ! -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Crystools" ]; then
    echo "Installation de ComfyUI-Crystools..."
    if ! cp -r /opt/comfyui_extensions/ComfyUI-Crystools /workspace/ComfyUI/custom_nodes/; then
        echo "ERREUR: Impossible d'installer ComfyUI-Crystools"
        exit 1
    fi
else
    echo "ComfyUI-Crystools déjà installé"
fi

# Installation de ComfyUI-KJNodes
if [ ! -d "/workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes" ]; then
    echo "Installation de ComfyUI-KJNodes..."
    if ! cp -r /opt/comfyui_extensions/ComfyUI-KJNodes /workspace/ComfyUI/custom_nodes/; then
        echo "ERREUR: Impossible d'installer ComfyUI-KJNodes"
        exit 1
    fi
else
    echo "ComfyUI-KJNodes déjà installé"
fi

# Étape 6: Configuration des chemins de modèles
echo "Configuration des chemins de modèles..."
if [ -f "/workspace/ComfyUI/extra_model_paths.yml" ]; then
    echo "Configuration extra_model_paths.yml trouvée"
    # Créer un lien symbolique dans le répertoire ComfyUI pour s'assurer que le fichier est trouvé
    ln -sf /workspace/ComfyUI/extra_model_paths.yml /workspace/ComfyUI/extra_model_paths.yaml
else
    echo "AVERTISSEMENT: Fichier extra_model_paths.yml manquant!"
fi

# Étape 7: Démarrage de ComfyUI avec optimisations Blackwell
echo "Démarrage de ComfyUI avec optimisations GPU Blackwell..."
cd /workspace/ComfyUI

# S'assurer que le répertoire de logs existe
mkdir -p /var/log

# Arrêter toute instance précédente de ComfyUI si elle existe
pkill -f "python.*main.py.*--port.*8188" 2>/dev/null || true

# Démarrer ComfyUI avec optimisations pour Blackwell
nohup python main.py \
    --listen \
    --port 8188 \
    --extra-model-paths-config /workspace/ComfyUI/extra_model_paths.yml \
    --force-fp16 \
    --use-split-cross-attention \
    --enable-cors-header \
    > /var/log/comfyui.log 2>&1 &

# Vérification du démarrage
sleep 5
if pgrep -f "python.*main.py.*--port.*8188" > /dev/null; then
    echo "ComfyUI démarré avec succès"
    echo "✅ Extensions installées : ComfyUI-Manager, ComfyUI-Crystools, ComfyUI-KJNodes"
    echo "🚀 Optimisations Blackwell activées"
else
    echo "ERREUR: Échec du démarrage de ComfyUI"
    tail -n 20 /var/log/comfyui.log
    exit 1
fi