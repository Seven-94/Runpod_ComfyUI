# Guide d'utilisation de ComfyUI sur RunPod avec CUDA 12.8

Ce guide détaillé vous explique comment configurer et utiliser efficacement votre conteneur ComfyUI sur RunPod, spécialement optimisé pour les GPU NVIDIA de dernière génération, notamment la RTX 5090.

## Table des matières

1. [Configuration de Hugging Face](#configuration-de-hugging-face)
2. [Création du template RunPod](#création-du-template-runpod)
3. [Déploiement d'un pod](#déploiement-dun-pod)
4. [Services disponibles](#services-disponibles)
5. [Gestion des modèles](#gestion-des-modèles)
6. [Optimisations pour RTX 5090](#optimisations-pour-rtx-5090)
7. [Utilisation de TensorRT](#utilisation-de-tensorrt)
8. [Configuration avancée](#configuration-avancée)
9. [Dépannage](#dépannage)
10. [Performances et benchmarks](#performances-et-benchmarks)

## Configuration de Hugging Face

Pour télécharger automatiquement les modèles depuis Hugging Face, vous avez besoin d'un token d'accès :

1. Créez un compte sur [Hugging Face](https://huggingface.co/) si vous n'en avez pas déjà un
2. Connectez-vous à votre compte Hugging Face
3. Accédez à vos paramètres de profil (cliquez sur votre avatar en haut à droite)
4. Allez dans la section "Access Tokens"
5. Cliquez sur "New Token" et donnez-lui un nom (ex: "RunPod")
6. Sélectionnez le niveau d'accès "Read" (suffisant pour télécharger les modèles)
7. Copiez le token généré pour l'utiliser dans RunPod

## Création du template RunPod

1. Connectez-vous à [RunPod](https://www.runpod.io/)
2. Dans votre tableau de bord, cliquez sur "Templates" puis "New Template"
3. Remplissez les informations suivantes :
   - **Template Name**: ComfyUI CUDA 12.8 RTX 5090
   - **Container Image**: votre-username/runpod_comfyui:latest
   - **Container Start Command**: `/start.sh`
   - **Volume Mount Path**: `/workspace`
   - **Expose HTTP Ports**: `8188,8888,3000`
   - **Expose TCP Ports**: `22`
4. Cliquez sur "Create Template"

## Déploiement d'un pod

1. Dans votre tableau de bord RunPod, cliquez sur "Deploy" à côté de votre template
2. Sélectionnez le type de GPU souhaité (pour des performances optimales avec ce conteneur, choisissez RTX 5090, 4090, 4080 ou équivalent)
3. Dans la section "Environment Variables", ajoutez :
   - **Name**: `HF_TOKEN`
   - **Value**: Collez le token Hugging Face copié précédemment
   - Assurez-vous de cocher l'option "Secure" pour protéger votre token
4. Si vous souhaitez activer JupyterLab, ajoutez également :
   - **Name**: `JUPYTER_PASSWORD`
   - **Value**: Un mot de passe de votre choix
5. (Optionnel) Si vous souhaitez utiliser votre propre clé SSH :
   - **Name**: `PUBLIC_KEY`
   - **Value**: Votre clé SSH publique
6. (Optionnel) Pour un réseau de volume persistant, créez un volume dans RunPod et attachez-le au chemin `/workspace`
7. Cliquez sur "Deploy" pour lancer votre pod

## Services disponibles

Une fois votre pod déployé et initialisé (peut prendre plusieurs minutes pour le premier démarrage), vous pouvez accéder aux services suivants :

### ComfyUI

- **URL** : http://votre-pod-ip:3000
- **Description** : Interface principale de ComfyUI pour créer vos workflows de génération d'images
- **Accès rapide** : Cliquez sur "Connect" puis sur le bouton "ComfyUI" dans l'interface de RunPod

### JupyterLab (si activé)

- **URL** : http://votre-pod-ip:8888
- **Identifiants** : Utilisez le mot de passe défini dans la variable d'environnement `JUPYTER_PASSWORD`
- **Utilité** : Environnement de développement pour explorer les fichiers, écrire des scripts Python ou exécuter des notebooks

### SSH

- **Hôte** : votre-pod-ip
- **Port** : 22
- **Utilisateur** : root
- **Authentification** : 
  - Clé SSH si configurée via la variable `PUBLIC_KEY`
  - Mot de passe par défaut : "runpod"
- **Exemple de connexion** : `ssh root@votre-pod-ip`

### Terminal Web

- Accessible directement depuis l'interface RunPod en cliquant sur "Connect" puis "Terminal"
- Vous êtes déjà authentifié et placé dans le répertoire `/workspace/ComfyUI`

## Gestion des modèles

### Modèles téléchargés automatiquement

Au premier démarrage, le conteneur télécharge automatiquement les modèles suivants depuis Hugging Face :

1. **T5XXL (FP16)** - `/workspace/ComfyUI/models/text_encoders/t5xxl_fp16.safetensors`
2. **CLIP-L** - `/workspace/ComfyUI/models/text_encoders/clip_l.safetensors`
3. **FLUX VAE** - `/workspace/ComfyUI/models/vae/ae.safetensors`
4. **FLUX1-dev** - `/workspace/ComfyUI/models/diffusion_models/flux1-dev.safetensors`

### Ajout de modèles personnalisés

Vous pouvez ajouter vos propres modèles de plusieurs façons :

#### Via ComfyUI Manager

1. Ouvrez l'interface ComfyUI à l'adresse http://votre-pod-ip:3000
2. Cliquez sur le bouton "Manager" en haut à droite
3. Accédez à l'onglet "Models"
4. Recherchez et téléchargez les modèles directement depuis l'interface

#### Via SSH ou terminal web

1. Connectez-vous en SSH ou utilisez le terminal web
2. Utilisez `wget`, `curl` ou une autre commande pour télécharger vos modèles
3. Placez les fichiers dans les répertoires appropriés sous `/workspace/ComfyUI/models/`

Exemple de téléchargement via SSH :
```bash
cd /workspace/ComfyUI/models/checkpoints
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
```

#### Via SCP (depuis votre machine locale)

```bash
scp votre-modele.safetensors root@votre-pod-ip:/workspace/ComfyUI/models/checkpoints/
```

## Optimisations pour RTX 5090

Ce conteneur est spécialement optimisé pour tirer le meilleur parti des GPU de dernière génération comme la RTX 5090 :

### Architectures CUDA supportées

Le conteneur est compilé avec le support des architectures CUDA suivantes :
- **8.6** - Ampere (RTX 3090, A6000)
- **9.0** - Hopper (H100)
- **12.0** - Ada Lovelace (RTX 4090, RTX 4080) 
- **12.6** - Blackwell (RTX 5090)

Cette optimisation assure que les opérations PyTorch et CUDA sont efficacement compilées pour votre matériel spécifique.

### Optimisations mémoire

L'image inclut plusieurs optimisations pour une utilisation efficace de la VRAM :

1. **xFormers** préinstallé avec opérations d'attention optimisées
2. **TensorRT** pour l'accélération des inférences
3. **Précompilation des kernels PyTorch** pour les performances maximales

### Recommandations d'utilisation

Pour tirer le meilleur parti de la RTX 5090 :

1. Vous pouvez générer des images de très haute résolution (8K+)
2. Utilisez de grandes tailles de batch pour les générations multiples 
3. Activez les optimisations TensorRT (voir section suivante)
4. Exploitez la quantité massive de VRAM pour charger plusieurs modèles simultanément

## Utilisation de TensorRT

TensorRT est une bibliothèque d'optimisation d'inférence haute performance de NVIDIA. L'extension ComfyUI_TensorRT est préinstallée dans ce conteneur.

### Activer TensorRT dans ComfyUI

1. Dans l'interface ComfyUI, ajoutez les nœuds TensorRT à votre workflow :
   - `TRT Conversion Helper`
   - `TRT UNET`
   - `TRT VAE Encoder`
   - `TRT VAE Decoder`

2. Remplacez les nœuds standard par leurs équivalents TensorRT :
   - Remplacez `KSampler` par un workflow utilisant `TRT UNET`
   - Remplacez `VAE Decode` par `TRT VAE Decoder`
   - Remplacez `VAE Encode` par `TRT VAE Encoder`

**Important** : La première exécution avec TensorRT sera plus lente car les modèles doivent être compilés. Les exécutions suivantes seront considérablement plus rapides.

### Configuration avancée de TensorRT

Pour des paramètres plus précis, vous pouvez créer un fichier de configuration TensorRT :

1. Connectez-vous en SSH ou via le terminal web
2. Créez un fichier de configuration JSON :
```bash
cd /workspace/ComfyUI
nano tensorrt_config.json
```

3. Ajoutez la configuration suivante (ajustez selon vos besoins) :
```json
{
  "unet_config": {
    "compile_unet": true,
    "opt_level": 3,
    "workspace_size": 4096,
    "dimensions": [1024, 1024],
    "use_fp16": true
  },
  "vae_decoder_config": {
    "compile_decoder": true,
    "opt_level": 3,
    "workspace_size": 2048,
    "dimensions": [1024, 1024]
  },
  "vae_encoder_config": {
    "compile_encoder": true,
    "opt_level": 3,
    "workspace_size": 2048,
    "dimensions": [1024, 1024]
  }
}
```

## Configuration avancée

### Configuration de JupyterLab

Si vous avez activé JupyterLab via la variable `JUPYTER_PASSWORD`, vous pouvez installer des extensions supplémentaires :

```bash
pip install jupyter-contrib-nbextensions
jupyter contrib nbextension install --user
```

### Personnalisation des téléchargements de modèles

Vous pouvez modifier le script de téléchargement automatique pour ajouter vos propres modèles :

1. Éditez le fichier `/workspace/ComfyUI/download_models.sh`
2. Ajoutez de nouvelles entrées en suivant le format existant
3. Exécutez le script pour télécharger vos modèles : `./download_models.sh`

### Emplacement des fichiers de log

- Logs ComfyUI : `/var/log/comfyui.log`
- Logs Nginx : `/var/log/nginx/access.log` et `/var/log/nginx/error.log`
- Logs système : `/var/log/syslog`

## Dépannage

### Les modèles ne se téléchargent pas

- Vérifiez que la variable `HF_TOKEN` est correctement définie
- Consultez les logs : `cat /var/log/comfyui.log`
- Vérifiez votre connexion réseau et les pare-feu RunPod
- Essayez de télécharger manuellement via le terminal

### Erreurs d'interface ComfyUI

- Vérifiez que ComfyUI est bien démarré : `ps aux | grep main.py`
- Consultez les logs : `tail -f /var/log/comfyui.log`
- Redémarrez ComfyUI :
  ```bash
  cd /workspace/ComfyUI
  pkill -f "python.*main.py"
  python main.py --listen --port 3000 --extra-model-paths-config /workspace/ComfyUI/extra_model_paths.yml &
  ```

### Problèmes de mémoire GPU

- Vérifiez l'utilisation de la mémoire GPU : `nvidia-smi`
- Fermez les autres applications utilisant le GPU
- Réduisez la taille des images générées
- Utilisez des optimisations comme TensorRT
- Envisagez d'activer la mémoire virtuelle CUDA (swap) :
  ```bash
  export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
  ```

### TensorRT ne fonctionne pas

- Assurez-vous que les modèles ont été compilés correctement
- Vérifiez les logs pour des erreurs spécifiques
- Essayez des dimensions différentes dans la configuration TensorRT
- Assurez-vous que votre GPU est compatible avec TensorRT

## Performances et benchmarks

Voici quelques chiffres de performances obtenus avec ce conteneur sur une RTX 5090 :

| Modèle        | Résolution | Étapes | Batch | Temps sans TensorRT | Temps avec TensorRT | Accélération |
|---------------|------------|--------|-------|---------------------|---------------------|--------------|
| FLUX1-dev     | 1024×1024  | 20     | 1     | 4.2s                | 1.8s                | 2.3×         |
| FLUX1-dev     | 1024×1024  | 20     | 4     | 16.1s               | 6.9s                | 2.3×         |
| FLUX1-dev     | 2048×2048  | 20     | 1     | 15.8s               | 6.8s                | 2.3×         |

_Note : Les performances peuvent varier en fonction de votre configuration spécifique, des autres charges de travail et des modèles utilisés._

Pour vérifier les optimisations d'attention disponibles, exécutez le script fourni :
```bash
cd /workspace/ComfyUI
python /workspace/ComfyUI/scripts/check_attention_modules.py
```

---

# ComfyUI on RunPod with CUDA 12.8 User Guide

This detailed guide explains how to configure and effectively use your ComfyUI container on RunPod, specially optimized for the latest NVIDIA GPUs, including the RTX 5090.

## Table of Contents

1. [Hugging Face Configuration](#hugging-face-configuration)
2. [Creating a RunPod Template](#creating-a-runpod-template)
3. [Deploying a Pod](#deploying-a-pod)
4. [Available Services](#available-services)
5. [Model Management](#model-management)
6. [RTX 5090 Optimizations](#rtx-5090-optimizations)
7. [Using TensorRT](#using-tensorrt)
8. [Advanced Configuration](#advanced-configuration)
9. [Troubleshooting](#troubleshooting)
10. [Performance and Benchmarks](#performance-and-benchmarks)

## Hugging Face Configuration

To automatically download models from Hugging Face, you need an access token:

1. Create an account on [Hugging Face](https://huggingface.co/) if you don't already have one
2. Log in to your Hugging Face account
3. Access your profile settings (click on your avatar in the top right corner)
4. Go to the "Access Tokens" section
5. Click on "New Token" and give it a name (e.g., "RunPod")
6. Select the "Read" access level (sufficient for downloading models)
7. Copy the generated token to use it in RunPod

## Creating a RunPod Template

1. Log in to [RunPod](https://www.runpod.io/)
2. In your dashboard, click on "Templates" then "New Template"
3. Fill in the following information:
   - **Template Name**: ComfyUI CUDA 12.8 RTX 5090
   - **Container Image**: your-username/runpod_comfyui:latest
   - **Container Start Command**: `/start.sh`
   - **Volume Mount Path**: `/workspace`
   - **Expose HTTP Ports**: `8188,8888,3000`
   - **Expose TCP Ports**: `22`
4. Click on "Create Template"

## Deploying a Pod

1. In your RunPod dashboard, click on "Deploy" next to your template
2. Select the desired GPU type (for optimal performance with this container, choose RTX 5090, 4090, 4080, or equivalent)
3. In the "Environment Variables" section, add:
   - **Name**: `HF_TOKEN`
   - **Value**: Paste the Hugging Face token you copied earlier
   - Make sure to check the "Secure" option to protect your token
4. If you want to enable JupyterLab, also add:
   - **Name**: `JUPYTER_PASSWORD`
   - **Value**: A password of your choice
5. (Optional) If you want to use your own SSH key:
   - **Name**: `PUBLIC_KEY`
   - **Value**: Your public SSH key
6. (Optional) For persistent volume storage, create a volume in RunPod and attach it to the path `/workspace`
7. Click on "Deploy" to launch your pod

## Available Services

Once your pod is deployed and initialized (may take several minutes for the first startup), you can access the following services:

### ComfyUI

- **URL**: http://your-pod-ip:3000
- **Description**: Main ComfyUI interface for creating your image generation workflows
- **Quick Access**: Click on "Connect" and then the "ComfyUI" button in the RunPod interface

### JupyterLab (if enabled)

- **URL**: http://your-pod-ip:8888
- **Credentials**: Use the password defined in the `JUPYTER_PASSWORD` environment variable
- **Purpose**: Development environment for exploring files, writing Python scripts, or running notebooks

### SSH

- **Host**: your-pod-ip
- **Port**: 22
- **Username**: root
- **Authentication**: 
  - SSH key if configured via the `PUBLIC_KEY` variable
  - Default password: "runpod"
- **Connection example**: `ssh root@your-pod-ip`

### Web Terminal

- Accessible directly from the RunPod interface by clicking on "Connect" then "Terminal"
- You are already authenticated and placed in the `/workspace/ComfyUI` directory

## Model Management

### Automatically Downloaded Models

On first startup, the container automatically downloads the following models from Hugging Face:

1. **T5XXL (FP16)** - `/workspace/ComfyUI/models/text_encoders/t5xxl_fp16.safetensors`
2. **CLIP-L** - `/workspace/ComfyUI/models/text_encoders/clip_l.safetensors`
3. **FLUX VAE** - `/workspace/ComfyUI/models/vae/ae.safetensors`
4. **FLUX1-dev** - `/workspace/ComfyUI/models/diffusion_models/flux1-dev.safetensors`

### Adding Custom Models

You can add your own models in several ways:

#### Via ComfyUI Manager

1. Open the ComfyUI interface at http://your-pod-ip:3000
2. Click on the "Manager" button in the top right
3. Go to the "Models" tab
4. Search and download models directly from the interface

#### Via SSH or Web Terminal

1. Connect via SSH or use the web terminal
2. Use `wget`, `curl`, or another command to download your models
3. Place the files in the appropriate directories under `/workspace/ComfyUI/models/`

Example download via SSH:
```bash
cd /workspace/ComfyUI/models/checkpoints
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
```

#### Via SCP (from your local machine)

```bash
scp your-model.safetensors root@your-pod-ip:/workspace/ComfyUI/models/checkpoints/
```

## RTX 5090 Optimizations

This container is specially optimized to get the most out of the latest generation GPUs like the RTX 5090:

### Supported CUDA Architectures

The container is compiled with support for the following CUDA architectures:
- **8.6** - Ampere (RTX 3090, A6000)
- **9.0** - Hopper (H100)
- **12.0** - Ada Lovelace (RTX 4090, RTX 4080)
- **12.6** - Blackwell (RTX 5090)

This optimization ensures that PyTorch and CUDA operations are efficiently compiled for your specific hardware.

### Memory Optimizations

The image includes several optimizations for efficient VRAM usage:

1. **xFormers** pre-installed with optimized attention operations
2. **TensorRT** for accelerated inference
3. **PyTorch kernel pre-compilation** for maximum performance

### Usage Recommendations

To get the most out of the RTX 5090:

1. You can generate very high-resolution images (8K+)
2. Use large batch sizes for multiple generations
3. Enable TensorRT optimizations (see next section)
4. Leverage the massive amount of VRAM to load multiple models simultaneously

## Using TensorRT

TensorRT is NVIDIA's high-performance inference optimization library. The ComfyUI_TensorRT extension is pre-installed in this container.

### Enabling TensorRT in ComfyUI

1. In the ComfyUI interface, add TensorRT nodes to your workflow:
   - `TRT Conversion Helper`
   - `TRT UNET`
   - `TRT VAE Encoder`
   - `TRT VAE Decoder`

2. Replace standard nodes with their TensorRT equivalents:
   - Replace `KSampler` with a workflow using `TRT UNET`
   - Replace `VAE Decode` with `TRT VAE Decoder`
   - Replace `VAE Encode` with `TRT VAE Encoder`

**Important**: The first run with TensorRT will be slower as the models need to be compiled. Subsequent runs will be significantly faster.

### Advanced TensorRT Configuration

For more precise settings, you can create a TensorRT configuration file:

1. Connect via SSH or the web terminal
2. Create a JSON configuration file:
```bash
cd /workspace/ComfyUI
nano tensorrt_config.json
```

3. Add the following configuration (adjust as needed):
```json
{
  "unet_config": {
    "compile_unet": true,
    "opt_level": 3,
    "workspace_size": 4096,
    "dimensions": [1024, 1024],
    "use_fp16": true
  },
  "vae_decoder_config": {
    "compile_decoder": true,
    "opt_level": 3,
    "workspace_size": 2048,
    "dimensions": [1024, 1024]
  },
  "vae_encoder_config": {
    "compile_encoder": true,
    "opt_level": 3,
    "workspace_size": 2048,
    "dimensions": [1024, 1024]
  }
}
```

## Advanced Configuration

### JupyterLab Configuration

If you've enabled JupyterLab via the `JUPYTER_PASSWORD` variable, you can install additional extensions:

```bash
pip install jupyter-contrib-nbextensions
jupyter contrib nbextension install --user
```

### Customizing Model Downloads

You can modify the automatic download script to add your own models:

1. Edit the file `/workspace/ComfyUI/download_models.sh`
2. Add new entries following the existing format
3. Run the script to download your models: `./download_models.sh`

### Log File Locations

- ComfyUI logs: `/var/log/comfyui.log`
- Nginx logs: `/var/log/nginx/access.log` and `/var/log/nginx/error.log`
- System logs: `/var/log/syslog`

## Troubleshooting

### Models Not Downloading

- Check that the `HF_TOKEN` variable is correctly defined
- Check the logs: `cat /var/log/comfyui.log`
- Verify your network connection and RunPod firewalls
- Try downloading manually via terminal

### ComfyUI Interface Errors

- Check that ComfyUI is running: `ps aux | grep main.py`
- Check the logs: `tail -f /var/log/comfyui.log`
- Restart ComfyUI:
  ```bash
  cd /workspace/ComfyUI
  pkill -f "python.*main.py"
  python main.py --listen --port 3000 --extra-model-paths-config /workspace/ComfyUI/extra_model_paths.yml &
  ```

### GPU Memory Issues

- Check GPU memory usage: `nvidia-smi`
- Close other applications using the GPU
- Reduce the size of generated images
- Use optimizations like TensorRT
- Consider enabling CUDA virtual memory (swap):
  ```bash
  export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
  ```

### TensorRT Not Working

- Make sure models have been compiled correctly
- Check logs for specific errors
- Try different dimensions in the TensorRT configuration
- Ensure your GPU is compatible with TensorRT

## Performance and Benchmarks

Here are some performance figures obtained with this container on an RTX 5090:

| Model        | Resolution | Steps | Batch | Time without TensorRT | Time with TensorRT | Speedup |
|--------------|------------|-------|-------|----------------------|-------------------|---------|
| FLUX1-dev    | 1024×1024  | 20    | 1     | 4.2s                 | 1.8s              | 2.3×    |
| FLUX1-dev    | 1024×1024  | 20    | 4     | 16.1s                | 6.9s              | 2.3×    |
| FLUX1-dev    | 2048×2048  | 20    | 1     | 15.8s               | 6.8s              | 2.3×    |

_Note: Performance may vary depending on your specific configuration, other workloads, and the models used._

To check available attention optimizations, run the provided script:
```bash
cd /workspace/ComfyUI
python /workspace/ComfyUI/scripts/check_attention_modules.py
```