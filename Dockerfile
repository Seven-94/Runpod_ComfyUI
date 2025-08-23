# Image de base optimisée pour GPU Blackwell avec PyTorch 2.8.0 et CUDA 12.9
FROM pytorch/pytorch:2.8.0-cuda12.9-cudnn9-devel

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Variables d'environnement optimisées pour GPU Blackwell et PyTorch 2.8.0
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    TORCH_CUDA_ARCH_LIST="8.6+PTX;9.0+PTX" \
    HF_HUB_ENABLE_HF_TRANSFER="1" \
    CUDA_MODULE_LOADING="LAZY" \
    TORCH_CUDNN_V8_API_ENABLED="1" \
    TORCH_COMPILE_MODE="default" \
    PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True,roundup_power2_divisions:16" \
    CUBLAS_WORKSPACE_CONFIG=":4096:8" \
    TORCH_NCCL_AVOID_RECORD_STREAMS="1" \
    PYTORCH_JIT_USE_NNC_NOT_NVFUSER="0"

# Argument pour la version de ComfyUI (par défaut v0.3.51)
ARG COMFYUI_VERSION=v0.3.51

# Installation des dépendances système
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    ffmpeg libsm6 libxext6 libglib2.0-0 libgl1 \
    nginx openssh-server git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configuration SSH pour RunPod
RUN mkdir -p /var/run/sshd && \
    echo 'root:runpod' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Installation des packages Python optimisés pour Blackwell
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install \
        einops safetensors jupyterlab ipywidgets && \
    pip3 install flash-attn --no-build-isolation || echo "⚠️ flash-attn installation failed, continuing..." && \
    pip3 install triton || echo "⚠️ triton installation failed, continuing..." && \
    pip3 install xformers || echo "⚠️ xformers installation failed, continuing..." && \
    rm -rf /root/.cache/pip

# Installation de ComfyUI avec version dynamique
WORKDIR /opt
RUN git clone --depth 1 --branch ${COMFYUI_VERSION} https://github.com/comfyanonymous/ComfyUI.git /opt/ComfyUI && \
    cd /opt/ComfyUI && \
    pip install -r requirements.txt && \
    rm -rf /root/.cache/pip

# Préinstallation des extensions essentielles
RUN mkdir -p /opt/comfyui_extensions && \
    # ComfyUI-Manager
    git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git /opt/comfyui_extensions/ComfyUI-Manager && \
    cd /opt/comfyui_extensions/ComfyUI-Manager && \
    pip install -r requirements.txt || echo "Pas de requirements.txt pour ComfyUI-Manager" && \
    # ComfyUI-Crystools
    git clone --depth 1 https://github.com/crystian/ComfyUI-Crystools.git /opt/comfyui_extensions/ComfyUI-Crystools && \
    cd /opt/comfyui_extensions/ComfyUI-Crystools && \
    if [ -f "requirements.txt" ]; then pip install -r requirements.txt; fi && \
    # ComfyUI-KJNodes  
    git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes.git /opt/comfyui_extensions/ComfyUI-KJNodes && \
    cd /opt/comfyui_extensions/ComfyUI-KJNodes && \
    if [ -f "requirements.txt" ]; then pip install -r requirements.txt; fi && \
    rm -rf /root/.cache/pip /tmp/* /var/tmp/*

# Création des répertoires de base
RUN mkdir -p /opt/comfyui_templates /usr/share/nginx/html

# Copie des fichiers de configuration (sans download_models.sh)
COPY config/nginx.conf /opt/comfyui_templates/nginx.conf
COPY config/readme.html /opt/comfyui_templates/readme.html
COPY config/README.md /usr/share/nginx/html/README.md
COPY config/extra_model_paths.yml /opt/comfyui_templates/extra_model_paths.yml
COPY config/start.sh /start.sh
COPY config/pre_start.sh /pre_start.sh

# Copie des scripts utilitaires
COPY scripts/check_attention_modules.py /opt/scripts/check_attention_modules.py
COPY scripts/check_blackwell_optimizations.py /opt/scripts/check_blackwell_optimizations.py
COPY fix-comfyui-git.sh /opt/scripts/fix-comfyui-git.sh
COPY diagnose-comfyui-git.sh /opt/scripts/diagnose-comfyui-git.sh

# Permissions d'exécution
RUN chmod +x /pre_start.sh /start.sh /opt/scripts/*.py /opt/scripts/fix-comfyui-git.sh /opt/scripts/diagnose-comfyui-git.sh

# Exposition des ports
# 3000: nginx (interface ComfyUI)
# 8188: ComfyUI (service principal)
# 8888: JupyterLab (optionnel)
# 22: SSH
EXPOSE 3000 8188 8888 22

# Définir le répertoire de travail par défaut vers le répertoire ComfyUI dans le volume
WORKDIR /workspace/ComfyUI

CMD ["/start.sh"]