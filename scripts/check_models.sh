#!/bin/bash

# Script de vérification des modèles téléchargés
# Ce script vérifie que tous les modèles requis sont présents et ont une taille appropriée

set -e

echo "🔍 Vérification des modèles ComfyUI..."
echo "======================================="

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour vérifier la présence et la taille d'un fichier
check_model() {
    local file_path="$1"
    local model_name="$2"
    local min_size_mb="$3"
    
    if [ -f "$file_path" ]; then
        local size=$(stat -c%s "$file_path" 2>/dev/null || stat -f%z "$file_path")
        local size_mb=$((size / 1024 / 1024))
        
        if [ "$size_mb" -gt "$min_size_mb" ]; then
            echo -e "${GREEN}✓${NC} $model_name ($size_mb MB)"
            return 0
        else
            echo -e "${RED}✗${NC} $model_name (taille insuffisante: $size_mb MB < $min_size_mb MB)"
            return 1
        fi
    else
        echo -e "${RED}✗${NC} $model_name (fichier manquant)"
        return 1
    fi
}

# Vérification des modèles FLUX originaux
echo -e "${YELLOW}🎨 Modèles FLUX:${NC}"
check_model "/workspace/ComfyUI/models/text_encoders/t5xxl_fp16.safetensors" "T5XXL Encoder" 10000
check_model "/workspace/ComfyUI/models/text_encoders/clip_l.safetensors" "CLIP-L Encoder" 200
check_model "/workspace/ComfyUI/models/vae/ae.safetensors" "FLUX VAE" 300
check_model "/workspace/ComfyUI/models/diffusion_models/flux1-dev.safetensors" "FLUX.1-dev" 10000
check_model "/workspace/ComfyUI/models/diffusion_models/flux1-fill-dev.safetensors" "FLUX.1-Fill-dev" 10000
check_model "/workspace/ComfyUI/models/diffusion_models/flux1-depth-dev.safetensors" "FLUX.1-Depth-dev" 10000
check_model "/workspace/ComfyUI/models/diffusion_models/flux1-canny-dev.safetensors" "FLUX.1-Canny-dev" 10000
check_model "/workspace/ComfyUI/models/style_models/flux1-redux-dev.safetensors" "FLUX.1-Redux-dev" 10000

echo ""
echo -e "${YELLOW}✨ Nouveaux modèles 2025:${NC}"

# FLUX.1-Kontext-dev
check_model "/workspace/ComfyUI/models/diffusion_models/flux1-kontext-dev.safetensors" "FLUX.1-Kontext-dev" 20000
check_model "/workspace/ComfyUI/models/vae/flux_kontext_ae.safetensors" "FLUX Kontext VAE" 300

# Modèles Wan 2.2
check_model "/workspace/ComfyUI/models/text_to_video/wan2.2_t2v_a14b_dit.safetensors" "Wan 2.2 T2V A14B" 5000
check_model "/workspace/ComfyUI/models/vae/wan2.2_t2v_vae.safetensors" "Wan 2.2 T2V VAE" 100
check_model "/workspace/ComfyUI/models/image_to_video/wan2.2_i2v_a14b_dit.safetensors" "Wan 2.2 I2V A14B" 5000
check_model "/workspace/ComfyUI/models/vae/wan2.2_i2v_vae.safetensors" "Wan 2.2 I2V VAE" 100

# Modèles Qwen
check_model "/workspace/ComfyUI/models/diffusion_models/qwen_image_dit.safetensors" "Qwen-Image DiT" 1000
check_model "/workspace/ComfyUI/models/vae/qwen_image_vae.safetensors" "Qwen-Image VAE" 100
check_model "/workspace/ComfyUI/models/diffusion_models/qwen_image_edit_dit.safetensors" "Qwen-Image-Edit DiT" 1000
check_model "/workspace/ComfyUI/models/vae/qwen_image_edit_vae.safetensors" "Qwen-Image-Edit VAE" 100
check_model "/workspace/ComfyUI/models/text_encoders/qwen_text_encoder.safetensors" "Qwen Text Encoder" 500

echo ""
echo -e "${YELLOW}🔍 Modèles de support:${NC}"
check_model "/workspace/ComfyUI/models/clip_vision/sigclip_vision_patch14_384.safetensors" "Sigclip Vision" 500

echo ""
echo "======================================="

# Calcul de l'espace disque utilisé
if [ -d "/workspace/ComfyUI/models" ]; then
    total_size=$(du -sh /workspace/ComfyUI/models 2>/dev/null | cut -f1)
    echo -e "${YELLOW}💾 Espace total utilisé par les modèles: $total_size${NC}"
fi

# Vérification des permissions
echo -e "${YELLOW}🔐 Vérification des permissions...${NC}"
if [ -r "/workspace/ComfyUI/models" ] && [ -w "/workspace/ComfyUI/models" ]; then
    echo -e "${GREEN}✓${NC} Permissions correctes sur le répertoire des modèles"
else
    echo -e "${RED}✗${NC} Problème de permissions sur le répertoire des modèles"
fi

echo ""
echo -e "${GREEN}🎉 Vérification terminée!${NC}"
echo "Pour plus d'informations sur les nouveaux modèles, consultez docs/NOUVEAUX_MODELES.md"
