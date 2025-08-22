#!/usr/bin/env python3
"""
Script de vérification des optimisations GPU Blackwell pour ComfyUI
Compatible PyTorch 2.8.0 + CUDA 12.9 - Ce script vérifie que toutes les optimisations sont correctement activées
"""

import sys
import torch
import subprocess
import os
from typing import Dict, List, Tuple

def check_torch_version() -> Tuple[bool, str]:
    """Vérifier la version de PyTorch"""
    torch_version = torch.__version__
    required_version = "2.8.0"
    
    if torch_version >= required_version:
        return True, f"✅ PyTorch {torch_version} (>= {required_version})"
    else:
        return False, f"❌ PyTorch {torch_version} (< {required_version} requis)"

def check_cuda_version() -> Tuple[bool, str]:
    """Vérifier la version de CUDA"""
    if not torch.cuda.is_available():
        return False, "❌ CUDA non disponible"
    
    cuda_version = torch.version.cuda
    required_version = "12.9"
    
    if cuda_version and cuda_version >= required_version:
        return True, f"✅ CUDA {cuda_version} (>= {required_version})"
    else:
        return False, f"❌ CUDA {cuda_version or 'Unknown'} (< {required_version} requis)"

def check_gpu_architecture() -> Tuple[bool, str]:
    """Vérifier l'architecture GPU et support Blackwell"""
    if not torch.cuda.is_available():
        return False, "❌ CUDA non disponible"
    
    gpu_name = torch.cuda.get_device_name(0)
    gpu_capability = torch.cuda.get_device_capability(0)
    
    # Blackwell a une compute capability de 9.0
    if gpu_capability[0] >= 9:
        return True, f"✅ GPU Blackwell détecté: {gpu_name} (Compute {gpu_capability[0]}.{gpu_capability[1]})"
    elif gpu_capability[0] >= 8:
        return True, f"✅ GPU moderne détecté: {gpu_name} (Compute {gpu_capability[0]}.{gpu_capability[1]})"
    else:
        return False, f"⚠️ GPU ancien: {gpu_name} (Compute {gpu_capability[0]}.{gpu_capability[1]})"

def check_environment_variables() -> List[Tuple[bool, str]]:
    """Vérifier les variables d'environnement d'optimisation"""
    # Variables d'optimisation critiques pour GPU
    critical_optimizations = [
        ("TORCH_CUDA_ARCH_LIST", "9.0+PTX", "Architecture Blackwell supportée"),
        ("CUDA_MODULE_LOADING", "LAZY", "Chargement CUDA optimisé"),
        ("TORCH_CUDNN_V8_API_ENABLED", "1", "CuDNN v8 API activée"),
        ("PYTORCH_CUDA_ALLOC_CONF", "expandable_segments:True", "Allocation mémoire optimisée"),
        ("CUBLAS_WORKSPACE_CONFIG", ":4096:8", "Configuration CUBLAS optimisée"),
        ("HF_HUB_ENABLE_HF_TRANSFER", "1", "Transfert HuggingFace optimisé"),
        ("TORCH_COMPILE_MODE", "default", "Mode de compilation PyTorch"),
        ("TORCH_NCCL_AVOID_RECORD_STREAMS", "1", "Optimisation NCCL streams"),
        ("PYTORCH_JIT_USE_NNC_NOT_NVFUSER", "0", "Configuration JIT optimisée"),
    ]
    
    # Variables d'environnement générales
    general_variables = [
        ("PYTHONUNBUFFERED", "1", "Sortie Python non tamponnée"),
        ("PIP_NO_CACHE_DIR", "1", "Cache pip désactivé"),
        ("DEBIAN_FRONTEND", "noninteractive", "Installation Debian non interactive"),
    ]
    
    results = []
    
    # Vérification des optimisations critiques
    for var_name, expected_contains, description in critical_optimizations:
        var_value = os.environ.get(var_name, "")
        if expected_contains in var_value:
            results.append((True, f"✅ {description}: {var_name}={var_value}"))
        else:
            results.append((False, f"❌ {description}: {var_name}={var_value or 'Non définie'}"))
    
    # Vérification des variables générales (moins critiques)
    for var_name, expected_value, description in general_variables:
        var_value = os.environ.get(var_name, "")
        if var_value == expected_value:
            results.append((True, f"✅ {description}: {var_name}={var_value}"))
        elif var_value:
            results.append((True, f"⚠️ {description}: {var_name}={var_value} (valeur différente mais définie)"))
        else:
            results.append((False, f"❌ {description}: {var_name} non définie"))
    
    return results

def check_cuda_architecture_support() -> Tuple[bool, str]:
    """Vérifier spécifiquement le support des architectures CUDA"""
    cuda_arch_list = os.environ.get("TORCH_CUDA_ARCH_LIST", "")
    
    if not cuda_arch_list:
        return False, "❌ TORCH_CUDA_ARCH_LIST non définie"
    
    # Vérifier le support Blackwell (9.0) et la rétrocompatibilité (8.6)
    has_blackwell = "9.0+PTX" in cuda_arch_list
    has_ampere = "8.6+PTX" in cuda_arch_list
    
    if has_blackwell and has_ampere:
        return True, f"✅ Support complet: Blackwell (9.0) + Ampere (8.6): {cuda_arch_list}"
    elif has_blackwell:
        return True, f"✅ Support Blackwell détecté: {cuda_arch_list}"
    elif has_ampere:
        return False, f"⚠️ Support Ampere uniquement (pas de Blackwell): {cuda_arch_list}"
    else:
        return False, f"❌ Architecture CUDA non optimisée: {cuda_arch_list}"

def check_pytorch_memory_optimization() -> Tuple[bool, str]:
    """Vérifier les optimisations mémoire PyTorch"""
    alloc_conf = os.environ.get("PYTORCH_CUDA_ALLOC_CONF", "")
    
    if not alloc_conf:
        return False, "❌ PYTORCH_CUDA_ALLOC_CONF non définie"
    
    has_expandable = "expandable_segments:True" in alloc_conf
    has_roundup = "roundup_power2_divisions" in alloc_conf
    
    if has_expandable and has_roundup:
        return True, f"✅ Optimisations mémoire complètes: {alloc_conf}"
    elif has_expandable:
        return True, f"✅ Segments extensibles activés: {alloc_conf}"
    else:
        return False, f"❌ Optimisations mémoire manquantes: {alloc_conf}"

def check_flash_attention() -> Tuple[bool, str]:
    """Vérifier la disponibilité de Flash Attention"""
    try:
        import flash_attn
        return True, f"✅ Flash Attention disponible (v{flash_attn.__version__})"
    except ImportError:
        return False, "❌ Flash Attention non installée"

def check_xformers() -> Tuple[bool, str]:
    """Vérifier la disponibilité de xFormers"""
    try:
        import xformers
        return True, f"✅ xFormers disponible (v{xformers.__version__})"
    except ImportError:
        return False, "❌ xFormers non installé"

def check_triton() -> Tuple[bool, str]:
    """Vérifier la disponibilité de Triton"""
    try:
        import triton
        return True, f"✅ Triton disponible (v{triton.__version__})"
    except ImportError:
        return False, "❌ Triton non installé"

def check_torch_compile() -> Tuple[bool, str]:
    """Vérifier les optimisations torch.compile"""
    try:
        # Test simple de torch.compile
        @torch.compile
        def test_function(x):
            return x * 2
        
        if torch.cuda.is_available():
            x = torch.randn(10, device='cuda')
            result = test_function(x)
            return True, "✅ torch.compile fonctionnel"
        else:
            return False, "❌ CUDA requis pour torch.compile"
    except Exception as e:
        return False, f"❌ torch.compile non fonctionnel: {str(e)}"

def main():
    """Fonction principale"""
    print("🔍 Vérification des optimisations GPU Blackwell pour ComfyUI")
    print("=" * 60)
    print()
    
    # Affichage des informations système importantes
    print("📋 Informations système:")
    print(f"  • Python: {sys.version.split()[0]}")
    print(f"  • PyTorch: {torch.__version__}")
    if torch.cuda.is_available():
        print(f"  • CUDA: {torch.version.cuda}")
        print(f"  • GPU: {torch.cuda.get_device_name(0)}")
        print(f"  • Compute Capability: {'.'.join(map(str, torch.cuda.get_device_capability(0)))}")
    else:
        print("  • CUDA: Non disponible")
    print()
    
    all_checks_passed = True
    
    # Vérifications principales
    checks = [
        ("Version PyTorch", check_torch_version),
        ("Version CUDA", check_cuda_version), 
        ("Architecture GPU", check_gpu_architecture),
        ("Support Architecture CUDA", check_cuda_architecture_support),
        ("Optimisations Mémoire PyTorch", check_pytorch_memory_optimization),
        ("Flash Attention", check_flash_attention),
        ("xFormers", check_xformers),
        ("Triton", check_triton),
        ("torch.compile", check_torch_compile),
    ]
    
    for check_name, check_func in checks:
        try:
            success, message = check_func()
            print(f"{check_name}: {message}")
            if not success:
                all_checks_passed = False
        except Exception as e:
            print(f"{check_name}: ❌ Erreur - {str(e)}")
            all_checks_passed = False
    
    print()
    print("🔧 Variables d'environnement d'optimisation:")
    print("-" * 50)
    env_results = check_environment_variables()
    env_critical_failed = 0
    env_general_failed = 0
    
    for success, message in env_results:
        print(f"  {message}")
        if not success:
            if "❌" in message:
                if any(critical in message for critical in ["TORCH_", "CUDA_", "PYTORCH_", "CUBLAS_"]):
                    env_critical_failed += 1
                else:
                    env_general_failed += 1
                all_checks_passed = False
    
    print()
    if env_critical_failed > 0:
        print(f"⚠️ {env_critical_failed} variable(s) d'optimisation critique(s) manquante(s)")
    if env_general_failed > 0:
        print(f"ℹ️ {env_general_failed} variable(s) générale(s) non configurée(s) (non critique)")
    
    print()
    print("=" * 60)
    
    if all_checks_passed:
        print("🎉 Toutes les optimisations Blackwell sont correctement configurées!")
        print("✅ Votre environnement est optimal pour les GPU Blackwell.")
        sys.exit(0)
    else:
        print("⚠️ Certaines optimisations ne sont pas configurées correctement.")
        print("📖 Actions recommandées:")
        print("   • Vérifiez les variables d'environnement manquantes")
        print("   • Consultez le Dockerfile pour les configurations recommandées")
        print("   • Redémarrez le conteneur si nécessaire")
        sys.exit(1)

if __name__ == "__main__":
    main()
