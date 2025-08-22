# Configuration de ComfyUI sur RunPod

Ce dossier contient les fichiers de configuration et les scripts nécessaires au fonctionnement de ComfyUI sur RunPod.

## Téléchargement des modèles

Cette image permet le téléchargement de modèles depuis Hugging Face selon vos besoins.

Pour télécharger les modèles avec authentification (recommandé) :
1. Créez un compte sur [Hugging Face](https://huggingface.co/)
2. Créez un token d'accès dans les paramètres de votre compte
3. Lors du déploiement du pod sur RunPod, ajoutez une variable d'environnement :
   - Nom : `HF_TOKEN`
   - Valeur : votre token HuggingFace

Si vous ne fournissez pas de token, vous pourrez toujours télécharger des modèles publics via ComfyUI-Manager.

## Scripts inclus

### pre_start.sh
Ce script est exécuté au démarrage du conteneur pour initialiser ComfyUI :
- Copie des fichiers ComfyUI depuis l'image Docker vers le volume
- Création des répertoires pour les modèles
- Installation des extensions depuis l'image Docker
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
- **ComfyUI-Crystools** : Outils utilitaires avancés  
- **ComfyUI-KJNodes** : Nœuds étendus de Kijai

## Modèles

Vous pouvez télécharger les modèles de votre choix via ComfyUI-Manager une fois le conteneur démarré.
Les modèles seront automatiquement placés dans les répertoires correspondants définis dans `extra_model_paths.yml`.

## Personnalisation

Vous pouvez personnaliser cette configuration en modifiant les fichiers suivants :

- **extra_model_paths.yml** pour ajouter des chemins de modèles supplémentaires
- **pre_start.sh** pour ajouter des extensions ou des configurations supplémentaires

---

# ComfyUI on RunPod Configuration

This folder contains configuration files and scripts necessary for the operation of ComfyUI on RunPod.

## Model Download

This image allows downloading models from Hugging Face according to your needs.

To download models with authentication (recommended):
1. Create an account on [Hugging Face](https://huggingface.co/)
2. Create an access token in your account settings
3. When deploying the pod on RunPod, add an environment variable:
   - Name: `HF_TOKEN`
   - Value: your HuggingFace token

If you don't provide a token, you can still download public models via ComfyUI-Manager.

## Included Scripts

### pre_start.sh
This script runs at container startup to initialize ComfyUI:
- Copies ComfyUI files from the Docker image to the volume
- Creates directories for models
- Installs extensions from the Docker image
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
- **ComfyUI-Crystools**: Advanced utility tools  
- **ComfyUI-KJNodes**: Extended nodes from Kijai

## Models

You can download the models of your choice via ComfyUI-Manager once the container is started.
Models will be automatically placed in the corresponding directories defined in `extra_model_paths.yml`.

## Customization

You can customize this configuration by modifying the following files:

- **extra_model_paths.yml** to add additional model paths
- **pre_start.sh** to add additional extensions or configurations