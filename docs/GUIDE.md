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
   - **Container Image**: votre-username/comfyui-runpod:latest
   - **Container Start Command**: `/start.sh`
   - **Volume Mount Path**: `/workspace/comfyui`
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

Une fois votre pod déployé et initialisé (peut prendre jusqu'à 5 minutes pour le téléchargement des modèles), vous pouvez accéder aux services suivants :

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

- `/workspace/ComfyUI/` - Répertoire principal de ComfyUI
  - `/workspace/ComfyUI/models/` - Contient tous les modèles (téléchargés automatiquement)
  - `/workspace/ComfyUI/output/` - Images générées
  - `/workspace/ComfyUI/input/` - Images d'entrée pour vos workflows
  - `/workspace/ComfyUI/custom_nodes/` - Extensions installées

## Persistance des données

Pour conserver vos modèles et sorties entre les redémarrages de pod :

1. Allez dans la section "Volumes" de RunPod et créez un nouveau volume.
2. Lors du déploiement de votre pod, associez ce volume au chemin `/workspace/comfyui`.

## Dépannage

### Les modèles ne se téléchargent pas

- Vérifiez que la variable `HF_TOKEN` est correctement définie.
- Consultez les logs du pod pour voir les erreurs de téléchargement.
- Essayez de télécharger manuellement les modèles via SSH.

### Erreurs d'interface ComfyUI

- Vérifiez que ComfyUI est bien démarré : `ps aux | grep ComfyUI`
- Consultez les logs de ComfyUI : `tail -f /var/log/comfyui.log`
- Redémarrez le service : `cd /workspace/ComfyUI && python main.py --listen --port 3000 &`

### Problèmes de mémoire GPU

- Utilisez les workflows optimisés pour votre GPU spécifique.
- Ajustez les tailles des images générées en fonction de la VRAM disponible.
- Sur les modèles SDXL, utilisez l'extension ComfyUI_TensorRT pour optimiser la mémoire.