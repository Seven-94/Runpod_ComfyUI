# Image de base NGC avec PyTorch et CUDA préinstallés pour GPU dernière génération
FROM nvcr.io/nvidia/pytorch:25.02-py3

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    TORCH_CUDA_ARCH_LIST="8.6+PTX;9.0+PTX;12.0+PTX;12.6+PTX" \
    HF_HUB_ENABLE_HF_TRANSFER="1"

# Installation des dépendances système
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    ffmpeg libsm6 libxext6 libglib2.0-0 libgl1 \
    nginx openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configuration SSH pour RunPod
RUN mkdir -p /var/run/sshd && \
    echo 'root:runpod' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Installation des packages Python supplémentaires (xformers déjà inclus dans l'image NGC)
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 --force-reinstall && \
    pip3 install einops safetensors jupyterlab ipywidgets

# Création d'une copie de ComfyUI dans l'image Docker
WORKDIR /opt
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /opt/ComfyUI && \
    cd /opt/ComfyUI && \
    pip install -r requirements.txt

# Préinstallation des extensions dans un répertoire séparé
RUN mkdir -p /opt/comfyui_extensions && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git /opt/comfyui_extensions/ComfyUI-Manager && \
    cd /opt/comfyui_extensions/ComfyUI-Manager && \
    pip install -r requirements.txt || echo "Pas de requirements.txt pour ComfyUI-Manager" && \
    git clone https://github.com/twri/sdxl_prompt_styler /opt/comfyui_extensions/sdxl_prompt_styler && \
    cd /opt/comfyui_extensions/sdxl_prompt_styler && \
    if [ -f "requirements.txt" ]; then pip install -r requirements.txt; fi && \
    git clone https://github.com/comfyanonymous/ComfyUI_TensorRT /opt/comfyui_extensions/ComfyUI_TensorRT && \
    cd /opt/comfyui_extensions/ComfyUI_TensorRT && \
    if [ -f "requirements.txt" ]; then pip install -r requirements.txt; fi

# Création des répertoires de base
RUN mkdir -p /opt/comfyui_templates /usr/share/nginx/html

# Copie des fichiers de configuration
COPY config/nginx.conf /opt/comfyui_templates/nginx.conf
COPY config/readme.html /opt/comfyui_templates/readme.html
COPY config/README.md /usr/share/nginx/html/README.md
COPY config/extra_model_paths.yml /opt/comfyui_templates/extra_model_paths.yml
COPY config/download_models.sh /opt/comfyui_templates/download_models.sh
COPY config/start.sh /start.sh
COPY config/pre_start.sh /pre_start.sh

# Permissions d'exécution
RUN chmod +x /opt/comfyui_templates/download_models.sh /pre_start.sh /start.sh

# Exposition des ports
EXPOSE 3000 8188 8888 22

# Définir le répertoire de travail par défaut vers le répertoire ComfyUI dans le volume
WORKDIR /workspace/ComfyUI

CMD ["/start.sh"]