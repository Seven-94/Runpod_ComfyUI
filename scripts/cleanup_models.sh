#!/bin/bash

# Script de nettoyage des anciens modèles
# Ce script peut être utilisé pour libérer de l'espace en supprimant des modèles obsolètes

set -e

echo "🧹 Script de nettoyage des modèles ComfyUI"
echo "==========================================="

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}⚠️  ATTENTION: Ce script peut supprimer des modèles volumineux!${NC}"
echo "Assurez-vous d'avoir suffisamment de bande passante pour les retélécharger si nécessaire."
echo ""

# Fonction pour demander confirmation
confirm() {
    read -p "Voulez-vous continuer? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Opération annulée."
        exit 1
    fi
}

# Fonction pour supprimer un fichier avec confirmation
remove_model() {
    local file_path="$1"
    local model_name="$2"
    local size_mb="$3"
    
    if [ -f "$file_path" ]; then
        echo -e "${BLUE}Supprimer $model_name ($size_mb MB)?${NC}"
        read -p "  (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$file_path"
            echo -e "${GREEN}✓${NC} $model_name supprimé"
            return 0
        else
            echo -e "${YELLOW}⏭️${NC} $model_name conservé"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️${NC} $model_name non trouvé"
        return 1
    fi
}

# Fonction pour calculer la taille d'un fichier
get_file_size_mb() {
    local file_path="$1"
    if [ -f "$file_path" ]; then
        local size=$(stat -c%s "$file_path" 2>/dev/null || stat -f%z "$file_path")
        echo $((size / 1024 / 1024))
    else
        echo 0
    fi
}

echo -e "${BLUE}Options de nettoyage:${NC}"
echo "1. Supprimer les anciens modèles FLUX (garde les nouveaux)"
echo "2. Supprimer les modèles Wan 2.2 (très volumineux)"
echo "3. Supprimer les modèles Qwen"
echo "4. Supprimer tous les modèles non-essentiels"
echo "5. Analyse de l'espace disque seulement"
echo "0. Annuler"
echo ""

read -p "Choisissez une option (0-5): " choice

case $choice in
    1)
        echo -e "${YELLOW}🎨 Nettoyage des anciens modèles FLUX...${NC}"
        # Garder flux1-dev et les nouveaux, supprimer les variantes moins utilisées
        remove_model "/workspace/ComfyUI/models/diffusion_models/flux1-fill-dev.safetensors" "FLUX.1-Fill-dev" $(get_file_size_mb "/workspace/ComfyUI/models/diffusion_models/flux1-fill-dev.safetensors")
        remove_model "/workspace/ComfyUI/models/diffusion_models/flux1-depth-dev.safetensors" "FLUX.1-Depth-dev" $(get_file_size_mb "/workspace/ComfyUI/models/diffusion_models/flux1-depth-dev.safetensors")
        remove_model "/workspace/ComfyUI/models/diffusion_models/flux1-canny-dev.safetensors" "FLUX.1-Canny-dev" $(get_file_size_mb "/workspace/ComfyUI/models/diffusion_models/flux1-canny-dev.safetensors")
        ;;
        
    2)
        echo -e "${YELLOW}📹 Nettoyage des modèles Wan 2.2...${NC}"
        echo "Ces modèles sont très volumineux (>5GB chacun)"
        confirm
        remove_model "/workspace/ComfyUI/models/text_to_video/wan2.2_t2v_a14b_dit.safetensors" "Wan 2.2 T2V A14B" $(get_file_size_mb "/workspace/ComfyUI/models/text_to_video/wan2.2_t2v_a14b_dit.safetensors")
        remove_model "/workspace/ComfyUI/models/image_to_video/wan2.2_i2v_a14b_dit.safetensors" "Wan 2.2 I2V A14B" $(get_file_size_mb "/workspace/ComfyUI/models/image_to_video/wan2.2_i2v_a14b_dit.safetensors")
        remove_model "/workspace/ComfyUI/models/vae/wan2.2_t2v_vae.safetensors" "Wan 2.2 T2V VAE" $(get_file_size_mb "/workspace/ComfyUI/models/vae/wan2.2_t2v_vae.safetensors")
        remove_model "/workspace/ComfyUI/models/vae/wan2.2_i2v_vae.safetensors" "Wan 2.2 I2V VAE" $(get_file_size_mb "/workspace/ComfyUI/models/vae/wan2.2_i2v_vae.safetensors")
        ;;
        
    3)
        echo -e "${YELLOW}🌏 Nettoyage des modèles Qwen...${NC}"
        remove_model "/workspace/ComfyUI/models/diffusion_models/qwen_image_dit.safetensors" "Qwen-Image DiT" $(get_file_size_mb "/workspace/ComfyUI/models/diffusion_models/qwen_image_dit.safetensors")
        remove_model "/workspace/ComfyUI/models/diffusion_models/qwen_image_edit_dit.safetensors" "Qwen-Image-Edit DiT" $(get_file_size_mb "/workspace/ComfyUI/models/diffusion_models/qwen_image_edit_dit.safetensors")
        remove_model "/workspace/ComfyUI/models/vae/qwen_image_vae.safetensors" "Qwen-Image VAE" $(get_file_size_mb "/workspace/ComfyUI/models/vae/qwen_image_vae.safetensors")
        remove_model "/workspace/ComfyUI/models/vae/qwen_image_edit_vae.safetensors" "Qwen-Image-Edit VAE" $(get_file_size_mb "/workspace/ComfyUI/models/vae/qwen_image_edit_vae.safetensors")
        remove_model "/workspace/ComfyUI/models/text_encoders/qwen_text_encoder.safetensors" "Qwen Text Encoder" $(get_file_size_mb "/workspace/ComfyUI/models/text_encoders/qwen_text_encoder.safetensors")
        ;;
        
    4)
        echo -e "${YELLOW}🗑️ Nettoyage complet (garde uniquement FLUX.1-dev et Kontext)...${NC}"
        echo "Cette option garde uniquement les modèles essentiels:"
        echo "- FLUX.1-dev et FLUX.1-Kontext-dev"
        echo "- Encodeurs de texte (T5XXL, CLIP-L)"
        echo "- VAE FLUX"
        echo ""
        confirm
        
        # Supprimer les variantes FLUX
        remove_model "/workspace/ComfyUI/models/diffusion_models/flux1-fill-dev.safetensors" "FLUX.1-Fill-dev" $(get_file_size_mb "/workspace/ComfyUI/models/diffusion_models/flux1-fill-dev.safetensors")
        remove_model "/workspace/ComfyUI/models/diffusion_models/flux1-depth-dev.safetensors" "FLUX.1-Depth-dev" $(get_file_size_mb "/workspace/ComfyUI/models/diffusion_models/flux1-depth-dev.safetensors")
        remove_model "/workspace/ComfyUI/models/diffusion_models/flux1-canny-dev.safetensors" "FLUX.1-Canny-dev" $(get_file_size_mb "/workspace/ComfyUI/models/diffusion_models/flux1-canny-dev.safetensors")
        remove_model "/workspace/ComfyUI/models/style_models/flux1-redux-dev.safetensors" "FLUX.1-Redux-dev" $(get_file_size_mb "/workspace/ComfyUI/models/style_models/flux1-redux-dev.safetensors")
        
        # Supprimer Wan 2.2
        remove_model "/workspace/ComfyUI/models/text_to_video/wan2.2_t2v_a14b_dit.safetensors" "Wan 2.2 T2V A14B" $(get_file_size_mb "/workspace/ComfyUI/models/text_to_video/wan2.2_t2v_a14b_dit.safetensors")
        remove_model "/workspace/ComfyUI/models/image_to_video/wan2.2_i2v_a14b_dit.safetensors" "Wan 2.2 I2V A14B" $(get_file_size_mb "/workspace/ComfyUI/models/image_to_video/wan2.2_i2v_a14b_dit.safetensors")
        remove_model "/workspace/ComfyUI/models/vae/wan2.2_t2v_vae.safetensors" "Wan 2.2 T2V VAE" $(get_file_size_mb "/workspace/ComfyUI/models/vae/wan2.2_t2v_vae.safetensors")
        remove_model "/workspace/ComfyUI/models/vae/wan2.2_i2v_vae.safetensors" "Wan 2.2 I2V VAE" $(get_file_size_mb "/workspace/ComfyUI/models/vae/wan2.2_i2v_vae.safetensors")
        
        # Supprimer Qwen
        remove_model "/workspace/ComfyUI/models/diffusion_models/qwen_image_dit.safetensors" "Qwen-Image DiT" $(get_file_size_mb "/workspace/ComfyUI/models/diffusion_models/qwen_image_dit.safetensors")
        remove_model "/workspace/ComfyUI/models/diffusion_models/qwen_image_edit_dit.safetensors" "Qwen-Image-Edit DiT" $(get_file_size_mb "/workspace/ComfyUI/models/diffusion_models/qwen_image_edit_dit.safetensors")
        remove_model "/workspace/ComfyUI/models/vae/qwen_image_vae.safetensors" "Qwen-Image VAE" $(get_file_size_mb "/workspace/ComfyUI/models/vae/qwen_image_vae.safetensors")
        remove_model "/workspace/ComfyUI/models/vae/qwen_image_edit_vae.safetensors" "Qwen-Image-Edit VAE" $(get_file_size_mb "/workspace/ComfyUI/models/vae/qwen_image_edit_vae.safetensors")
        remove_model "/workspace/ComfyUI/models/text_encoders/qwen_text_encoder.safetensors" "Qwen Text Encoder" $(get_file_size_mb "/workspace/ComfyUI/models/text_encoders/qwen_text_encoder.safetensors")
        ;;
        
    5)
        echo -e "${BLUE}📊 Analyse de l'espace disque...${NC}"
        echo ""
        
        if [ -d "/workspace/ComfyUI/models" ]; then
            echo "Utilisation par répertoire:"
            du -sh /workspace/ComfyUI/models/*/ 2>/dev/null | sort -hr
            echo ""
            echo "Total:"
            du -sh /workspace/ComfyUI/models
            echo ""
            echo "Top 10 des plus gros fichiers:"
            find /workspace/ComfyUI/models -name "*.safetensors" -exec ls -lh {} \; | sort -k5 -hr | head -10 | awk '{print $5 "  " $9}'
        else
            echo "Répertoire des modèles non trouvé."
        fi
        ;;
        
    0|*)
        echo "Opération annulée."
        exit 0
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Nettoyage terminé!${NC}"

# Afficher l'espace libéré
if [ -d "/workspace/ComfyUI/models" ]; then
    total_size=$(du -sh /workspace/ComfyUI/models 2>/dev/null | cut -f1)
    echo -e "${BLUE}💾 Espace actuel utilisé par les modèles: $total_size${NC}"
fi
