# ComfyUI sur RunPod

## Téléchargement des modèles

Cette image nécessite le téléchargement de certains modèles depuis Hugging Face au premier démarrage.

Pour télécharger les modèles avec authentification (recommandé) :
1. Créez un compte sur [Hugging Face](https://huggingface.co/)
2. Créez un token d'accès dans les paramètres de votre compte
3. Lors du déploiement du pod sur RunPod, ajoutez une variable d'environnement :
   - Nom : `HF_TOKEN`
   - Valeur : votre token HuggingFace

Si vous ne fournissez pas de token, l'image tentera un téléchargement anonyme, mais celui-ci pourrait échouer selon les restrictions d'accès des modèles.

## Extensions intégrées

- ComfyUI-Manager
- sdxl_prompt_styler
- ComfyUI_TensorRT

## Modèles préchargés
Les modèles suivants seront automatiquement téléchargés au premier démarrage :

- t5xxl_fp16.safetensors (text encoder)
- clip_l.safetensors (text encoder)
- ae.safetensors (VAE)
- flux1-dev.safetensors (diffusion model)

---

# ComfyUI on RunPod

## Model Download

This image requires downloading certain models from Hugging Face on first startup.

To download models with authentication (recommended):
1. Create an account on [Hugging Face](https://huggingface.co/)
2. Create an access token in your account settings
3. When deploying the pod on RunPod, add an environment variable:
   - Name: `HF_TOKEN`
   - Value: your HuggingFace token

If you don't provide a token, the image will attempt an anonymous download, but this may fail depending on the access restrictions of the models.

## Included Extensions

- ComfyUI-Manager
- sdxl_prompt_styler
- ComfyUI_TensorRT

## Pre-loaded Models
The following models will be automatically downloaded on first startup:

- t5xxl_fp16.safetensors (text encoder)
- clip_l.safetensors (text encoder)
- ae.safetensors (VAE)
- flux1-dev.safetensors (diffusion model)