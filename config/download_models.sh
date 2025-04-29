#!/bin/bash

if [ -z "$HF_TOKEN" ]; then
    echo "ATTENTION: Variable HF_TOKEN non définie. Téléchargement anonyme, risque d'échec."
    AUTH_HEADER=""
else
    echo "Téléchargement avec authentification HuggingFace"
    AUTH_HEADER="--header=\"Authorization: Bearer $HF_TOKEN\""
fi

# Création des répertoires nécessaires
mkdir -p /workspace/ComfyUI/models/text_encoders
mkdir -p /workspace/ComfyUI/models/vae
mkdir -p /workspace/ComfyUI/models/diffusion_models

# Téléchargement des fichiers avec authentification si token disponible
echo "Téléchargement des encodeurs de texte..."
cd /workspace/ComfyUI/models/text_encoders
if [ ! -f t5xxl_fp16.safetensors ]; then
    eval "wget $AUTH_HEADER -O t5xxl_fp16.safetensors \"https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors?download=true\"" || echo "Échec du téléchargement de t5xxl_fp16.safetensors"
fi
if [ ! -f clip_l.safetensors ]; then
    eval "wget $AUTH_HEADER -O clip_l.safetensors \"https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true\"" || echo "Échec du téléchargement de clip_l.safetensors"
fi

echo "Téléchargement du VAE..."
cd /workspace/ComfyUI/models/vae
if [ ! -f ae.safetensors ]; then
    eval "wget $AUTH_HEADER -O ae.safetensors \"https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors?download=true\"" || echo "Échec du téléchargement de ae.safetensors"
fi

echo "Téléchargement du modèle de diffusion..."
cd /workspace/ComfyUI/models/diffusion_models
if [ ! -f flux1-dev.safetensors ]; then
    eval "wget $AUTH_HEADER -O flux1-dev.safetensors \"https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors\"" || echo "Échec du téléchargement de flux1-dev.safetensors"
fi
echo "Téléchargements terminés."