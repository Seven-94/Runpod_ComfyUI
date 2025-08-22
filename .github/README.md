# GitHub Actions - Build Automatique

Ce répertoire contient un workflow GitHub Actions qui build automatiquement une nouvelle image Docker lorsqu'une nouvelle version de ComfyUI est disponible.

## 🕕 Planification

Le workflow s'exécute **chaque jour à 6h du matin (heure de Paris)** :
- 🇫🇷 **6h00 Paris** (heure d'été : UTC+2)
- 🌍 **4h00 UTC** (configuré dans le cron)

> **Note :** Pendant l'heure d'hiver (UTC+1), le build s'exécutera à 5h du matin heure française.

## 🔄 Logique de Build

### 1. Vérification automatique
Le workflow vérifie automatiquement :
- ✅ La dernière version de ComfyUI sur GitHub
- ✅ Si une image Docker existe déjà pour cette version
- ✅ Si un build est nécessaire

### 2. Build conditionnel
L'image est buildée **uniquement si** :
- 🆕 Une nouvelle version de ComfyUI est disponible
- 🚫 Aucune image n'existe pour cette version
- 🔧 Build forcé manuellement

### 3. Tagging intelligent
Chaque image est tagguée avec :
```
{VERSION_CONTENEUR}-comfyui-{VERSION_COMFYUI}
```
Exemple : `0.1.0-comfyui-v0.3.51`

## 📋 Workflow : `auto-build-comfyui.yml`

### Jobs

1. **`check-version`** - Vérifie les versions
   - Récupère la dernière version ComfyUI via GitHub API
   - Compare avec les images existantes
   - Détermine si un build est nécessaire

2. **`build-and-push`** - Build et publication (conditionnel)
   - Met à jour le Dockerfile avec la nouvelle version
   - Build l'image Docker avec optimisations Blackwell
   - Publie sur Docker Hub avec plusieurs tags
   - Utilise le cache GitHub Actions pour optimiser

3. **`notify-completion`** - Notification de fin
   - Affiche le résultat du build
   - Fournit les informations de l'image créée

## 🚀 Exécution manuelle

Vous pouvez déclencher le workflow manuellement :

1. Allez dans l'onglet **Actions** de votre repo GitHub
2. Sélectionnez **ComfyUI Auto Build**
3. Cliquez sur **Run workflow**
4. Optionnel : Cochez "Forcer le build" pour ignorer les vérifications

## 🔧 Configuration requise

### Secrets GitHub nécessaires :

```bash
DOCKERHUB_USERNAME  # Votre nom d'utilisateur Docker Hub
DOCKERHUB_TOKEN     # Token d'accès Docker Hub
GITHUB_TOKEN        # Token GitHub (automatique)
```

### Permissions requises :
- ✅ Lecture du repository
- ✅ Actions workflow
- ✅ Packages/Registry (pour Docker Hub)
- ✅ Contents write (pour les releases)

## 📊 Sortie du Workflow

### En cas de nouvelle version :
```
✅ Build réussi pour ComfyUI v0.3.52
🐳 Image disponible: username/runpod-comfyui:0.1.0-comfyui-v0.3.52
```

### En cas de version à jour :
```
ℹ️ Aucun build nécessaire - ComfyUI v0.3.51 déjà à jour
```

## 🏷️ Tags créés automatiquement

Pour chaque build réussi :
- `latest` - Dernière version
- `0.1.0-comfyui-v0.3.51` - Tag versionnement complet
- `v2025.08.22` - Tag avec date du build

## 📈 Optimisations

- **Cache GitHub Actions** : Réutilise les layers Docker entre builds
- **Build conditionnel** : Évite les builds inutiles
- **Vérification API** : Utilise l'API Docker Hub pour vérifier l'existence des images
- **Multi-platform** : Support linux/amd64 (compatible RunPod)

## 🐛 Debugging

### Vérifier la logique de version localement :
```bash
./test-version-check.sh
```

### Logs utiles dans Actions :
- Vérification de version ComfyUI
- Existence de l'image sur Docker Hub
- Mise à jour du Dockerfile
- Résultat du build

## 📚 Documentation complémentaire

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build-Push Action](https://github.com/docker/build-push-action)
- [ComfyUI Releases](https://github.com/comfyanonymous/ComfyUI/releases)
