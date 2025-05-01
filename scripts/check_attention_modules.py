#!/usr/bin/env python3
# Fichier: check_attention_modules.py
# Script pour vérifier la présence de modules d'attention dans un conteneur ComfyUI

import sys
import importlib
import subprocess
import pkg_resources
from packaging import version

print("============ Vérification des modules d'attention pour ComfyUI ============")
print(f"Python version: {sys.version}")

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
except ImportError:
    print("❌ PyTorch n'est pas installé")

# Vérification de xformers
try:
    import xformers
    print(f"✅ xformers est installé (version: {xformers.__version__})")
    
    # Vérification des fonctionnalités spécifiques de xformers
    try:
        from xformers.ops import memory_efficient_attention
        print("✅ memory_efficient_attention est disponible")
    except ImportError:
        print("❌ memory_efficient_attention n'est pas disponible")
except ImportError:
    print("❌ xformers n'est pas installé")

# Vérification de FlashAttention
has_flash_attn = False
try:
    import flash_attn
    has_flash_attn = True
    print(f"✅ FlashAttention est installé (version: {flash_attn.__version__})")
except ImportError:
    try:
        # Essayer de trouver flash-attn via pip
        installed_packages = [pkg.key for pkg in pkg_resources.working_set]
        if 'flash-attn' in installed_packages:
            print("✅ FlashAttention est installé (via pip)")
            has_flash_attn = True
        else:
            # Vérifions si flash_attn est dans le chemin Python
            try:
                subprocess.check_output(["pip", "show", "flash-attn"])
                print("✅ FlashAttention est installé (détecté via pip show)")
                has_flash_attn = True
            except:
                pass
    except:
        pass

if not has_flash_attn:
    # Vérifier si le module est dans les modules torch compilés 
    try:
        if hasattr(torch.nn.functional, 'scaled_dot_product_attention'):
            print("✅ PyTorch inclut scaled_dot_product_attention (peut utiliser FlashAttention si disponible)")
        else:
            print("❌ PyTorch n'inclut pas scaled_dot_product_attention")
    except:
        print("❌ FlashAttention n'est pas détecté")

# Vérification de triton (souvent utilisé avec FlashAttention)
try:
    import triton
    print(f"✅ Triton est installé")
except ImportError:
    print("❌ Triton n'est pas installé")

# Vérification de SageAttention (partie de SageMaker ou custom implementations)
try:
    # Essayer de trouver sage-attention via pip
    installed_packages = [pkg.key for pkg in pkg_resources.working_set]
    if 'sage-attention' in installed_packages:
        print("✅ SageAttention est installé (via pip)")
    else:
        # Vérifions si sage-attention est dans le chemin Python
        try:
            subprocess.check_output(["pip", "show", "sage-attention"])
            print("✅ SageAttention est installé (détecté via pip show)")
        except:
            # Vérifions dans les modules torch
            print("❌ SageAttention n'est pas installé comme package indépendant")
            
            # Vérifions si des modules d'attention similaires sont disponibles dans PyTorch
            if hasattr(torch.nn.functional, 'scaled_dot_product_attention'):
                print("✅ PyTorch inclut scaled_dot_product_attention (alternative à SageAttention)")
            else:
                print("❌ Pas d'alternative native à SageAttention détectée")
except:
    print("❌ Impossible de vérifier SageAttention")

print("\n============ Vérification de l'utilisation dans ComfyUI ============")
# Vérifier si ComfyUI est configuré pour utiliser ces modules d'attention
try:
    import sys
    sys.path.append('/workspace/ComfyUI')
    
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
                if device.type == "cuda" and torch.cuda.get_device_capability(device) >= (8, 0):
                    optimizations.append("sdp-flash-attention2")
            
            if optimizations:
                print(f"✅ ComfyUI utilisera ces optimisations: {', '.join(optimizations)}")
            else:
                print("⚠️ Aucune optimisation d'attention spécifique détectée dans ComfyUI")
        except:
            print("⚠️ Impossible de vérifier les optimisations d'attention dans ComfyUI")
    except ImportError:
        print("❌ Module ComfyUI model_management non trouvé")
except:
    print("❌ Impossible de vérifier l'intégration avec ComfyUI")

print("\n============ Test de performance ============")
# Test rapide pour vérifier les performances
try:
    if torch.cuda.is_available():
        device = torch.device("cuda")
        # Tailles typiques pour les modèles de diffusion
        q = torch.randn(1, 16, 4096, 128, device=device)
        k = torch.randn(1, 16, 4096, 128, device=device)
        v = torch.randn(1, 16, 4096, 128, device=device)
        
        print("Test avec PyTorch vanilla attention...")
        torch.cuda.synchronize()
        start = torch.cuda.Event(enable_timing=True)
        end = torch.cuda.Event(enable_timing=True)
        
        start.record()
        for _ in range(10):
            torch.nn.functional.scaled_dot_product_attention(q, k, v)
        end.record()
        torch.cuda.synchronize()
        vanilla_time = start.elapsed_time(end) / 10
        print(f"Temps moyen avec PyTorch vanilla: {vanilla_time:.2f} ms")
        
        try:
            # Test avec xformers si disponible
            if 'xformers' in sys.modules:
                from xformers.ops import memory_efficient_attention
                print("Test avec xformers memory_efficient_attention...")
                
                start.record()
                for _ in range(10):
                    memory_efficient_attention(q, k, v)
                end.record()
                torch.cuda.synchronize()
                xformers_time = start.elapsed_time(end) / 10
                print(f"Temps moyen avec xformers: {xformers_time:.2f} ms")
                speedup = vanilla_time / xformers_time
                print(f"Accélération avec xformers: {speedup:.2f}x")
        except:
            print("⚠️ Test avec xformers a échoué")
    else:
        print("⚠️ CUDA non disponible, impossible de faire le test de performance")
except:
    print("⚠️ Test de performance a échoué")

print("\n============ Notes finales ============")
print("L'image NVIDIA NGC 25.02-py3 inclut généralement:")
print("- FlashAttention-2 intégré à PyTorch")
print("- xformers préinstallé et optimisé")
print("- Différentes optimisations d'attention spécifiques à NVIDIA")
print("\nComfyUI détectera et utilisera automatiquement la meilleure méthode disponible")