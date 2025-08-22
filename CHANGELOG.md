# Changelog

Toutes les modifications importantes de ce projet seront documentées dans ce fichier.

## [0.1.0] - 2025-08-23

### 🚀 Version initiale
- **ComfyUI v0.3.51** - Dernière version stable de ComfyUI
- **Optimisations GPU Blackwell** - Support natif pour les GPU B200/B100
- **Base PyTorch 2.8.0 + CUDA 12.9** - Performance maximale avec les derniers drivers
- **Conteneur propre** - Aucun modèle pré-téléchargé pour un démarrage rapide

### ⚡ Optimisations techniques
- **PyTorch 2.8.0 + CUDA 12.9** - Base optimisée pour Blackwell
- **Flash Attention 2** - Attention optimisée pour performance accrue
- **xFormers** - Transformers efficaces pour réduction VRAM
- **Triton** - Kernels CUDA optimisés
- **torch.compile** - Compilation JIT pour accélération
- **Architecture CUDA étendue** - Support jusqu'à Compute 9.0 (Blackwell)

### 🔧 Extensions incluses
- ✅ **ComfyUI-Manager** - Gestionnaire d'extensions
- ✅ **ComfyUI-Crystools** - Outils utilitaires avancés  
- ✅ **ComfyUI-KJNodes** - Nœuds étendus de Kijai

### 🗂️ Architecture
- **Scripts de configuration** :
  - `start.sh` - Script principal de démarrage
  - `pre_start.sh` - Initialisation de ComfyUI
  - `check_blackwell_optimizations.py` - Vérification des optimisations GPU
- **Configuration nginx** optimisée pour ComfyUI

### 💾 Caractéristiques
- **Taille d'image optimisée** - Pas de modèles pré-téléchargés
- **Démarrage rapide** - Installation à la volée des extensions
- **Support multi-GPU** - Optimisations pour clusters GPU
- **Compatibilité RunPod** - Configuration spécialisée pour l'infrastructure RunPod

### 📋 Note de version
Cette version 0.1.0 représente une refonte complète du conteneur ComfyUI pour RunPod, optimisée pour les GPU Blackwell et une expérience utilisateur améliorée. Les prochaines versions suivront le versioning sémantique standard.

### 🐛 Améliorations
- Permissions optimisées sur les fichiers de script
- Gestion améliorée des volumes réseau
- Démarrage optimisé de nginx et SSH

---
