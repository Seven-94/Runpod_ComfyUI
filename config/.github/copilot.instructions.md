# INSTRUCTIONS A SUIVRE POUR CE PROJET

## Environnement de travail
Je suis sur un mac m1 max avec 32go de ram.

## But
 Mon but est de **creer un conteneur docker Comfyui pour l'utiliser sur Runpod.io (linux) avec les contraintes suivantes** :

- Une image de base nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04
- L'installation de pytorch 2.7.0 avec la commande suivante `pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128`
- L'installation de ComfyUi et des modules ComfyUI supplementaires suivants
    1. https://github.com/ltdrdata/ComfyUI-Manager.git
    2. https://github.com/twri/sdxl_prompt_styler
    3. https://github.com/comfyanonymous/ComfyUI_TensorRT
- Prévoir les fichiers de configurations necessaires à Runpod à Savoir :
    1. un fichier nginx.conf
    2. un fichier pre_start.sh
    3. un fichier start.sh

## Téléchargement optionnel des modeles 
Si cela ne complique pas inutilement le conteneur, telecharger les modeles suivants directement dans leur emplacement dans le `Volume Network` pour ne pas avoir à les telecharger à nouveau à chaque demarrage du pod.

1. `https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors?download=true` dans le repertoire `ComfyUI/models/text_encoders/t5xxl_fp16.safetensors`

2. `https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true`dans le repertoire `ComfyUI/models/text_encoders/clip_l.safetensors`

3. `https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors?download=true` dans le repertoire `ComfyUI/models/vae/ae.safetensors`
4. `https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors` dans le repertoire `ComfyUI/models/diffusion_models/flux1-dev.safetensors`


## Autres considerations importantes
L'utilisateur sur Runpod **doit utiliser imperativement un `Volume Network` pour pourvoir stocker les modeles telechargés** et conserver ses parametres utilisateurs et la configuration de ComfyUI et de ses modules. 

L'utilisateur doit c**onfigurer 2 variables d'environnement** dans son template, `HF_TOKEN` qui contiendra son token huggingface pour le telechargement des modeles et `JUPYTER_PASSWORD` qui contiendra son mot de passe ou token pour la connexion à jupyter sur Runpod.

### REAMDE et Documentations
Créé des fichiers de documentation et et README comme si le projet allait etre envoyé sur Github. Assurre toi d'avoir une version Française et une version Anglaise de chaques fichiers pour la bonne comprehension à l'international du projet.

## Objectif Principal
L'objectif principal est d'avoir un conteneur docker avec ComfyUi, ComfyUI-Manager, sdxl_prompt_styler et ComfyUI_TensorRT **fonctionnel sur Runpod** en sachant que je construit ce conteneur docker sur un mac pour un environnement linux. 

**Si tu ne comprends pas quelque chose ou si tu veux des précisions tu me poses des questions** 