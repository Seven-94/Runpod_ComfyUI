#!/usr/bin/env python3
# Fichier: check_attention_modules.py
# Script pour vérifier la présence de modules d'attention dans un conteneur ComfyUI
# 
# Améliorations apportées:
# - Gestion d'erreurs spécifiques au lieu de except: génériques
# - Remplacement de pkg_resources déprécié par importlib.metadata
# - Fonction réutilisable pour vérifier les packages installés
# - Test de performance sécurisé avec gestion de la mémoire GPU
# - Détection flexible du chemin ComfyUI
# - Correction de la vérification des capacités GPU
# - Résumé final avec statut de tous les modules

import sys
import importlib
import subprocess
import os
from packaging import version

# Utiliser importlib.metadata au lieu de pkg_resources (déprécié)
try:
    from importlib import metadata as importlib_metadata
except ImportError:
    import importlib_metadata

print("============ Vérification des modules d'attention pour ComfyUI ============")
print(f"Python version: {sys.version}")

def get_module_version(module_name):
    """Obtenir la version d'un module de manière sécurisée."""
    try:
        module = importlib.import_module(module_name)
        if hasattr(module, '__version__'):
            return module.__version__
        else:
            # Essayer via importlib.metadata
            try:
                return importlib_metadata.version(module_name.replace('_', '-'))
            except importlib_metadata.PackageNotFoundError:
                return "version inconnue"
    except ImportError:
        return None

# Vérification de PyTorch
try:
    import torch
    print(f"PyTorch version: {torch.__version__}")
    print(f"CUDA disponible: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"CUDA version: {torch.version.cuda}")
        print(f"Nombre de GPUs: {torch.cuda.device_count()}")
        for i in range(torch.cuda.device_count()):
            print(f"GPU {i}: {torch.cuda.get_device_name(i)}")
except ImportError as e:
    print(f"❌ PyTorch n'est pas installé: {e}")
    sys.exit(1)

# Vérification de xformers
try:
    import xformers
    print(f"✅ xformers est installé (version: {xformers.__version__})")
    
    # Vérification des fonctionnalités spécifiques de xformers
    try:
        from xformers.ops import memory_efficient_attention
        print("✅ memory_efficient_attention est disponible")
    except ImportError as e:
        print(f"❌ memory_efficient_attention n'est pas disponible: {e}")
except ImportError as e:
    print(f"❌ xformers n'est pas installé: {e}")

def check_package_installed(package_name):
    """Vérifier si un package est installé via pip ou importable."""
    try:
        # Essayer d'importer le module
        importlib.import_module(package_name.replace('-', '_'))
        return True, "importable"
    except ImportError:
        pass
    
    # Vérifier via importlib.metadata
    try:
        importlib_metadata.distribution(package_name)
        return True, "pip"
    except importlib_metadata.PackageNotFoundError:
        pass
    
    # Dernière tentative avec pip show
    try:
        result = subprocess.run(["pip", "show", package_name], 
                              capture_output=True, text=True, check=True)
        return True, "pip show"
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False, None

# Vérification de FlashAttention
has_flash_attn = False
try:
    import flash_attn
    has_flash_attn = True
    print(f"✅ FlashAttention est installé (version: {flash_attn.__version__})")
except ImportError:
    is_installed, method = check_package_installed('flash-attn')
    if is_installed:
        print(f"✅ FlashAttention est installé (détecté via {method})")
        has_flash_attn = True
    else:
        print("❌ FlashAttention n'est pas installé")

if not has_flash_attn:
    # Vérifier si le module est dans les modules torch compilés 
    try:
        if hasattr(torch.nn.functional, 'scaled_dot_product_attention'):
            print("✅ PyTorch inclut scaled_dot_product_attention (peut utiliser FlashAttention si disponible)")
        else:
            print("❌ PyTorch n'inclut pas scaled_dot_product_attention")
    except Exception as e:
        print(f"❌ FlashAttention n'est pas détecté: {e}")

# Vérification de triton (souvent utilisé avec FlashAttention)
triton_version = get_module_version('triton')
if triton_version:
    print(f"✅ Triton est installé (version: {triton_version})")
else:
    print("❌ Triton n'est pas installé")

# Vérification de SageAttention (partie de SageMaker ou custom implementations)
is_installed, method = check_package_installed('sage-attention')
if is_installed:
    print(f"✅ SageAttention est installé (détecté via {method})")
else:
    print("❌ SageAttention n'est pas installé comme package indépendant")
    
    # Vérifions si des modules d'attention similaires sont disponibles dans PyTorch
    try:
        if hasattr(torch.nn.functional, 'scaled_dot_product_attention'):
            print("✅ PyTorch inclut scaled_dot_product_attention (alternative à SageAttention)")
        else:
            print("❌ Pas d'alternative native à SageAttention détectée")
    except Exception as e:
        print(f"❌ Impossible de vérifier les alternatives à SageAttention: {e}")

print("\n============ Vérification de l'utilisation dans ComfyUI ============")
# Vérifier si ComfyUI est configuré pour utiliser ces modules d'attention
comfyui_paths = ['/workspace/ComfyUI', './ComfyUI', '../ComfyUI']
comfyui_found = False

for path in comfyui_paths:
    if os.path.exists(path):
        sys.path.insert(0, path)
        comfyui_found = True
        print(f"✅ ComfyUI trouvé dans: {path}")
        break

if comfyui_found:
    try:
        from comfy import model_management
        print("✅ Module ComfyUI model_management trouvé")
        
        # Pour information: ComfyUI utilise automatiquement xformers s'il est disponible
        print("ℹ️ ComfyUI utilisera automatiquement xformers s'il est disponible")
        
        try:
            # Vérification des optimisations d'attention dans ComfyUI
            optimizations = []
            if hasattr(model_management, 'xformers_enabled'):
                if model_management.xformers_enabled():
                    optimizations.append("xformers")
            if hasattr(model_management, 'get_torch_device'):
                device = model_management.get_torch_device()
                if device.type == "cuda" and torch.cuda.is_available():
                    # Vérifier les capacités du GPU de manière sécurisée
                    try:
                        props = torch.cuda.get_device_properties(device)
                        if props.major >= 8:  # Ampere architecture ou plus récente
                            optimizations.append("sdp-flash-attention2")
                    except Exception as e:
                        print(f"⚠️ Impossible de vérifier les capacités GPU: {e}")
            
            if optimizations:
                print(f"✅ ComfyUI utilisera ces optimisations: {', '.join(optimizations)}")
            else:
                print("⚠️ Aucune optimisation d'attention spécifique détectée dans ComfyUI")
        except Exception as e:
            print(f"⚠️ Impossible de vérifier les optimisations d'attention dans ComfyUI: {e}")
    except ImportError as e:
        print(f"❌ Module ComfyUI model_management non trouvé: {e}")
else:
    print("❌ ComfyUI non trouvé dans les chemins standards")

print("\n============ Test de performance ============")
# Test rapide pour vérifier les performances
def run_performance_test():
    """Exécuter un test de performance sécurisé pour les modules d'attention."""
    if not torch.cuda.is_available():
        print("⚠️ CUDA non disponible, impossible de faire le test de performance")
        return
    
    device = torch.device("cuda")
    
    # Vérifier la mémoire disponible avant de créer les tenseurs
    try:
        total_memory = torch.cuda.get_device_properties(device).total_memory
        available_memory = total_memory - torch.cuda.memory_allocated(device)
        print(f"Mémoire GPU disponible: {available_memory / 1024**3:.1f} GB")
        
        # Utiliser des tailles plus petites pour éviter les problèmes de mémoire
        if available_memory < 2 * 1024**3:  # Moins de 2GB disponible
            batch, heads, seq_len, dim = 1, 8, 1024, 64
            print("Utilisation de tenseurs de taille réduite pour économiser la mémoire")
        else:
            batch, heads, seq_len, dim = 1, 16, 2048, 128
            print("Utilisation de tenseurs de taille standard")
        
        # Créer les tenseurs de test
        q = torch.randn(batch, heads, seq_len, dim, device=device, dtype=torch.float16)
        k = torch.randn(batch, heads, seq_len, dim, device=device, dtype=torch.float16)
        v = torch.randn(batch, heads, seq_len, dim, device=device, dtype=torch.float16)
        
        print("Test avec PyTorch vanilla attention...")
        torch.cuda.synchronize()
        start = torch.cuda.Event(enable_timing=True)
        end = torch.cuda.Event(enable_timing=True)
        
        # Warmup
        for _ in range(3):
            torch.nn.functional.scaled_dot_product_attention(q, k, v)
        torch.cuda.synchronize()
        
        # Test réel
        start.record()
        for _ in range(10):
            torch.nn.functional.scaled_dot_product_attention(q, k, v)
        end.record()
        torch.cuda.synchronize()
        vanilla_time = start.elapsed_time(end) / 10
        print(f"Temps moyen avec PyTorch vanilla: {vanilla_time:.2f} ms")
        
        # Test avec xformers si disponible
        if 'xformers' in sys.modules:
            try:
                from xformers.ops import memory_efficient_attention
                print("Test avec xformers memory_efficient_attention...")
                
                # Warmup
                for _ in range(3):
                    memory_efficient_attention(q, k, v)
                torch.cuda.synchronize()
                
                start.record()
                for _ in range(10):
                    memory_efficient_attention(q, k, v)
                end.record()
                torch.cuda.synchronize()
                xformers_time = start.elapsed_time(end) / 10
                print(f"Temps moyen avec xformers: {xformers_time:.2f} ms")
                speedup = vanilla_time / xformers_time if xformers_time > 0 else 0
                print(f"Accélération avec xformers: {speedup:.2f}x")
            except Exception as e:
                print(f"⚠️ Test avec xformers a échoué: {e}")
        
        # Nettoyage mémoire
        del q, k, v
        torch.cuda.empty_cache()
        
    except Exception as e:
        print(f"⚠️ Test de performance a échoué: {e}")

try:
    run_performance_test()
except Exception as e:
    print(f"⚠️ Impossible d'exécuter le test de performance: {e}")

print("\n============ Notes finales ============")
print("L'image NVIDIA NGC 25.02-py3 inclut généralement:")
print("- FlashAttention-2 intégré à PyTorch")
print("- xformers préinstallé et optimisé")
print("- Différentes optimisations d'attention spécifiques à NVIDIA")
print("\nComfyUI détectera et utilisera automatiquement la meilleure méthode disponible")

print("\n============ Recommandations ============")
if not has_flash_attn and 'xformers' not in sys.modules:
    print("⚠️ Aucun module d'optimisation d'attention détecté")
    print("   Considérez installer xformers ou flash-attn pour de meilleures performances")
elif has_flash_attn or 'xformers' in sys.modules:
    print("✅ Modules d'optimisation d'attention détectés")
    print("   Votre configuration devrait offrir de bonnes performances")

print(f"\n============ Résumé ============")
modules_status = {
    'PyTorch': torch.cuda.is_available() if 'torch' in sys.modules else False,
    'xformers': 'xformers' in sys.modules,
    'FlashAttention': has_flash_attn,
    'Triton': get_module_version('triton') is not None,
    'SageAttention': check_package_installed('sage-attention')[0]
}

for module, status in modules_status.items():
    status_icon = "✅" if status else "❌"
    print(f"{status_icon} {module}: {'Disponible' if status else 'Non disponible'}")

print(f"\nScript terminé avec succès.")