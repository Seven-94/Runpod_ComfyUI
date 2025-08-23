#!/bin/bash
set -e

echo "Initialisation de ComfyUI pour RunPod..."

# Étape 1: S'assurer que le dossier de base existe
mkdir -p /workspace/ComfyUI

# Étape 2: Vérifier si ComfyUI est déjà installé sur le volume
if [ ! -f "/workspace/ComfyUI/main.py" ]; then
    echo "Installation de ComfyUI v0.3.51 dans le volume network..."
    # Copier les fichiers depuis la version préinstallée dans l'image
    if ! cp -r /opt/ComfyUI/* /workspace/ComfyUI/ 2>/dev/null; then
        echo "ERREUR: Impossible de copier les fichiers ComfyUI"
        exit 1
    fi
    if ! cp -r /opt/ComfyUI/.* /workspace/ComfyUI/ 2>/dev/null; then
        echo "AVERTISSEMENT: Impossible de copier tous les fichiers cachés (normal)"
    fi
    
    # Réinitialiser le repository Git pour permettre les mises à jour
    echo "Configuration du repository Git pour les mises à jour..."
    cd /workspace/ComfyUI
    
    # Supprimer l'ancien .git si présent (cloné avec --depth 1 --branch tag)
    rm -rf .git
    
    # Réinitialiser le repository Git avec l'historique complet
    git init
    git remote add origin https://github.com/comfyanonymous/ComfyUI.git
    echo "Récupération de l'historique Git complet..."
    if git fetch origin; then
        echo "✅ Fetch initial réussi"
    else
        echo "❌ Échec du fetch Git"
        exit 1
    fi
    
    # Récupérer spécifiquement la branche master
    echo "Configuration de la branche master..."
    if git fetch origin master:master; then
        echo "✅ Branche master récupérée"
        git checkout master
        git branch --set-upstream-to=origin/master master
    else
        echo "❌ Impossible de récupérer la branche master"
        exit 1
    fi
    
    # Revenir au tag v0.3.51 tout en gardant la branche master accessible
    git fetch --tags
    if git show-ref --verify --quiet refs/tags/v0.3.51; then
        echo "Tag v0.3.51 trouvé, création d'une branche de travail..."
        git checkout v0.3.51
        git checkout -b current-version
        git checkout master
        echo "Configuration Git terminée - prêt pour les mises à jour via ComfyUI-Manager"
    else
        echo "⚠️ Tag v0.3.51 non trouvé, resté sur master"
    fi
    
    echo "ComfyUI v0.3.51 installé avec succès (repository Git configuré pour les mises à jour)"
else
    echo "ComfyUI déjà présent dans le volume network"
    
    # Vérifier si le repository Git est correctement configuré
    cd /workspace/ComfyUI
    if [ ! -d ".git" ] || ! git remote get-url origin >/dev/null 2>&1; then
        echo "Reconfiguration complète du repository Git pour les mises à jour..."
        rm -rf .git
        git init
        git remote add origin https://github.com/comfyanonymous/ComfyUI.git
        
        echo "Récupération de toutes les branches et tags..."
        if git fetch origin; then
            echo "✅ Fetch initial réussi"
        else
            echo "❌ Échec du fetch Git initial"
            exit 1
        fi
        
        # Récupérer spécifiquement la branche master
        echo "Récupération de la branche master..."
        if git fetch origin master:master; then
            echo "✅ Branche master récupérée"
        else
            echo "❌ Impossible de récupérer la branche master"
            exit 1
        fi
        
        # Basculer sur master
        if git checkout master; then
            echo "✅ Basculé sur master"
        else
            echo "❌ Impossible de basculer sur master"
            exit 1
        fi
        
        # S'assurer que master suit origin/master
        git branch --set-upstream-to=origin/master master
        echo "Repository Git reconfiguré - prêt pour les mises à jour"
    else
        echo "Vérification de la configuration Git existante..."
        
        # Vérifier que la branche master existe localement
        if ! git show-ref --verify --quiet refs/heads/master; then
            echo "Branche master manquante, reconfiguration..."
            
            # Nettoyer et recommencer proprement
            echo "Nettoyage et reconfiguration complète..."
            cd /workspace
            rm -rf ComfyUI/.git
            cd ComfyUI
            git init
            git remote add origin https://github.com/comfyanonymous/ComfyUI.git
            
            echo "Récupération de la branche master..."
            if git fetch origin master:master; then
                echo "✅ Branche master récupérée"
                git checkout master
                git branch --set-upstream-to=origin/master master
            else
                echo "❌ Impossible de récupérer master"
                exit 1
            fi
        elif ! git rev-parse --abbrev-ref master@{upstream} >/dev/null 2>&1; then
            echo "Configuration upstream manquante pour master..."
            git fetch origin
            git branch --set-upstream-to=origin/master master
        fi
        echo "Configuration Git vérifiée"
    fi
fi

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