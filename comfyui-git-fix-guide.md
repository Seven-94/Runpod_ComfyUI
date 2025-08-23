# 🔧 Correction du problème de mise à jour ComfyUI

## 🚨 Problème identifié
```
[ComfyUI-Manager] Failed to checkout 'master' branch.
repo_path=/workspace/ComfyUI
Available branches:
ComfyUI update failed
```

## 🔍 Cause du problème
Le repository ComfyUI est cloné avec `--depth 1 --branch v0.3.51`, ce qui crée un repository Git "shallow" sans la branche `master`. ComfyUI-Manager ne peut donc pas effectuer de checkout sur `master` pour les mises à jour.

## ✅ Solutions implémentées

### 1. **Correction automatique** (pour nouvelles installations)
Le script `pre_start.sh` a été modifié pour :
- Réinitialiser le repository Git avec l'historique complet
- Configurer la branche `master` correctement
- Permettre les mises à jour via ComfyUI-Manager

### 2. **Script de correction manuelle** (pour installations existantes)
Le script `fix-comfyui-git.sh` permet de corriger le problème sur une installation existante.

## 🚀 Utilisation

### Pour une installation existante sur RunPod :

1. **Se connecter en SSH au pod RunPod**

2. **Télécharger et exécuter le script de correction :**
```bash
cd /workspace
wget https://raw.githubusercontent.com/Seven-94/Runpod_ComfyUI/main/fix-comfyui-git.sh
chmod +x fix-comfyui-git.sh
./fix-comfyui-git.sh
```

3. **Redémarrer ComfyUI :**
```bash
# Arrêter ComfyUI
pkill -f "python.*main.py"

# Redémarrer ComfyUI
cd /workspace/ComfyUI
python main.py --listen --port 8188 --extra-model-paths-config extra_model_paths.yml --force-fp16 --use-split-cross-attention --enable-cors-header &
```

4. **Rafraîchir le navigateur et tester la mise à jour**

### Pour nouvelles installations :
Le problème sera automatiquement corrigé lors du prochain déploiement avec la nouvelle image Docker.

## ✅ Validation du succès
Après correction, vous devriez pouvoir :
- ✅ Accéder aux paramètres de mise à jour de ComfyUI-Manager
- ✅ Voir la branche `master` disponible
- ✅ Effectuer des mises à jour de ComfyUI sans erreur

## 📋 Vérification manuelle
```bash
cd /workspace/ComfyUI
git branch -a                    # Doit montrer origin/master
git remote get-url origin        # Doit montrer https://github.com/comfyanonymous/ComfyUI.git
git status                       # Doit fonctionner sans erreur
```
