# Scripts de gestion Git pour ComfyUI

Ce répertoire contient des scripts pour résoudre les problèmes de mise à jour de ComfyUI via l'interface graphique.

## 📁 **Scripts disponibles**

### **Dans l'image Docker** (`/opt/scripts/`)

| Script | Description | Utilisation |
|--------|-------------|-------------|
| `fix-comfyui-git.sh` | Corrige la configuration Git de ComfyUI | `/opt/scripts/fix-comfyui-git.sh` |
| `diagnose-comfyui-git.sh` | Diagnostique les problèmes Git | `/opt/scripts/diagnose-comfyui-git.sh` |

### **Tests locaux uniquement**

| Script | Description | Utilisation |
|--------|-------------|-------------|
| `test-comfyui-git-setup.sh` | Test de validation de la configuration Git | `./test-comfyui-git-setup.sh` |

## 🚀 **Utilisation courante**

### Sur une instance RunPod en cours :

```bash
# 1. Diagnostiquer le problème
/opt/scripts/diagnose-comfyui-git.sh

# 2. Corriger automatiquement
cd /workspace
/opt/scripts/fix-comfyui-git.sh

# 3. Redémarrer ComfyUI
pkill -f "python.*main.py"
cd /workspace/ComfyUI
python main.py --listen --port 8188 --extra-model-paths-config extra_model_paths.yml --force-fp16 --use-split-cross-attention --enable-cors-header &
```

### Test local (développement) :

```bash
# Tester la procédure avant déploiement
./test-comfyui-git-setup.sh
```

## ❓ **Problème résolu**

Ces scripts résolvent l'erreur :
```
[ComfyUI-Manager] Failed to checkout 'master' branch.
fatal: 'origin/master' is not a commit and a branch 'master' cannot be created from it
```

Après correction, ComfyUI-Manager pourra effectuer les mises à jour via l'interface graphique sans erreur.
