#!/bin/bash
echo "🔍 DIAGNOSTIC RUNPOD - Services non accessibles"
echo "========================================================"

echo ""
echo "📋 1. VÉRIFICATION DES PROCESSUS"
echo "----------------------------------------"
echo "ComfyUI (port 8188):"
if pgrep -f "python.*main.py.*8188" > /dev/null; then
    echo "✅ ComfyUI est en cours d'exécution"
    ps aux | grep "python.*main.py" | grep -v grep
else
    echo "❌ ComfyUI n'est PAS en cours d'exécution"
fi

echo ""
echo "Nginx:"
if pgrep nginx > /dev/null; then
    echo "✅ Nginx est en cours d'exécution"
    ps aux | grep nginx | grep -v grep
else
    echo "❌ Nginx n'est PAS en cours d'exécution"
fi

echo ""
echo "Jupyter:"
if pgrep -f "jupyter" > /dev/null; then
    echo "✅ Jupyter est en cours d'exécution"
    ps aux | grep jupyter | grep -v grep
else
    echo "❌ Jupyter n'est PAS en cours d'exécution"
fi

echo ""
echo "📋 2. VÉRIFICATION DES PORTS"
echo "----------------------------------------"
netstat -tlnp | grep -E ":(3000|8188|8888|22)" || echo "Aucun port actif trouvé"

echo ""
echo "📋 3. VÉRIFICATION DES FICHIERS DE LOG"
echo "----------------------------------------"
echo "Log ComfyUI:"
if [ -f "/var/log/comfyui.log" ]; then
    echo "✅ Log ComfyUI trouvé"
    echo "Dernières lignes:"
    tail -n 10 /var/log/comfyui.log
else
    echo "❌ Log ComfyUI non trouvé"
fi

echo ""
echo "Log Jupyter:"
if [ -f "/jupyter.log" ]; then
    echo "✅ Log Jupyter trouvé"
    echo "Dernières lignes:"
    tail -n 5 /jupyter.log
else
    echo "❌ Log Jupyter non trouvé"
fi

echo ""
echo "📋 4. VÉRIFICATION DE LA CONFIGURATION"
echo "----------------------------------------"
echo "Répertoire ComfyUI:"
ls -la /workspace/ComfyUI/ | head -n 10

echo ""
echo "Configuration nginx:"
if [ -f "/workspace/ComfyUI/nginx.conf" ]; then
    echo "✅ nginx.conf trouvé"
else
    echo "❌ nginx.conf manquant"
fi

echo ""
echo "Variables d'environnement importantes:"
echo "JUPYTER_PASSWORD: ${JUPYTER_PASSWORD:-'Non défini'}"
echo "HF_TOKEN: ${HF_TOKEN:-'Non défini'}"

echo ""
echo "📋 5. TEST DE CONNECTIVITÉ LOCALE"
echo "----------------------------------------"
echo "Test port 8188 (ComfyUI):"
curl -s -o /dev/null -w "%{http_code}" http://localhost:8188 || echo "Échec connexion"

echo ""
echo "Test port 3000 (nginx):"
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "Échec connexion"

echo ""
echo "========================================================"
echo "✅ Diagnostic terminé"
