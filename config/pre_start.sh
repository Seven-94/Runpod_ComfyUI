#!/bin/bash

# Création des répertoires de modèles dans l'espace de travail s'ils n'existent pas
mkdir -p /workspace/ComfyUI/models/{checkpoints,clip,clip_vision,controlnet,diffusers,embeddings,loras,upscale_models,vae,unet,configs,text_encoders,diffusion_models}

# Tentative de téléchargement des modèles requis
/workspace/ComfyUI/download_models.sh

cd /workspace/ComfyUI
nohup python main.py --listen --port 3000 >> /dev/stdout 2>&1 &

# S'assurer que le processus est démarré
sleep 2
if ! pgrep -f "python.*main.py.*--port.*3000" > /dev/null; then
    echo "Failed to start ComfyUI"
    exit 1
fi