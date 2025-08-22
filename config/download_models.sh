#!/bin/bash
set -e

# Fonction pour télécharger un modèle s'il n'existe pas déjà
download_if_not_exists() {
    local url="$1"
    local dest="$2"
    local name="$3"
    
    # S'assurer que le répertoire parent existe
    mkdir -p "$(dirname "$dest")"
    
    if [ -f "$dest" ]; then
        # Vérifier que le fichier a une taille raisonnable (>1MB)
        local size=$(stat -c%s "$dest" 2>/dev/null || stat -f%z "$dest")
        if [ "$size" -gt 1048576 ]; then
            echo "✓ Modèle $name déjà présent ($size octets)"
            return 0
        else
            echo "⚠️ Modèle $name détecté mais taille invalide ($size octets)"
            rm -f "$dest"
        fi
    fi
    
    echo "📥 Téléchargement de $name..."
    if [ -n "$HF_TOKEN" ]; then
        wget --quiet --show-progress --header="Authorization: Bearer $HF_TOKEN" -O "$dest" "$url"
    else
        wget --quiet --show-progress -O "$dest" "$url"
    fi
    
    echo "✅ $name téléchargé avec succès!"
}

echo "==== Vérification des modèles dans le volume network ===="

# Message d'authentification
if [ -z "$HF_TOKEN" ]; then
    echo "⚠️ Variable HF_TOKEN non définie. Téléchargement anonyme (limites de débit possibles)"
else
    echo "🔐 Authentification HuggingFace activée"
fi

# Téléchargement des modèles essentiels
echo "🔍 Vérification des modèles de base..."

# S'assurer que nous sommes dans le répertoire ComfyUI
cd /workspace/ComfyUI

# Encodeurs de texte
download_if_not_exists \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors?download=true" \
    "/workspace/ComfyUI/models/text_encoders/t5xxl_fp16.safetensors" \
    "Encodeur T5XXL"

download_if_not_exists \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true" \
    "/workspace/ComfyUI/models/text_encoders/clip_l.safetensors" \
    "Encodeur CLIP-L"

# VAE
download_if_not_exists \
    "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors?download=true" \
    "/workspace/ComfyUI/models/vae/ae.safetensors" \
    "FLUX VAE"

# Modèle de diffusion
download_if_not_exists \
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors" \
    "/workspace/ComfyUI/models/diffusion_models/flux1-dev.safetensors" \
    "FLUX.1-dev Modèle"

# Modèle Fill Flux.1-dev
download_if_not_exists \
    "https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev/resolve/main/flux1-fill-dev.safetensors" \
    "/workspace/ComfyUI/models/diffusion_models/flux1-fill-dev.safetensors" \
    "FLUX.1-Fill-dev Modèle"

# Modèle Depth Flux.1-dev
download_if_not_exists \
    "https://huggingface.co/black-forest-labs/FLUX.1-Depth-dev/resolve/main/flux1-depth-dev.safetensors" \
    "/workspace/ComfyUI/models/diffusion_models/flux1-depth-dev.safetensors" \
    "FLUX.1-Depth-dev Modèle"

# Modèle Canny Flux.1-dev
download_if_not_exists \
    "https://huggingface.co/black-forest-labs/FLUX.1-Canny-dev/resolve/main/flux1-canny-dev.safetensors" \
    "/workspace/ComfyUI/models/diffusion_models/flux1-canny-dev.safetensors" \
    "FLUX.1-Canny-dev Modèle"

# Modèle Redux Flux.1-dev
download_if_not_exists \
    "https://huggingface.co/black-forest-labs/FLUX.1-Redux-dev/resolve/main/flux1-redux-dev.safetensors" \
    "/workspace/ComfyUI/models/style_models/flux1-redux-dev.safetensors" \
    "FLUX.1-Redux-dev Modèle"

# Sigclip Vision Comfyui
download_if_not_exists \
    "https://huggingface.co/Comfy-Org/sigclip_vision_384/resolve/main/sigclip_vision_patch14_384.safetensors" \
    "/workspace/ComfyUI/models/clip_vision/sigclip_vision_patch14_384.safetensors" \
    "Sigclip Vision Comfyui"

echo "🔍 Téléchargement des nouveaux modèles..."

# FLUX.1-Kontext-dev - Modèle d'édition d'images contextuelle
download_if_not_exists \
    "https://huggingface.co/black-forest-labs/FLUX.1-Kontext-dev/resolve/main/flux1-kontext-dev.safetensors" \
    "/workspace/ComfyUI/models/diffusion_models/flux1-kontext-dev.safetensors" \
    "FLUX.1-Kontext-dev Modèle"

# VAE pour FLUX.1-Kontext-dev
download_if_not_exists \
    "https://huggingface.co/black-forest-labs/FLUX.1-Kontext-dev/resolve/main/ae.safetensors" \
    "/workspace/ComfyUI/models/vae/flux_kontext_ae.safetensors" \
    "FLUX.1-Kontext VAE"

# Wan 2.2 T2V A14B - Modèle Text-to-Video
echo "📹 Téléchargement des modèles Wan 2.2 (très volumineux)..."
download_if_not_exists \
    "https://huggingface.co/Wan-AI/Wan2.2-T2V-A14B/resolve/main/dit/diffusion_pytorch_model.safetensors" \
    "/workspace/ComfyUI/models/text_to_video/wan2.2_t2v_a14b_dit.safetensors" \
    "Wan 2.2 T2V A14B DiT"

download_if_not_exists \
    "https://huggingface.co/Wan-AI/Wan2.2-T2V-A14B/resolve/main/vae/diffusion_pytorch_model.safetensors" \
    "/workspace/ComfyUI/models/vae/wan2.2_t2v_vae.safetensors" \
    "Wan 2.2 T2V VAE"

# Wan 2.2 I2V A14B - Modèle Image-to-Video
download_if_not_exists \
    "https://huggingface.co/Wan-AI/Wan2.2-I2V-A14B/resolve/main/dit/diffusion_pytorch_model.safetensors" \
    "/workspace/ComfyUI/models/image_to_video/wan2.2_i2v_a14b_dit.safetensors" \
    "Wan 2.2 I2V A14B DiT"

download_if_not_exists \
    "https://huggingface.co/Wan-AI/Wan2.2-I2V-A14B/resolve/main/vae/diffusion_pytorch_model.safetensors" \
    "/workspace/ComfyUI/models/vae/wan2.2_i2v_vae.safetensors" \
    "Wan 2.2 I2V VAE"

# Qwen-Image - Modèle Text-to-Image multilingue
echo "🖼️ Téléchargement des modèles Qwen Image..."
download_if_not_exists \
    "https://huggingface.co/Qwen/Qwen-Image/resolve/main/dit/diffusion_pytorch_model.safetensors" \
    "/workspace/ComfyUI/models/diffusion_models/qwen_image_dit.safetensors" \
    "Qwen-Image DiT"

download_if_not_exists \
    "https://huggingface.co/Qwen/Qwen-Image/resolve/main/vae/diffusion_pytorch_model.safetensors" \
    "/workspace/ComfyUI/models/vae/qwen_image_vae.safetensors" \
    "Qwen-Image VAE"

# Qwen-Image-Edit - Modèle d'édition d'images multilingue
download_if_not_exists \
    "https://huggingface.co/Qwen/Qwen-Image-Edit/resolve/main/dit/diffusion_pytorch_model.safetensors" \
    "/workspace/ComfyUI/models/diffusion_models/qwen_image_edit_dit.safetensors" \
    "Qwen-Image-Edit DiT"

download_if_not_exists \
    "https://huggingface.co/Qwen/Qwen-Image-Edit/resolve/main/vae/diffusion_pytorch_model.safetensors" \
    "/workspace/ComfyUI/models/vae/qwen_image_edit_vae.safetensors" \
    "Qwen-Image-Edit VAE"

# Encodeurs de texte pour Qwen models
download_if_not_exists \
    "https://huggingface.co/Qwen/Qwen-Image/resolve/main/text_encoder/model.safetensors" \
    "/workspace/ComfyUI/models/text_encoders/qwen_text_encoder.safetensors" \
    "Qwen Text Encoder"

echo "==== Vérification des permissions des fichiers ===="
# S'assurer que tous les fichiers téléchargés sont accessibles
chmod -R 755 /workspace/ComfyUI/models/

echo "==== Téléchargements terminés ===="
echo "💾 Tous les modèles sont stockés dans le Volume Network à /workspace/ComfyUI/models/"