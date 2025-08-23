#!/bin/bash
# Script d'installation avec stratégies de fallback

install_with_fallback() {
    local package_name=$1
    shift
    local strategies=("$@")
    
    echo "📦 Installation de $package_name..."
    
    for strategy in "${strategies[@]}"; do
        echo "🔄 Tentative: $strategy"
        if eval $strategy; then
            echo "✅ $package_name installé avec succès"
            return 0
        else
            echo "❌ Stratégie échouée, tentative suivante..."
        fi
    done
    
    echo "⚠️ Toutes les stratégies ont échoué pour $package_name"
    return 1
}

# Installation des packages de base
pip install --upgrade pip setuptools wheel
pip install einops safetensors jupyterlab ipywidgets

# Installation avec fallback pour chaque package problématique
install_with_fallback "flash-attn" \
    "pip install flash-attn --no-build-isolation" \
    "pip install flash-attn==2.5.8 --no-build-isolation" \
    "pip install flash-attn --no-deps --no-build-isolation" \
    "echo 'Continuing without flash-attn'"

install_with_fallback "xformers" \
    "pip install xformers" \
    "pip install xformers==0.0.23.post1" \
    "pip install xformers --index-url https://download.pytorch.org/whl/cu121" \
    "echo 'Continuing without xformers'"

install_with_fallback "triton" \
    "pip install triton" \
    "pip install triton==2.1.0" \
    "echo 'Using PyTorch built-in triton'"

# Nettoyage final
rm -rf /root/.cache/pip
echo "✅ Installation terminée"
