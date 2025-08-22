# Nouveaux Modèles Ajoutés - Mise à Jour 2025

Cette mise à jour ajoute plusieurs nouveaux modèles de pointe pour ComfyUI, notamment pour l'édition d'images, la génération vidéo et la génération d'images multilingue.

## 🖼️ FLUX.1-Kontext-dev

**Type:** Modèle d'édition d'images basé sur du contexte  
**Taille:** ~23.8 GB  
**Utilisation:** Édition d'images avec cohérence de personnage et de style

### Fonctionnalités
- Édition d'images basée sur des instructions textuelles
- Maintien de la cohérence des personnages et du style
- Édition itérative avec dérive visuelle minimale
- Support des références d'objets, de style et de caractères sans fine-tuning

### Fichiers téléchargés
- `flux1-kontext-dev.safetensors` - Modèle principal
- `flux_kontext_ae.safetensors` - VAE spécifique

---

## 📹 Modèles Wan 2.2

### Wan 2.2 T2V A14B (Text-to-Video)
**Type:** Génération de vidéo à partir de texte  
**Architecture:** Mixture-of-Experts (MoE) avec 2 experts de 14B paramètres chacun  
**Résolutions supportées:** 480P et 720P  
**Durée:** Jusqu'à 5 secondes

### Wan 2.2 I2V A14B (Image-to-Video)
**Type:** Génération de vidéo à partir d'image  
**Architecture:** Mixture-of-Experts (MoE)  
**Résolutions supportées:** 480P et 720P  
**Durée:** Jusqu'à 5 secondes

### Avantages de Wan 2.2
- Architecture MoE efficace : 27B paramètres totaux, 14B actifs par étape
- Expert haute-noise pour les étapes précoces (mise en page globale)
- Expert basse-noise pour les étapes tardives (raffinement des détails)
- Esthétique cinématographique avec données curées
- Génération de mouvements complexes

### Fichiers téléchargés
- `wan2.2_t2v_a14b_dit.safetensors` - Modèle T2V principal
- `wan2.2_t2v_vae.safetensors` - VAE T2V
- `wan2.2_i2v_a14b_dit.safetensors` - Modèle I2V principal  
- `wan2.2_i2v_vae.safetensors` - VAE I2V

---

## 🌏 Modèles Qwen Image

### Qwen-Image
**Type:** Génération d'images à partir de texte  
**Langues:** Chinois et Anglais  
**Spécialité:** Rendu de texte précis

### Qwen-Image-Edit  
**Type:** Édition d'images multilingue  
**Langues:** Chinois et Anglais  
**Spécialité:** Édition de texte précise dans les images

### Fonctionnalités Qwen
- **Édition sémantique:** Modification du contenu tout en préservant la sémantique
- **Édition d'apparence:** Ajout/suppression d'éléments spécifiques
- **Édition de texte précise:** Support bilingue (chinois/anglais)
- **Synthèse de nouvelles vues:** Rotation d'objets jusqu'à 180°
- **Transfert de style:** Transformation en différents styles artistiques

### Fichiers téléchargés
- `qwen_image_dit.safetensors` - Modèle Qwen-Image principal
- `qwen_image_vae.safetensors` - VAE Qwen-Image
- `qwen_image_edit_dit.safetensors` - Modèle Qwen-Image-Edit
- `qwen_image_edit_vae.safetensors` - VAE Qwen-Image-Edit
- `qwen_text_encoder.safetensors` - Encodeur de texte Qwen

---

## 📁 Organisation des Modèles

Les nouveaux modèles sont organisés dans les répertoires suivants :

```
/workspace/ComfyUI/models/
├── diffusion_models/
│   ├── flux1-kontext-dev.safetensors
│   ├── qwen_image_dit.safetensors
│   └── qwen_image_edit_dit.safetensors
├── text_to_video/
│   └── wan2.2_t2v_a14b_dit.safetensors
├── image_to_video/
│   └── wan2.2_i2v_a14b_dit.safetensors
├── vae/
│   ├── flux_kontext_ae.safetensors
│   ├── wan2.2_t2v_vae.safetensors
│   ├── wan2.2_i2v_vae.safetensors
│   ├── qwen_image_vae.safetensors
│   └── qwen_image_edit_vae.safetensors
└── text_encoders/
    └── qwen_text_encoder.safetensors
```

---

## 🔧 Configuration Requise

### Mémoire GPU Recommandée
- **FLUX.1-Kontext-dev:** 24+ GB VRAM (modèle 23.8GB)
- **Wan 2.2 A14B:** 80+ GB VRAM (ou multi-GPU avec FSDP)
- **Qwen Models:** 24+ GB VRAM

### Optimisations
- Utilisation d'offloading pour réduire l'utilisation VRAM
- Support multi-GPU avec FSDP et DeepSpeed Ulysses pour Wan 2.2
- Quantification disponible pour certains modèles

---

## 🚀 Utilisation dans ComfyUI

Ces modèles seront automatiquement détectés par ComfyUI Manager et pourront être utilisés via les nœuds appropriés :

1. **FLUX.1-Kontext-dev** - Nœuds d'édition d'images FLUX
2. **Wan 2.2** - Nœuds de génération vidéo (T2V/I2V)  
3. **Qwen Models** - Nœuds de génération/édition d'images multilingues

---

## 📚 Ressources Supplémentaires

- [FLUX.1-Kontext-dev Documentation](https://huggingface.co/black-forest-labs/FLUX.1-Kontext-dev)
- [Wan 2.2 GitHub](https://github.com/Wan-Video/Wan2.2)
- [Qwen-Image Documentation](https://huggingface.co/Qwen/Qwen-Image)
- [Qwen-Image-Edit Documentation](https://huggingface.co/Qwen/Qwen-Image-Edit)

---

## ⚠️ Notes Importantes

1. **Licences:** Vérifiez les licences de chaque modèle avant utilisation commerciale
2. **Taille:** Ces modèles sont volumineux - assurez-vous d'avoir suffisamment d'espace de stockage
3. **Performance:** Les modèles Wan 2.2 nécessitent des ressources GPU importantes
4. **Authentification:** Certains modèles peuvent nécessiter un token HuggingFace pour le téléchargement

---

**Date de mise à jour:** 22 août 2025  
**Version ComfyUI recommandée:** Latest avec support pour les nouveaux nœuds
