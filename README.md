# ComfyUI pour RunPod avec CUDA 12.8 - Compatible RTX 5090

Ce dépôt contient les fichiers nécessaires pour créer un conteneur Docker optimisé pour exécuter ComfyUI sur la plateforme RunPod avec CUDA 12.8, spécialement configuré pour les GPU NVIDIA de dernière génération, y compris la RTX 5090.


## Fonctionnalités

- **Base CUDA 12.8** - Support complet des GPU de dernière génération (RTX 5090, 4090, 4080, etc.)
- **Image NGC PyTorch 25.02** - Utilise l'image officielle NVIDIA NGC avec PyTorch pour des performances maximales
- **Architecture GPU étendue** - Support natif pour les compute capabilities 8.6, 9.0, 12.0 et 12.6
- **Téléchargement automatique des modèles** - Les modèles sont téléchargés depuis Hugging Face au premier démarrage
- **Extensions pré-installées** - ComfyUI-Manager, sdxl_prompt_styler, ComfyUI_TensorRT et plus
- **Interface web avec Nginx** - Configuration optimisée pour l'accès à distance
- **Support JupyterLab** - Pour le développement et l'exploration des fonctionnalités
- **Persistance des données** - Les modèles et les configurations sont conservés dans un volume network

## Prérequis

- Docker installé sur votre machine (pour la construction de l'image)
- Si vous utilisez un Mac avec puce Apple Silicon (M1/M2/M3), utilisez Docker Desktop avec support d'émulation
- Un compte RunPod avec des crédits ou un GPU disponible
- Un compte Hugging Face (pour le téléchargement des modèles)

## Démarrage rapide

1. **Clonez ce dépôt** :
```bash
git clone https://github.com/Seven-94/Runpod_ComfyUI.git
cd Runpod_ComfyUI
```

2. **Construisez l'image Docker** :
```bash
# Sur x86_64/amd64 (Linux, Windows)
docker build -t runpod_comfyui .

# Sur Mac M1/M2/M3 (arm64)
docker buildx build --platform=linux/amd64 -t runpod_comfyui .
```

3. **Publiez l'image sur Docker Hub** :
```bash
docker tag runpod_comfyui votre-username/runpod_comfyui:latest
docker push votre-username/runpod_comfyui:latest
```

4. **Déployez sur RunPod** :
   - Créez un template avec votre image Docker
   - Configurez la commande de démarrage : `/start.sh`
   - Exposez les ports HTTP : `8188,8888,3000`
   - Exposez les ports TCP : `22`
   - Ajoutez la variable d'environnement `HF_TOKEN` avec votre token Hugging Face

## Modèles inclus

Les modèles suivants sont téléchargés automatiquement depuis Hugging Face :
- **T5XXL (FP16)** - Encodeur de texte pour la génération d'embeddings textuels
- **CLIP-L** - Encodeur de texte CLIP Large pour la compréhension texte-image
- **FLUX VAE** - Autoencodeur variationnel pour la conversion latent/image
- **FLUX1-dev** - Modèle de diffusion FLUX1 (version développeur)

## Organisation des répertoires

```
/workspace/ComfyUI/              # Répertoire principal de ComfyUI
├── custom_nodes/                # Extensions et nœuds personnalisés
│   ├── ComfyUI-Manager/         # Gestionnaire d'extensions
│   ├── ComfyUI_TensorRT/        # Optimisations TensorRT
│   └── sdxl_prompt_styler/      # Stylisation de prompts pour SDXL
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

## Optimisations pour RTX 5090

Cette image est spécialement optimisée pour tirer pleinement parti des GPU de dernière génération comme la RTX 5090 :

- **Support d'architecture avancé** - Prise en charge native des architectures CUDA 8.6, 9.0, 12.0 et 12.6
- **Optimisations TensorRT** - Conversion des modèles pour une inférence accélérée
- **Transferts HF optimisés** - Utilise le nouveau backend de transfert HF pour des téléchargements plus rapides
- **xFormers intégré** - Optimisations d'attention pour réduire l'utilisation de VRAM et accélérer le traitement

## Accès aux services

- **ComfyUI** : http://votre-pod-ip:3000
- **JupyterLab** : http://votre-pod-ip:8888 (si activé via la variable `JUPYTER_PASSWORD`)
- **SSH** : `ssh root@votre-pod-ip` (mot de passe : runpod)

## Documentation complète

Pour des instructions détaillées sur la configuration, l'utilisation et les fonctionnalités avancées, consultez le [Guide d'utilisation](docs/GUIDE.md).

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

# ComfyUI for RunPod with CUDA 12.8 - RTX 5090 Compatible

This repository contains the files needed to create an optimized Docker container to run ComfyUI on the RunPod platform with CUDA 12.8, specially configured for the latest NVIDIA GPUs, including the RTX 5090.

## Features

- **CUDA 12.8 Base** - Full support for latest generation GPUs (RTX 5090, 4090, 4080, etc.)
- **NGC PyTorch 25.02 Image** - Uses official NVIDIA NGC image with PyTorch for maximum performance
- **Extended GPU Architecture** - Native support for compute capabilities 8.6, 9.0, 12.0, and 12.6
- **Automatic Model Download** - Models are downloaded from Hugging Face on first startup
- **Pre-installed Extensions** - ComfyUI-Manager, sdxl_prompt_styler, ComfyUI_TensorRT, and more
- **Web Interface with Nginx** - Optimized configuration for remote access
- **JupyterLab Support** - For development and feature exploration
- **Data Persistence** - Models and configurations are preserved in a network volume

## Prerequisites

- Docker installed on your machine (for building the image)
- If using a Mac with Apple Silicon (M1/M2/M3), use Docker Desktop with emulation support
- A RunPod account with credits or an available GPU
- A Hugging Face account (for model downloading)

## Quick Start

1. **Clone this repository**:
```bash
git clone https://github.com/Seven-94/Runpod_ComfyUI.git
cd Runpod_ComfyUI
```

2. **Build the Docker image**:
```bash
# On x86_64/amd64 (Linux, Windows)
docker build -t runpod_comfyui .

# On Mac M1/M2/M3 (arm64)
docker buildx build --platform=linux/amd64 -t runpod_comfyui .
```

3. **Publish the image to Docker Hub**:
```bash
docker tag runpod_comfyui your-username/runpod_comfyui:latest
docker push your-username/runpod_comfyui:latest
```

4. **Deploy on RunPod**:
   - Create a template with your Docker image
   - Configure the start command: `/start.sh`
   - Expose HTTP ports: `8188,8888,3000`
   - Expose TCP ports: `22`
   - Add the `HF_TOKEN` environment variable with your Hugging Face token

## Included Models

The following models are automatically downloaded from Hugging Face:
- **T5XXL (FP16)** - Text encoder for generating text embeddings
- **CLIP-L** - CLIP Large text encoder for text-image understanding
- **FLUX VAE** - Variational autoencoder for latent/image conversion
- **FLUX1-dev** - FLUX1 diffusion model (developer version)

## Directory Organization

```
/workspace/ComfyUI/              # Main ComfyUI directory
├── custom_nodes/                # Extensions and custom nodes
│   ├── ComfyUI-Manager/         # Extension manager
│   ├── ComfyUI_TensorRT/        # TensorRT optimizations
│   └── sdxl_prompt_styler/      # Prompt styling for SDXL
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

## RTX 5090 Optimizations

This image is specially optimized to take full advantage of the latest generation GPUs like the RTX 5090:

- **Advanced Architecture Support** - Native support for CUDA architectures 8.6, 9.0, 12.0, and 12.6
- **TensorRT Optimizations** - Model conversion for accelerated inference
- **Optimized HF Transfers** - Uses the new HF transfer backend for faster downloads
- **Built-in xFormers** - Attention optimizations to reduce VRAM usage and speed up processing

## Accessing Services

- **ComfyUI**: http://your-pod-ip:3000
- **JupyterLab**: http://your-pod-ip:8888 (if enabled via the `JUPYTER_PASSWORD` variable)
- **SSH**: `ssh root@your-pod-ip` (password: runpod)

## Complete Documentation

For detailed instructions on configuration, usage, and advanced features, check the [User Guide](docs/GUIDE.md).

## Contributing

Contributions are welcome! Feel free to open an issue or pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.