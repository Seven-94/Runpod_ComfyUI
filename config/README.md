# Configuration de ComfyUI sur RunPod

Ce dossier contient les fichiers de configuration et les scripts nécessaires au fonctionnement de ComfyUI sur RunPod.

## Téléchargement des modèles

Cette image nécessite le téléchargement de certains modèles depuis Hugging Face au premier démarrage.

Pour télécharger les modèles avec authentification (recommandé) :
1. Créez un compte sur [Hugging Face](https://huggingface.co/)
2. Créez un token d'accès dans les paramètres de votre compte
3. Lors du déploiement du pod sur RunPod, ajoutez une variable d'environnement :
   - Nom : `HF_TOKEN`
   - Valeur : votre token HuggingFace

Si vous ne fournissez pas de token, l'image tentera un téléchargement anonyme, mais celui-ci pourrait échouer selon les restrictions d'accès des modèles.

## Scripts inclus

### download_models.sh
Script automatisé pour télécharger les modèles nécessaires depuis Hugging Face. Il vérifie si les modèles existent déjà avant de les télécharger pour éviter les duplications.

### pre_start.sh
Ce script est exécuté au démarrage du conteneur pour initialiser ComfyUI :
- Copie des fichiers ComfyUI depuis l'image Docker vers le volume
- Création des répertoires pour les modèles
- Installation des extensions depuis l'image Docker
- Téléchargement des modèles manquants
- Configuration d'extra_model_paths.yml
- Démarrage du service ComfyUI

### start.sh
Script principal exécuté au démarrage du pod :
- Démarrage de Nginx pour l'interface web
- Configuration SSH pour l'accès distant
- Démarrage de JupyterLab si activé
- Exécution de pre_start.sh pour initialiser ComfyUI
- Configuration des variables d'environnement et du répertoire de travail

## Fichiers de configuration

### extra_model_paths.yml
Définit les chemins pour les différents types de modèles utilisés par ComfyUI. Cela permet à ComfyUI de trouver automatiquement les modèles placés dans les sous-répertoires appropriés.

### nginx.conf
Configuration du serveur web Nginx qui sert d'interface pour accéder à ComfyUI et à la documentation.

## Extensions intégrées

- **ComfyUI-Manager** : Interface de gestion pour installer d'autres extensions et modèles
- **sdxl_prompt_styler** : Permet de styliser facilement les prompts pour SDXL
- **ComfyUI_TensorRT** : Améliore les performances en utilisant TensorRT pour optimiser les calculs

## Modèles préchargés

Les modèles suivants sont automatiquement téléchargés au premier démarrage et placés dans les répertoires correspondants :

- **t5xxl_fp16.safetensors** (Encodeur de texte)  
  Chemin: `/workspace/ComfyUI/models/text_encoders/`

- **clip_l.safetensors** (Encodeur de texte CLIP)  
  Chemin: `/workspace/ComfyUI/models/text_encoders/`

- **ae.safetensors** (VAE)  
  Chemin: `/workspace/ComfyUI/models/vae/`

- **flux1-dev.safetensors** (Modèle de diffusion)  
  Chemin: `/workspace/ComfyUI/models/diffusion_models/`

## Personnalisation

Vous pouvez personnaliser cette configuration en modifiant les fichiers suivants :

- **download_models.sh** pour télécharger d'autres modèles par défaut
- **extra_model_paths.yml** pour ajouter des chemins de modèles supplémentaires
- **pre_start.sh** pour ajouter des extensions ou des configurations supplémentaires

---

# ComfyUI on RunPod Configuration

This folder contains configuration files and scripts necessary for the operation of ComfyUI on RunPod.

## Model Download

This image requires downloading certain models from Hugging Face on first startup.

To download models with authentication (recommended):
1. Create an account on [Hugging Face](https://huggingface.co/)
2. Create an access token in your account settings
3. When deploying the pod on RunPod, add an environment variable:
   - Name: `HF_TOKEN`
   - Value: your HuggingFace token

If you don't provide a token, the image will attempt an anonymous download, but this may fail depending on the access restrictions of the models.

## Included Scripts

### download_models.sh
Automated script to download necessary models from Hugging Face. It checks if models already exist before downloading to avoid duplication.

### pre_start.sh
This script runs at container startup to initialize ComfyUI:
- Copies ComfyUI files from the Docker image to the volume
- Creates directories for models
- Installs extensions from the Docker image
- Downloads missing models
- Configures extra_model_paths.yml
- Starts the ComfyUI service

### start.sh
Main script executed at pod startup:
- Starts Nginx for web interface
- Configures SSH for remote access
- Starts JupyterLab if enabled
- Runs pre_start.sh to initialize ComfyUI
- Configures environment variables and working directory

## Configuration Files

### extra_model_paths.yml
Defines paths for different types of models used by ComfyUI. This allows ComfyUI to automatically find models placed in the appropriate subdirectories.

### nginx.conf
Configuration of the Nginx web server that serves as the interface for accessing ComfyUI and documentation.

## Included Extensions

- **ComfyUI-Manager**: Management interface for installing other extensions and models
- **sdxl_prompt_styler**: Easily style prompts for SDXL
- **ComfyUI_TensorRT**: Improves performance by using TensorRT to optimize calculations

## Pre-loaded Models

The following models are automatically downloaded on first startup and placed in the corresponding directories:

- **t5xxl_fp16.safetensors** (Text Encoder)  
  Path: `/workspace/ComfyUI/models/text_encoders/`

- **clip_l.safetensors** (CLIP Text Encoder)  
  Path: `/workspace/ComfyUI/models/text_encoders/`

- **ae.safetensors** (VAE)  
  Path: `/workspace/ComfyUI/models/vae/`

- **flux1-dev.safetensors** (Diffusion Model)  
  Path: `/workspace/ComfyUI/models/diffusion_models/`

## Customization

You can customize this configuration by modifying the following files:

- **download_models.sh** to download other default models
- **extra_model_paths.yml** to add additional model paths
- **pre_start.sh** to add additional extensions or configurations