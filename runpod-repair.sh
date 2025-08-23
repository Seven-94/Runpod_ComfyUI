#!/bin/bash
echo "🔧 RÉPARATION AUTOMATIQUE DES SERVICES RUNPOD"
echo "=============================================="

# Fonction pour démarrer ComfyUI manuellement
start_comfyui() {
    echo "🚀 Démarrage manuel de ComfyUI..."
    cd /workspace/ComfyUI
    
    # Arrêter toute instance précédente
    pkill -f "python.*main.py" 2>/dev/null || true
    
    # Créer le répertoire de logs
    mkdir -p /var/log
    
    # Démarrer ComfyUI
    nohup python main.py \
        --listen \
        --port 8188 \
        --extra-model-paths-config /workspace/ComfyUI/extra_model_paths.yml \
        --force-fp16 \
        --use-split-cross-attention \
        --enable-cors-header \
        > /var/log/comfyui.log 2>&1 &
    
    sleep 3
    if pgrep -f "python.*main.py" > /dev/null; then
        echo "✅ ComfyUI démarré avec succès"
    else
        echo "❌ Échec du démarrage de ComfyUI"
        return 1
    fi
}

# Fonction pour démarrer nginx
start_nginx() {
    echo "🌐 Démarrage de nginx..."
    
    # Copier la configuration
    if [ -f "/workspace/ComfyUI/nginx.conf" ]; then
        cp /workspace/ComfyUI/nginx.conf /etc/nginx/nginx.conf
    else
        echo "❌ Configuration nginx manquante"
        return 1
    fi
    
    # Démarrer nginx
    service nginx start
    
    if pgrep nginx > /dev/null; then
        echo "✅ Nginx démarré avec succès"
    else
        echo "❌ Échec du démarrage de nginx"
        return 1
    fi
}

# Fonction pour démarrer Jupyter
start_jupyter() {
    if [ -n "$JUPYTER_PASSWORD" ]; then
        echo "📓 Démarrage de Jupyter..."
        
        pkill -f "jupyter" 2>/dev/null || true
        
        cd /workspace
        nohup jupyter lab --allow-root --no-browser --port=8888 --ip=* \
            --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* \
            --ServerApp.preferred_dir=/workspace &> /jupyter.log &
        
        sleep 2
        if pgrep -f "jupyter" > /dev/null; then
            echo "✅ Jupyter démarré avec succès"
        else
            echo "❌ Échec du démarrage de Jupyter"
        fi
    else
        echo "⚠️ JUPYTER_PASSWORD non défini, Jupyter non démarré"
    fi
}

# Vérifications préliminaires
echo "📋 Vérifications préliminaires..."

if [ ! -d "/workspace" ]; then
    echo "❌ Volume /workspace non monté!"
    echo "   Vérifiez la configuration du template RunPod"
    exit 1
fi

if [ ! -f "/workspace/ComfyUI/main.py" ]; then
    echo "⚠️ ComfyUI non trouvé, exécution du script de pré-démarrage..."
    bash /pre_start.sh
fi

# Démarrage des services
start_comfyui
start_nginx  
start_jupyter

echo ""
echo "✅ Réparation terminée!"
echo "📋 Vérifiez les services:"
echo "   - ComfyUI: http://localhost:8188"
echo "   - Interface (nginx): http://localhost:3000" 
echo "   - Jupyter: http://localhost:8888"
