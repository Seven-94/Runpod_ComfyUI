# INSTRUCTIONS A SUIVRE POUR CE PROJET

## Environnement de travail
Je suis sur un mac m1 max avec 32go de ram.

## But
 Mon but est de **creer un conteneur docker Comfyui pour l'utiliser sur Runpod.io (linux) avec les contraintes suivantes** :

- Une image de base pytorch/pytorch:2.8.0-cuda12.9-cudnn9-devel
- L'installation de ComfyUi et des modules ComfyUI supplementaires suivants
    1. https://github.com/ltdrdata/ComfyUI-Manager.git
    2. https://github.com/twri/sdxl_prompt_styler
    3. https://github.com/comfyanonymous/ComfyUI_TensorRT
    4. https://github.com/crystian/ComfyUI-Crystools
    5. https://github.com/kijai/ComfyUI-KJNodes
- Prévoir les fichiers de configurations necessaires à Runpod à Savoir :
    1. un fichier nginx.conf
    2. un fichier pre_start.sh
    3. un fichier start.sh


## Autres considerations importantes
L'utilisateur sur Runpod **doit utiliser imperativement un `Volume Network` pour pourvoir stocker les modeles telechargés** et conserver ses parametres utilisateurs et la configuration de ComfyUI et de ses modules. 

L'utilisateur doit **configurer 2 variables d'environnement** dans son template, `HF_TOKEN` qui contiendra son token huggingface pour le telechargement des modeles et `JUPYTER_PASSWORD` qui contiendra son mot de passe ou token pour la connexion à jupyter sur Runpod.

### REAMDE et Documentations
Créé des fichiers de documentation et et README comme si le projet allait etre envoyé sur Github. Assurre toi d'avoir une version Française et une version Anglaise de chaques fichiers pour la bonne comprehension à l'international du projet.

## Objectif Principal
L'objectif principal est d'avoir un conteneur docker avec ComfyUi, ComfyUI-Manager, sdxl_prompt_styler, KJNodes, Crystools et ComfyUI_TensorRT **fonctionnel sur Runpod** en sachant que je construit ce conteneur docker sur un mac pour un environnement linux. 

**Si tu ne comprends pas quelque chose ou si tu veux des précisions tu me poses des questions** 