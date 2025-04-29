# Guide d'utilisation de ComfyUI sur RunPod

Ce guide vous explique comment configurer et utiliser votre conteneur ComfyUI sur RunPod.

## Configuration de Hugging Face

Pour télécharger automatiquement les modèles depuis Hugging Face, vous avez besoin d'un token d'accès :

1. Créez un compte sur [Hugging Face](https://huggingface.co/) si vous n'en avez pas déjà un.
2. Connectez-vous à votre compte Hugging Face.
3. Accédez à vos paramètres de profil (cliquez sur votre avatar en haut à droite).
4. Allez dans la section "Access Tokens".
5. Cliquez sur "New Token" et donnez-lui un nom (ex: "RunPod").
6. Sélectionnez le niveau d'accès "Read" (suffisant pour télécharger les modèles).
7. Copiez le token généré pour l'utiliser dans RunPod.

## Création du template RunPod

1. Connectez-vous à [RunPod](https://www.runpod.io/).
2. Dans votre tableau de bord, cliquez sur "Templates" puis "New Template".
3. Remplissez les informations suivantes :
   - **Template Name**: ComfyUI CUDA 12.8
   - **Container Image**: votre-username/runpod_comfyui:latest
   - **Container Start Command**: `/start.sh`
   - **Volume Mount Path**: `/workspace`
   - **Expose HTTP Ports**: `8188,8888,3000`
   - **Expose TCP Ports**: `22`
4. Cliquez sur "Create Template".

## Déploiement d'un pod

1. Dans votre tableau de bord RunPod, cliquez sur "Deploy" à côté de votre template.
2. Sélectionnez le type de GPU souhaité.
3. Dans la section "Environment Variables", ajoutez :
   - **Name**: `HF_TOKEN`
   - **Value**: Collez le token Hugging Face copié précédemment
   - Assurez-vous de cocher l'option "Secure" pour protéger votre token
4. Si vous souhaitez activer JupyterLab, ajoutez également :
   - **Name**: `JUPYTER_PASSWORD`
   - **Value**: Un mot de passe de votre choix
5. Cliquez sur "Deploy" pour lancer votre pod.

## Utilisation du pod

Une fois votre pod déployé et initialisé (peut prendre plusieurs minutes pour le téléchargement des modèles), vous pouvez accéder aux services suivants :

### ComfyUI

- URL : http://votre-pod-ip:3000
- C'est l'interface principale de ComfyUI où vous pouvez créer vos workflows de génération d'images.

### JupyterLab (si activé)

- URL : http://votre-pod-ip:8888
- Utilisez le mot de passe défini dans la variable d'environnement `JUPYTER_PASSWORD`.
- Utile pour explorer les fichiers, écrire des scripts Python ou des notebooks Jupyter.

### SSH

- Hôte : votre-pod-ip
- Port : 22
- Utilisateur : root
- Authentification : Clé SSH (à configurer via la variable `PUBLIC_KEY`) ou mot de passe "runpod"

## Structure des répertoires

Dans votre pod, vous trouverez l'organisation suivante :

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

## Persistance des données

Pour conserver vos modèles et sorties entre les redémarrages de pod :

1. Allez dans la section "Volumes" de RunPod et créez un nouveau volume.
2. Lors du déploiement de votre pod, associez ce volume au chemin `/workspace`.

## Ajout de modèles personnalisés

Vous pouvez ajouter vos propres modèles de plusieurs façons :

1. **Via JupyterLab** : Téléchargez vos fichiers dans les répertoires correspondants.
2. **Via SSH** : Utilisez `scp` ou `rsync` pour transférer vos modèles.
3. **Via ComfyUI Manager** : Utilisez l'interface de ComfyUI Manager pour télécharger les modèles directement.

Par exemple, pour ajouter un nouveau checkpoint via SSH :
```bash
scp votre-checkpoint.safetensors root@votre-pod-ip:/workspace/ComfyUI/models/checkpoints/
```

## Extensions préinstallées

Ce conteneur inclut plusieurs extensions préinstallées :

- **ComfyUI-Manager** : Interface de gestion des extensions et modèles
- **SDXL Prompt Styler** : Stylisation de prompts pour SDXL
- **ComfyUI TensorRT** : Optimisation TensorRT pour une meilleure performance

Vous pouvez installer d'autres extensions via ComfyUI Manager ou manuellement en les clonant dans le répertoire `/workspace/ComfyUI/custom_nodes/`.

## Dépannage

### Les modèles ne se téléchargent pas

- Vérifiez que la variable `HF_TOKEN` est correctement définie.
- Consultez les logs du pod pour voir les erreurs de téléchargement : `cat /var/log/comfyui.log`
- Essayez de télécharger manuellement les modèles via SSH.

### Erreurs d'interface ComfyUI

- Vérifiez que ComfyUI est bien démarré : `ps aux | grep ComfyUI`
- Consultez les logs de ComfyUI : `tail -f /var/log/comfyui.log`
- Redémarrez le service : 
  ```bash
  cd /workspace/ComfyUI
  pkill -f "python.*main.py"
  python main.py --listen --port 3000 --extra-model-paths-config /workspace/ComfyUI/extra_model_paths.yml &
  ```

### Problèmes de répertoire de travail

- Par défaut, le terminal web s'ouvre dans `/workspace/ComfyUI`
- Si vous atterrissez dans un autre répertoire, exécutez `cd /workspace/ComfyUI`

### Problèmes de mémoire GPU

- Utilisez les workflows optimisés pour votre GPU spécifique.
- Ajustez les tailles des images générées en fonction de la VRAM disponible.
- Sur les modèles SDXL, utilisez l'extension ComfyUI_TensorRT pour optimiser la mémoire.
- Utilisez le nœud VAE-TAESD pour l'encodage/décodage en basse précision et économiser la VRAM.

### Configuration extra_model_paths.yml

Le fichier de configuration `/workspace/ComfyUI/extra_model_paths.yml` permet à ComfyUI de trouver les modèles dans les sous-répertoires correspondants. Si vous rencontrez des problèmes avec les chemins des modèles, vérifiez ce fichier :

```bash
cat /workspace/ComfyUI/extra_model_paths.yml
```

La configuration doit ressembler à ceci :

```yaml
runpod_ComfyUI:
  base_path: /workspace/ComfyUI
  checkpoints: models/checkpoints/
  clip: models/clip/
  clip_vision: models/clip_vision/
  configs: models/configs/
  controlnet: models/controlnet/
  embeddings: models/embeddings/
  loras: models/loras/
  upscale_models: models/upscale_models/
  vae: models/vae/
  unet: models/unet/
  text_encoders: models/text_encoders/
  diffusion_models: models/diffusion_models/
```

## Ressources complémentaires

- [Documentation officielle ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [Tutoriels ComfyUI](https://comfyanonymous.github.io/ComfyUI_examples/)
- [Base de connaissances RunPod](https://docs.runpod.io/)

---

# ComfyUI on RunPod User Guide

This guide explains how to configure and use your ComfyUI container on RunPod.

## Hugging Face Configuration

To automatically download models from Hugging Face, you need an access token:

1. Create an account on [Hugging Face](https://huggingface.co/) if you don't already have one.
2. Log in to your Hugging Face account.
3. Access your profile settings (click on your avatar in the top right corner).
4. Go to the "Access Tokens" section.
5. Click on "New Token" and give it a name (e.g., "RunPod").
6. Select the "Read" access level (sufficient for downloading models).
7. Copy the generated token to use it in RunPod.

## Creating a RunPod Template

1. Log in to [RunPod](https://www.runpod.io/).
2. In your dashboard, click on "Templates" then "New Template".
3. Fill in the following information:
   - **Template Name**: ComfyUI CUDA 12.8
   - **Container Image**: your-username/runpod_comfyui:latest
   - **Container Start Command**: `/start.sh`
   - **Volume Mount Path**: `/workspace`
   - **Expose HTTP Ports**: `8188,8888,3000`
   - **Expose TCP Ports**: `22`
4. Click on "Create Template".

## Deploying a Pod

1. In your RunPod dashboard, click on "Deploy" next to your template.
2. Select the desired GPU type.
3. In the "Environment Variables" section, add:
   - **Name**: `HF_TOKEN`
   - **Value**: Paste the Hugging Face token you copied earlier
   - Make sure to check the "Secure" option to protect your token
4. If you want to enable JupyterLab, also add:
   - **Name**: `JUPYTER_PASSWORD`
   - **Value**: A password of your choice
5. Click on "Deploy" to launch your pod.

## Using the Pod

Once your pod is deployed and initialized (may take several minutes for model downloads), you can access the following services:

### ComfyUI

- URL: http://your-pod-ip:3000
- This is the main ComfyUI interface where you can create your image generation workflows.

### JupyterLab (if enabled)

- URL: http://your-pod-ip:8888
- Use the password defined in the `JUPYTER_PASSWORD` environment variable.
- Useful for exploring files, writing Python scripts, or Jupyter notebooks.

### SSH

- Host: your-pod-ip
- Port: 22
- Username: root
- Authentication: SSH key (configurable via the `PUBLIC_KEY` variable) or password "runpod"

## Directory Structure

In your pod, you'll find the following organization:

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

## Data Persistence

To preserve your models and outputs between pod restarts:

1. Go to the "Volumes" section of RunPod and create a new volume.
2. When deploying your pod, associate this volume with the path `/workspace`.

## Adding Custom Models

You can add your own models in several ways:

1. **Via JupyterLab**: Upload your files to the corresponding directories.
2. **Via SSH**: Use `scp` or `rsync` to transfer your models.
3. **Via ComfyUI Manager**: Use the ComfyUI Manager interface to download models directly.

For example, to add a new checkpoint via SSH:
```bash
scp your-checkpoint.safetensors root@your-pod-ip:/workspace/ComfyUI/models/checkpoints/
```

## Pre-installed Extensions

This container includes several pre-installed extensions:

- **ComfyUI-Manager**: Extension and model management interface
- **SDXL Prompt Styler**: Prompt styling for SDXL
- **ComfyUI TensorRT**: TensorRT optimization for better performance

You can install other extensions via ComfyUI Manager or manually by cloning them into the `/workspace/ComfyUI/custom_nodes/` directory.

## Troubleshooting

### Models Not Downloading

- Check that the `HF_TOKEN` variable is correctly defined.
- Check the pod logs to see download errors: `cat /var/log/comfyui.log`
- Try to download models manually via SSH.

### ComfyUI Interface Errors

- Verify that ComfyUI is running: `ps aux | grep ComfyUI`
- Check ComfyUI logs: `tail -f /var/log/comfyui.log`
- Restart the service:
  ```bash
  cd /workspace/ComfyUI
  pkill -f "python.*main.py"
  python main.py --listen --port 3000 --extra-model-paths-config /workspace/ComfyUI/extra_model_paths.yml &
  ```

### Working Directory Issues

- By default, the web terminal opens in `/workspace/ComfyUI`
- If you land in another directory, run `cd /workspace/ComfyUI`

### GPU Memory Issues

- Use workflows optimized for your specific GPU.
- Adjust generated image sizes based on available VRAM.
- On SDXL models, use the ComfyUI_TensorRT extension to optimize memory.
- Use the VAE-TAESD node for low-precision encoding/decoding to save VRAM.

### extra_model_paths.yml Configuration

The `/workspace/ComfyUI/extra_model_paths.yml` configuration file allows ComfyUI to find models in the corresponding subdirectories. If you encounter issues with model paths, check this file:

```bash
cat /workspace/ComfyUI/extra_model_paths.yml
```

The configuration should look like this:

```yaml
runpod_ComfyUI:
  base_path: /workspace/ComfyUI
  checkpoints: models/checkpoints/
  clip: models/clip/
  clip_vision: models/clip_vision/
  configs: models/configs/
  controlnet: models/controlnet/
  embeddings: models/embeddings/
  loras: models/loras/
  upscale_models: models/upscale_models/
  vae: models/vae/
  unet: models/unet/
  text_encoders: models/text_encoders/
  diffusion_models: models/diffusion_models/
```

## Additional Resources

- [Official ComfyUI Documentation](https://github.com/comfyanonymous/ComfyUI)
- [ComfyUI Tutorials](https://comfyanonymous.github.io/ComfyUI_examples/)
- [RunPod Knowledge Base](https://docs.runpod.io/)