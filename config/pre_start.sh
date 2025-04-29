#!/bin/bash
set -e

echo "Initialisation de ComfyUI avec volume network..."

# Étape 1: S'assurer que le dossier de base existe
mkdir -p /workspace/ComfyUI

# Étape 2: Vérifier si ComfyUI est déjà installé sur le volume
if [ ! -f "/workspace/ComfyUI/main.py" ]; then
    echo "Installation de ComfyUI dans le volume network..."
    # Copier les fichiers depuis la version préinstallée dans l'image
    cp -r /opt/ComfyUI/* /workspace/ComfyUI/
    cp -r /opt/ComfyUI/.* /workspace/ComfyUI/ 2>/dev/null || true
    
    echo "ComfyUI installé avec succès"
else
    echo "ComfyUI déjà présent dans le volume network"
fi

# Étape 3: Création des répertoires pour les modèles s'ils n'existent pas
mkdir -p /workspace/ComfyUI/models/{checkpoints,clip,clip_vision,controlnet,diffusers,embeddings,loras,upscale_models,vae,unet,text_encoders,diffusion_models}
mkdir -p /workspace/ComfyUI/input
mkdir -p /workspace/ComfyUI/output
mkdir -p /workspace/ComfyUI/custom_nodes

# Étape 4: Copier les fichiers de configuration
cp -f /opt/comfyui_templates/nginx.conf /workspace/ComfyUI/nginx.conf
cp -f /opt/comfyui_templates/extra_model_paths.yml /workspace/ComfyUI/extra_model_paths.yml
cp -f /opt/comfyui_templates/download_models.sh /workspace/ComfyUI/download_models.sh
chmod +x /workspace/ComfyUI/download_models.sh

# Étape 5: Installation ou mise à jour des extensions ComfyUI
echo "Vérification des extensions essentielles..."

# Installation de ComfyUI Manager depuis l'image préinstallée
if [ ! -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Manager" ]; then
    echo "Copie de ComfyUI-Manager depuis l'image..."
    mkdir -p /workspace/ComfyUI/custom_nodes
    cp -r /opt/comfyui_extensions/ComfyUI-Manager /workspace/ComfyUI/custom_nodes/
else
    echo "ComfyUI-Manager déjà installé sur le volume"
fi

# Installation de SDXL Prompt Styler depuis l'image préinstallée
if [ ! -d "/workspace/ComfyUI/custom_nodes/sdxl_prompt_styler" ]; then
    echo "Copie de SDXL Prompt Styler depuis l'image..."
    mkdir -p /workspace/ComfyUI/custom_nodes
    cp -r /opt/comfyui_extensions/sdxl_prompt_styler /workspace/ComfyUI/custom_nodes/
else
    echo "SDXL Prompt Styler déjà installé sur le volume"
fi

# Installation de ComfyUI TensorRT depuis l'image préinstallée
if [ ! -d "/workspace/ComfyUI/custom_nodes/ComfyUI_TensorRT" ]; then
    echo "Copie de ComfyUI TensorRT depuis l'image..."
    mkdir -p /workspace/ComfyUI/custom_nodes
    cp -r /opt/comfyui_extensions/ComfyUI_TensorRT /workspace/ComfyUI/custom_nodes/
else
    echo "ComfyUI TensorRT déjà installé sur le volume"
fi

# Étape 6: Téléchargement des modèles si nécessaire
echo "Vérification des modèles..."
cd /workspace/ComfyUI
./download_models.sh

# Étape 7: S'assurer que extra_model_paths.yml est chargé correctement
echo "Vérification de la configuration des chemins de modèles..."
if [ -f "/workspace/ComfyUI/extra_model_paths.yml" ]; then
    echo "Configuration extra_model_paths.yml trouvée"
    # Créer un lien symbolique dans le répertoire ComfyUI pour s'assurer que le fichier est trouvé
    ln -sf /workspace/ComfyUI/extra_model_paths.yml /workspace/ComfyUI/extra_model_paths.yaml
else
    echo "ERREUR: Fichier extra_model_paths.yml manquant!"
fi

# Étape 8: Démarrage de ComfyUI
echo "Démarrage de ComfyUI..."
cd /workspace/ComfyUI
# Arrêter toute instance précédente de ComfyUI si elle existe
pkill -f "python.*main.py.*--port.*3000" 2>/dev/null || true
# Démarrer une nouvelle instance
nohup python main.py --listen --port 3000 --extra-model-paths-config /workspace/ComfyUI/extra_model_paths.yml > /var/log/comfyui.log 2>&1 &

# Vérification du démarrage
sleep 5
if pgrep -f "python.*main.py.*--port.*3000" > /dev/null; then
    echo "ComfyUI démarré avec succès"
else
    echo "ERREUR: Échec du démarrage de ComfyUI"
    tail -n 20 /var/log/comfyui.log
    exit 1
fi