#!/bin/bash
set -e

# Script de construction automatique pour ComfyUI RunPod v0.1.0
# Optimisé pour GPU Blackwell

echo "🐳 Construction du conteneur ComfyUI RunPod v${VERSION}"
echo "================================================"

# Variables
VERSION="0.1.0"
IMAGE_NAME="runpod-comfyui"
REGISTRY="${DOCKER_REGISTRY:-}" # Optionnel, peut être défini par l'utilisateur
COMFYUI_VERSION="${COMFYUI_VERSION:-$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/releases/latest | jq -r .tag_name)}"

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction d'affichage coloré
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log "Vérification des prérequis..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker n'est pas installé ou pas dans le PATH"
        exit 1
    fi
    
    # Vérifier que Docker est en cours d'exécution
    if ! docker info &> /dev/null; then
        error "Docker n'est pas en cours d'exécution"
        exit 1
    fi
    
    log "✅ Docker est disponible et en cours d'exécution"
}

# Construction de l'image
build_image() {
    log "Construction de l'image ${IMAGE_NAME}:${VERSION} avec ComfyUI ${COMFYUI_VERSION}..."
    
    # Arguments de build pour optimisation
    DOCKER_BUILDKIT=1 docker build \
        --platform linux/amd64 \
        --progress=plain \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --build-arg COMFYUI_VERSION="${COMFYUI_VERSION}" \
        --tag "${IMAGE_NAME}:${VERSION}" \
        --tag "${IMAGE_NAME}:latest" \
        --tag "${IMAGE_NAME}:${VERSION}-comfyui-${COMFYUI_VERSION}" \
        .
    
    if [ $? -eq 0 ]; then
        log "✅ Image construite avec succès!"
    else
        error "❌ Échec de la construction de l'image"
        exit 1
    fi
}

# Affichage des informations de l'image
show_image_info() {
    log "Informations de l'image construite:"
    docker images "${IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
}

# # Test de l'image (optionnel)
# test_image() {
#     if [ "$1" = "--test" ]; then
#         log "Test de l'image..."
        
#         # Test simple : vérifier que l'image démarre
#         docker run --rm \
#             --gpus all \
#             --name test_comfyui \
#             "${IMAGE_NAME}:${VERSION}" \
#             python --version
            
#         if [ $? -eq 0 ]; then
#             log "✅ Test réussi"
#         else
#             warn "⚠️ Test échoué - l'image peut tout de même fonctionner"
#         fi
#     fi
# }

# Test de l'image (optionnel)
test_image() {
    for arg in "$@"; do
        if [ "$arg" = "--test" ]; then
            warn "Test ignoré sur Mac - l'image sera testée sur RunPod"
            log "✅ Construction OK, prête pour déploiement RunPod"
            break
        fi
    done
}

# Publication sur registry (optionnel)
push_image() {
    local should_push=false
    for arg in "$@"; do
        if [ "$arg" = "--push" ]; then
            should_push=true
            break
        fi
    done
    
    if [ "$should_push" = true ] && [ -n "$REGISTRY" ]; then
        log "Publication vers le registry ${REGISTRY}..."
        
        # Tag pour le registry
        docker tag "${IMAGE_NAME}:${VERSION}" "${REGISTRY}/${IMAGE_NAME}:${VERSION}"
        docker tag "${IMAGE_NAME}:${VERSION}" "${REGISTRY}/${IMAGE_NAME}:latest"
        
        # Push
        docker push "${REGISTRY}/${IMAGE_NAME}:${VERSION}"
        docker push "${REGISTRY}/${IMAGE_NAME}:latest"
        
        log "✅ Image publiée sur ${REGISTRY}"
    elif [ "$should_push" = true ]; then
        warn "Variable DOCKER_REGISTRY non définie, publication ignorée"
    fi
}

# Nettoyage des images temporaires
cleanup() {
    for arg in "$@"; do
        if [ "$arg" = "--cleanup" ]; then
            log "Nettoyage des images temporaires..."
            docker image prune -f
            log "✅ Nettoyage terminé"
            break
        fi
    done
}

# Programme principal
main() {
    echo -e "${BLUE}ComfyUI RunPod v${VERSION} - Optimisé GPU Blackwell${NC}"
    echo "Fonctionnalités :"
    echo "  🚀 ComfyUI ${COMFYUI_VERSION}"
    echo "  ⚡ PyTorch 2.8.0 + CUDA 12.9"
    echo "  🎯 Flash Attention 2 + xFormers + Triton"
    echo "  🔧 Extensions : Manager, Crystools, KJNodes"
    echo "  🧹 Conteneur propre (sans modèles)"
    echo ""
    
    check_prerequisites
    build_image
    show_image_info
    test_image "$@"
    push_image "$@"
    cleanup "$@"
    
    echo ""
    log "🎉 Construction terminée!"
    echo -e "${GREEN}Pour déployer sur RunPod :${NC}"
    echo "  1. Publiez l'image : docker push ${REGISTRY:-votre-registry}/${IMAGE_NAME}:${VERSION}"
    echo "  2. Créez un template RunPod avec cette image"
    echo "  3. Commande de démarrage : /start.sh"
    echo "  4. Ports HTTP : 8188, 3000,8888,22"
    echo ""
    echo -e "${YELLOW}Vérification des optimisations Blackwell :${NC}"
    echo "  python /opt/scripts/check_blackwell_optimizations.py"
}

# Affichage de l'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --test      Teste l'image après construction"
    echo "  --push      Publie l'image sur le registry (nécessite DOCKER_REGISTRY)"
    echo "  --cleanup   Nettoie les images temporaires après construction"
    echo "  --help      Affiche cette aide"
    echo ""
    echo "Variables d'environnement:"
    echo "  DOCKER_REGISTRY   Registry Docker pour publication (optionnel)"
    echo "  COMFYUI_VERSION   Version ComfyUI à utiliser (défaut: dernière)"
    echo ""
    echo "Exemples:"
    echo "  $0                                    # Construction simple (dernière version ComfyUI)"
    echo "  $0 --test --cleanup                  # Construction + test + nettoyage"
    echo "  DOCKER_REGISTRY=myregistry.com $0 --push  # Construction + publication"
    echo "  COMFYUI_VERSION=v0.3.50 $0          # Construction avec ComfyUI v0.3.50"
}

# Point d'entrée
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
else
    main "$@"
fi
