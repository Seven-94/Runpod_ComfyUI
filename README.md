# ComfyUI pour RunPod avec CUDA 12.8

Ce dépôt contient les fichiers nécessaires pour créer un conteneur Docker optimisé pour exécuter ComfyUI sur la plateforme RunPod avec CUDA 12.8.1.

## Fonctionnalités

- **Base CUDA 12.8.1** - Support des GPU plus récents avec la dernière version CUDA
- **Téléchargement de modèles à la demande** - Les modèles sont téléchargés depuis Hugging Face au premier démarrage
- **Extensions pré-installées** - ComfyUI-Manager, sdxl_prompt_styler, ComfyUI_TensorRT et plus
- **Interface web avec Nginx** - Configuration optimisée pour l'accès à distance
- **Support JupyterLab** - Pour le développement et l'exploration des fonctionnalités

## Prérequis

- Docker installé sur votre machine (pour la construction de l'image)
- Si vous utilisez un Mac M1/M2/M3, utilisez Docker Desktop avec support d'émulation
- Un compte RunPod avec des crédits ou un GPU disponible
- Un compte Hugging Face (pour le téléchargement des modèles)

## Construction de l'image Docker

1. Clonez ce dépôt :
```bash
git clone https://github.com/votre-username/comfyui-runpod.git
cd comfyui-runpod
```

2. Construisez l'image Docker :
```bash
# Sur x86_64/amd64 (Linux, Windows)
docker build -t comfyui-runpod .

# Sur Mac M1/M2/M3 (arm64)
docker buildx build --platform=linux/amd64 -t comfyui-runpod .
```

3. Publiez l'image sur Docker Hub (optionnel) :
```bash
docker tag comfyui-runpod votre-username/comfyui-runpod:latest
docker push votre-username/comfyui-runpod:latest
```

## Utilisation sur RunPod

1. Connectez-vous à votre compte [RunPod](https://www.runpod.io/)
2. Créez un nouveau template en utilisant votre image Docker
3. Configurez le template avec :
   - Container Start Command: `/start.sh`
   - Volume Mount Path: `/workspace/comfyui`
   - Expose HTTP Ports: `8188,8888,3000`
   - Expose TCP Ports: `22`
4. N'oubliez pas d'ajouter la variable d'environnement `HF_TOKEN` avec votre token Hugging Face lors du déploiement

Pour plus de détails, consultez la [documentation complète](docs/GUIDE.md).

## Modèles inclus

Les modèles suivants sont téléchargés automatiquement depuis Hugging Face :
- t5xxl_fp16.safetensors (text encoder)
- clip_l.safetensors (text encoder)
- ae.safetensors (VAE)
- flux1-dev.safetensors (diffusion model)

## Structure du projet

- `Dockerfile` - Fichier principal pour la construction de l'image Docker
- `config/` - Fichiers de configuration pour ComfyUI, Nginx et scripts de démarrage
- `docs/` - Documentation supplémentaire
- `scripts/` - Scripts utilitaires

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

# ComfyUI for RunPod with CUDA 12.8

This repository contains the files needed to create an optimized Docker container to run ComfyUI on the RunPod platform with CUDA 12.8.1.

## Features

- **CUDA 12.8.1 Base** - Support for newer GPUs with the latest CUDA version
- **On-demand Model Download** - Models are downloaded from Hugging Face on first startup
- **Pre-installed Extensions** - ComfyUI-Manager, sdxl_prompt_styler, ComfyUI_TensorRT and more
- **Web Interface with Nginx** - Optimized configuration for remote access
- **JupyterLab Support** - For development and feature exploration

## Prerequisites

- Docker installed on your machine (for building the image)
- If using an M1/M2/M3 Mac, use Docker Desktop with emulation support
- A RunPod account with credits or an available GPU
- A Hugging Face account (for model downloading)

## Building the Docker Image

1. Clone this repository:
```bash
git clone https://github.com/your-username/comfyui-runpod.git
cd comfyui-runpod
```

2. Build the Docker image:
```bash
# On x86_64/amd64 (Linux, Windows)
docker build -t comfyui-runpod .

# On Mac M1/M2/M3 (arm64)
docker buildx build --platform=linux/amd64 -t comfyui-runpod .
```

3. Publish the image to Docker Hub (optional):
```bash
docker tag comfyui-runpod your-username/comfyui-runpod:latest
docker push your-username/comfyui-runpod:latest
```

## Usage on RunPod

1. Log in to your [RunPod](https://www.runpod.io/) account
2. Create a new template using your Docker image
3. Configure the template with:
   - Container Start Command: `/start.sh`
   - Volume Mount Path: `/workspace/comfyui`
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

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.