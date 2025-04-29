#!/bin/bash
set -e

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

# Start nginx service
start_nginx() {
    echo "Configuration de Nginx..."
    # Copier la configuration nginx
    cp /workspace/ComfyUI/nginx.conf /etc/nginx/nginx.conf
    # Démarrer le service
    service nginx start
    echo "Nginx démarré"
}

# Setup SSH service
setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Configuration SSH avec clé publique..."
        mkdir -p ~/.ssh
        echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
        chmod 700 -R ~/.ssh
        
        # Génération des clés SSH si nécessaire
        if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
            ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ''
        fi
        
        service ssh start
        echo "Service SSH démarré"
    fi
}

# Start Jupyter if password is set
start_jupyter() {
    if [[ $JUPYTER_PASSWORD ]]; then
        echo "Démarrage de Jupyter Lab..."
        mkdir -p /workspace
        cd /workspace
        nohup jupyter lab --allow-root --no-browser --port=8888 --ip=* \
            --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* \
            --ServerApp.preferred_dir=/workspace &> /jupyter.log &
        echo "Jupyter Lab démarré (port 8888)"
    fi
}

# Export RunPod environment variables to shell
export_env_vars() {
    printenv | grep -E '^RUNPOD_|^PATH=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment
    echo 'source /etc/rp_environment' >> ~/.bashrc
    
    # Définir le répertoire de travail par défaut dans .bashrc
    echo 'cd /workspace/ComfyUI' >> ~/.bashrc
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

echo "Démarrage des services..."

# Exécuter le script de pré-démarrage
echo "Exécution du script de pré-démarrage..."
bash /pre_start.sh

# S'assurer que le répertoire de travail est correct
cd /workspace/ComfyUI

# Démarrer les autres services
start_nginx
setup_ssh
start_jupyter
export_env_vars

echo "Tous les services ont démarré avec succès."
echo "ComfyUI est accessible sur le port 3000"

# Maintenir le conteneur actif
sleep infinity