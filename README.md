# ComfyUI pour RunPod - Optimisé GPU Blackwell v0.1.0

Ce dépôt contient un conteneur Docker optimisé pour exécuter ComfyUI v0.3.51 sur la plateforme RunPod, spécialement configuré pour les GPU NVIDIA Blackwell (B200, B100) et autres GPU de dernière génération.

## 🚀 Fonctionnalités

- **ComfyUI v0.3.51** - La dernière version stable de ComfyUI
- **Optimisations GPU Blackwell** - Support natif pour les architectures de calcul 9.0 et supérieures
- **Base PyTorch 2.8.0 + CUDA 12.9** - Performance maximale avec les derniers drivers
- **Extensions pré-installées** :
  - ComfyUI-Manager
  - ComfyUI-Crystools  
  - ComfyUI-KJNodes
- **Optimisations avancées** :
  - Flash Attention 2
  - xFormers
  - Triton
  - torch.compile
  - Allocation mémoire optimisée
- **Conteneur propre** - Aucun modèle pré-téléchargé, démarrage rapide
- **Interface web avec Nginx** - Configuration optimisée pour l'accès à distance
- **Support JupyterLab** - Pour le développement et l'exploration
- **Persistance des données** - Configuration conservée dans un volume network

## 🏗️ Architecture supportée

- **GPU Blackwell** : B200, B100 (Compute 9.0)
- **GPU Hopper** : H200, H100 (Compute 9.0)  
- **GPU Ada Lovelace** : RTX 4090, 4080, 4070 (Compute 8.9)
- **GPU Ampere** : RTX 3090, 3080, A100 (Compute 8.6+)

## 🚀 Démarrage rapide

### Prérequis
- Docker installé sur votre machine  
- Un compte RunPod avec des crédits ou un GPU disponible

### 1. Clonez ce dépôt
```bash
git clone https://github.com/Seven-94/Runpod_ComfyUI.git
cd Runpod_ComfyUI
```

### 2. Construisez l'image Docker
```bash
docker build -t runpod_comfyui:v0.1.0 .
```

**Pour build multi-architecture (recommandé pour publication) :**
```bash
docker buildx build --platform=linux/amd64 -t runpod_comfyui:v0.1.0 .
```

**Pour publier sur Docker Hub :**
```bash
docker tag runpod_comfyui:v0.1.0 votre-username/runpod_comfyui:v0.1.0
docker push votre-username/runpod_comfyui:v0.1.0
```

### 3. Déployez sur RunPod
- Créez un template avec votre image Docker
- Configurez la commande de démarrage : `/start.sh`
- Exposez les ports HTTP : `3000,8188,8888,22`
## 🔧 Configuration RunPod

### Variables d'environnement optionnelles
- `JUPYTER_PASSWORD` : Active JupyterLab avec le mot de passe spécifié
- `PUBLIC_KEY` : Clé SSH publique pour l'accès sécurisé

### Ports exposés
- `3000` : Interface ComfyUI (nginx proxy)
- `8188` : ComfyUI service direct
- `8888` : JupyterLab (si activé)
- `22` : SSH

## � Structure des répertoires

```
/workspace/ComfyUI/              # Répertoire principal de ComfyUI  
├── custom_nodes/                # Extensions préinstallées
│   ├── ComfyUI-Manager/         # Gestionnaire d'extensions
│   ├── ComfyUI-Crystools/       # Outils utilitaires avancés
│   └── ComfyUI-KJNodes/         # Nœuds étendus de Kijai
├── input/                       # Fichiers d'entrée
├── models/                      # Modèles (vide au démarrage)
│   ├── checkpoints/             # Modèles de base
│   ├── text_encoders/           # Encodeurs de texte
│   ├── diffusion_models/        # Modèles de diffusion
│   ├── vae/                     # Variational Auto-Encoders
│   └── ...                      # Autres types de modèles
├── output/                      # Images/vidéos générées
└── extra_model_paths.yml        # Configuration des chemins
```

## 🎯 Optimisations GPU Blackwell

Cette image intègre de nombreuses optimisations pour les GPU de dernière génération :

### Optimisations mémoire
- `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`
- `CUDA_MODULE_LOADING=LAZY`
- `CUBLAS_WORKSPACE_CONFIG=:4096:8`

### Optimisations de calcul
- Flash Attention 2 pour l'attention optimisée
- xFormers pour les transformers efficaces
- Triton pour les kernels CUDA optimisés
- torch.compile pour la compilation JIT
- Arguments ComfyUI optimisés : `--force-fp16`, `--use-split-cross-attention`

### Vérification des optimisations
```bash
# Dans le conteneur, vérifiez que tout est correctement configuré
python /opt/scripts/check_blackwell_optimizations.py
```

## 📱 Accès aux services

- **ComfyUI** : `http://votre-pod-ip:3000`
- **JupyterLab** : `http://votre-pod-ip:8888` (si activé)
- **SSH** : `ssh root@votre-pod-ip` (mot de passe : runpod)

## 📦 Installation des modèles

Ce conteneur ne contient aucun modèle pré-téléchargé pour rester léger et rapide au démarrage.
Pour installer des modèles :

1. **Via ComfyUI-Manager** (recommandé)
   - Accédez à ComfyUI sur le port 3000
   - Utilisez le Manager pour installer les modèles souhaités

2. **Manuellement** 
   - Placez vos modèles dans `/workspace/ComfyUI/models/`
   - Suivez la structure des répertoires standard de ComfyUI

## 🚀 Fonctionnalités v0.1.0

- ✅ ComfyUI v0.3.51 (dernière version)
- ✅ Support GPU Blackwell optimisé  
- ✅ Extensions modernes préinstallées
- ✅ Conteneur propre sans modèles
- ✅ Optimisations mémoire et calcul avancées
- ✅ Architecture supportée jusqu'à Compute 9.0
- ✅ Flash Attention 2 + xFormers + Triton

## 📚 Documentation

Pour des instructions détaillées, consultez le [Guide d'utilisation](docs/GUIDE.md).

### 📋 Fichiers de référence

- **`AUTO-BUILD.md`** - Documentation du système de build automatique GitHub Actions
- **`Dockerfile.multistage`** - Version multi-stage du Dockerfile (expérimentale, non utilisée en production)
- **`build.sh`** - Script de build local pour développement
- **`test-version-check.sh`** - Script de test pour vérification des versions

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

**Optimisé pour les GPU Blackwell | ComfyUI v0.3.51 | Docker | RunPod**