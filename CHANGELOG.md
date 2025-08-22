# Changelog - Runpod ComfyUI

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

## [2.1.0] - 2025-08-22

### ✨ Ajouté
- **FLUX.1-Kontext-dev** - Nouveau modèle d'édition d'images contextuelle (23.8GB)
  - Édition d'images basée sur des instructions textuelles
  - Maintien de la cohérence des personnages et du style
  - Support des références d'objets sans fine-tuning
- **Modèles Wan 2.2** - Suite complète de génération vidéo
  - **Wan 2.2 T2V A14B** - Text-to-Video avec architecture MoE (2×14B paramètres)
  - **Wan 2.2 I2V A14B** - Image-to-Video avec architecture MoE
  - Support résolutions 480P et 720P jusqu'à 5 secondes
  - VAE haute compression (16×16×4) pour génération efficace
- **Modèles Qwen Image** - Génération et édition multilingue
  - **Qwen-Image** - Génération d'images Text-to-Image (chinois/anglais)
  - **Qwen-Image-Edit** - Édition d'images avec support de texte précis
  - Spécialisé dans le rendu de texte et l'édition bilingue

### 🔧 Amélioré
- **Structure des répertoires de modèles** étendue
  - Ajout des dossiers `text_to_video/`, `image_to_video/`, `style_models/`
  - Meilleure organisation des différents types de modèles
- **Script de téléchargement** (`download_models.sh`) mis à jour
  - Support des nouveaux modèles avec URLs correctes
  - Messages d'information pour les téléchargements volumineux
  - Vérification améliorée des tailles de fichiers
- **Configuration des chemins** (`extra_model_paths.yml`)
  - Nouveaux chemins pour tous les types de modèles
  - Configuration optimisée pour ComfyUI

### 📁 Nouveaux Fichiers
- `docs/NOUVEAUX_MODELES.md` - Documentation complète des nouveaux modèles
- `scripts/check_models.sh` - Script de vérification des modèles installés
- `scripts/cleanup_models.sh` - Script de nettoyage pour libérer l'espace disque
- `CHANGELOG.md` - Ce fichier de changelog

### 📚 Documentation
- **README.md** mis à jour avec les nouveaux modèles
- Documentation détaillée des fonctionnalités de chaque modèle
- Guide d'utilisation des nouveaux scripts utilitaires
- Informations sur les exigences matérielles et optimisations

### 🛠️ Scripts Utilitaires
- **check_models.sh** - Vérification automatisée des modèles
  - Contrôle de la présence et taille des fichiers
  - Affichage coloré du statut de chaque modèle
  - Calcul de l'espace disque utilisé
- **cleanup_models.sh** - Gestion de l'espace disque
  - Options de nettoyage sélectif par catégorie
  - Confirmation avant suppression
  - Analyse de l'utilisation de l'espace

### 🐳 Docker
- **Dockerfile** mis à jour pour inclure les nouveaux scripts
- Copie automatique des scripts utilitaires dans `/opt/scripts/`
- Permissions d'exécution automatiques pour tous les scripts

## [2.0.0] - 2025-07-15

### ✨ Ajouté
- Support CUDA 12.8 pour GPUs de dernière génération
- Image de base NGC PyTorch 25.02
- Modèles FLUX.1 complets (dev, Fill, Depth, Canny, Redux)
- Support architecture GPU étendu (8.6, 9.0, 12.0, 12.6)
- ComfyUI-Manager et extensions pré-installées
- Configuration Nginx optimisée
- Support JupyterLab intégré

### 🔧 Modifié
- Migration vers l'image NGC pour meilleures performances
- Optimisations TensorRT intégrées
- xFormers pré-compilé pour réduction VRAM

### 📚 Documentation
- Guide d'installation complet
- Documentation des optimisations RTX 5090
- Instructions de déploiement RunPod

## [1.0.0] - 2025-06-01

### ✨ Première version
- Image Docker de base pour ComfyUI
- Support CUDA basique
- Téléchargement automatique des modèles FLUX.1-dev
- Configuration de base pour RunPod

---

## Types de changements
- `✨ Ajouté` pour les nouvelles fonctionnalités
- `🔧 Modifié` pour les changements dans les fonctionnalités existantes  
- `🐛 Corrigé` pour les corrections de bugs
- `🗑️ Supprimé` pour les fonctionnalités supprimées
- `🔒 Sécurité` pour les corrections de vulnérabilités
- `📚 Documentation` pour les changements de documentation uniquement
- `🐳 Docker` pour les changements liés au conteneur Docker
