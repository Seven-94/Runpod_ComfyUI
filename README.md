# ComfyUI pour RunPod avec CUDA 12.8

Ce dépôt contient les fichiers nécessaires pour créer un conteneur Docker optimisé pour exécuter ComfyUI sur la plateforme RunPod avec CUDA 12.8.1.

## Fonctionnalités

- **Base CUDA 12.8.1** - Support des GPU plus récents avec la dernière version CUDA
- **Téléchargement de modèles à la demande** - Les modèles sont téléchargés depuis Hugging Face au premier démarrage (Flux1.Dev actuellement)
- **Extensions pré-installées** - ComfyUI-Manager, sdxl_prompt_styler, ComfyUI_TensorRT et plus
- **Interface web avec Nginx** - Configuration optimisée pour l'accès à distance
- **Support JupyterLab** - Pour le développement et l'exploration des fonctionnalités
- **Persistance des données** - Les modèles et les configurations sont conservés dans un volume network

## Prérequis

- Docker installé sur votre machine (pour la construction de l'image)
- Si vous utilisez un Mac M1/M2/M3, utilisez Docker Desktop avec support d'émulation
- Un compte RunPod avec des crédits ou un GPU disponible
- Un compte Hugging Face (pour le téléchargement des modèles)

## Construction de l'image Docker

1. Clonez ce dépôt :
```bash
git clone https://github.com/Seven-94/Runpod_ComfyUI
cd Runpod_ComfyUI
```

2. Construisez l'image Docker :
```bash
# Sur x86_64/amd64 (Linux, Windows)
docker build -t runpod_comfyui .

# Sur Mac M1/M2/M3 (arm64)
docker buildx build --platform=linux/amd64 -t runpod_comfyui .
```

3. Publiez l'image sur Docker Hub (optionnel) :
```bash
docker tag runpod_comfyui votre-username/runpod_comfyui:latest
docker push votre-username/runpod_comfyui:latest
```

## Utilisation sur RunPod

1. Connectez-vous à votre compte [RunPod](https://www.runpod.io/)
2. Créez un nouveau template en utilisant votre image Docker
3. Configurez le template avec :
   - Container Start Command: `/start.sh`
   - Volume Mount Path: `/workspace`
   - Expose HTTP Ports: `8188,8888,3000`
   - Expose TCP Ports: `22`
4. N'oubliez pas d'ajouter la variable d'environnement `HF_TOKEN` avec votre token Hugging Face lors du déploiement

Pour plus de détails, consultez la [documentation complète](docs/GUIDE.md).

## Modèles inclus

Les modèles suivants sont téléchargés automatiquement depuis Hugging Face :
- t5xxl_fp16.safetensors (encodeur de texte)
- clip_l.safetensors (encodeur de texte)
- ae.safetensors (VAE)
- flux1-dev.safetensors (modèle de diffusion)

## Structure du projet

- `Dockerfile` - Fichier principal pour la construction de l'image Docker
- `config/` - Fichiers de configuration pour ComfyUI, Nginx et scripts de démarrage
- `docs/` - Documentation supplémentaire
- `scripts/` - Scripts utilitaires

## Organisation des répertoires

Une fois déployé, le conteneur organise les fichiers comme suit :

```
/workspace/ComfyUI/              # Répertoire principal de ComfyUI
├── custom_nodes/                # Extensions et nœuds personnalisés
├── input/                       # Répertoire pour les fichiers d'entrée
├── models/                      # Tous les modèles
│   ├── checkpoints/             # Modèles de base (checkpoint)
│   ├── clip/                    # Modèles CLIP
│   ├── clip_vision/             # Modèles CLIP Vision
│   ├── controlnet/              # Modèles ControlNet
│   ├── diffusion_models/        # Modèles de diffusion (comme Flux)
│   ├── embeddings/              # Embeddings textuels
│   ├── loras/                   # LoRA models
│   ├── text_encoders/           # Encodeurs de texte
│   ├── upscale_models/          # Modèles d'upscaling
│   └── vae/                     # Modèles VAE
└── output/                      # Images générées
```

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

# ComfyUI for RunPod with CUDA 12.8

This repository contains the files needed to create an optimized Docker container to run ComfyUI on the RunPod platform with CUDA 12.8.1.

## Features

- **CUDA 12.8.1 Base** - Support for newer GPUs with the latest CUDA version
- **On-demand Model Download** - Models are downloaded from Hugging Face on first startup (Flux1.Dev currently)
- **Pre-installed Extensions** - ComfyUI-Manager, sdxl_prompt_styler, ComfyUI_TensorRT and more
- **Web Interface with Nginx** - Optimized configuration for remote access
- **JupyterLab Support** - For development and feature exploration
- **Data Persistence** - Models and configurations are preserved in a network volume

## Prerequisites

- Docker installed on your machine (for building the image)
- If using an M1/M2/M3 Mac, use Docker Desktop with emulation support
- A RunPod account with credits or an available GPU
- A Hugging Face account (for model downloading)

## Building the Docker Image

1. Clone this repository:
```bash
git clone https://github.com/Seven-94/Runpod_ComfyUI.git
cd Runpod_ComfyUI
```

2. Build the Docker image:
```bash
# On x86_64/amd64 (Linux, Windows)
docker build -t runpod_comfyui .

# On Mac M1/M2/M3 (arm64)
docker buildx build --platform=linux/amd64 -t runpod_comfyui .
```

3. Publish the image to Docker Hub (optional):
```bash
docker tag runpod_comfyui your-username/runpod_comfyui:latest
docker push your-username/runpod_comfyui:latest
```

## Usage on RunPod

1. Log in to your [RunPod](https://www.runpod.io/) account
2. Create a new template using your Docker image
3. Configure the template with:
   - Container Start Command: `/start.sh`
   - Volume Mount Path: `/workspace`
   - Expose HTTP Ports: `8188,8888,3000`
   - Expose TCP Ports: `22`
4. Remember to add the `HF_TOKEN` environment variable with your Hugging Face token during deployment

For more details, check the [complete documentation](docs/GUIDE.md).

## Included Models

The following models are automatically downloaded from Hugging Face:
- t5xxl_fp16.safetensors (text encoder)
- clip_l.safetensors (text encoder)
- ae.safetensors (VAE)
- flux1-dev.safetensors (diffusion model)

## Project Structure

- `Dockerfile` - Main file for building the Docker image
- `config/` - Configuration files for ComfyUI, Nginx and startup scripts
- `docs/` - Additional documentation
- `scripts/` - Utility scripts

## Directory Organization

Once deployed, the container organizes files as follows:

```
/workspace/ComfyUI/              # Main ComfyUI directory
├── custom_nodes/                # Extensions and custom nodes
├── input/                       # Directory for input files
├── models/                      # All models
│   ├── checkpoints/             # Base models (checkpoint)
│   ├── clip/                    # CLIP models
│   ├── clip_vision/             # CLIP Vision models
│   ├── controlnet/              # ControlNet models
│   ├── diffusion_models/        # Diffusion models (like Flux)
│   ├── embeddings/              # Text embeddings
│   ├── loras/                   # LoRA models
│   ├── text_encoders/           # Text encoders
│   ├── upscale_models/          # Upscaling models
│   └── vae/                     # VAE models
└── output/                      # Generated images
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.