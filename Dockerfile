# Image de base avec CUDA 12.8.1 pour RunPod
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0;8.6;8.9;9.0" \
    HF_HUB_ENABLE_HF_TRANSFER="1"

# Installation des dépendances système
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    git wget curl unzip zip python3.10 python3.10-dev python3-pip \
    ffmpeg libsm6 libxext6 libgl1-mesa-glx libglib2.0-0 \
    build-essential ninja-build gcc g++ make cmake \
    nginx openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/bin/python3.10 /usr/bin/python

# Configuration SSH pour RunPod
RUN mkdir -p /var/run/sshd && \
    echo 'root:runpod' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Mise à jour de pip et installation des packages Python
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 && \
    pip3 install numpy einops safetensors triton jupyterlab ipywidgets

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