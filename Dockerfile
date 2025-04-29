# Image de base avec CUDA 12.8.1 et cuDNN pour une compatibilité avec les GPU récents
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Métadonnées
LABEL maintainer="ComfyUI Docker Maintainer"
LABEL version="1.0"
LABEL description="ComfyUI Docker Image with CUDA 12.8.1 support for RunPod"

# Set locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive \
    SHELL=/bin/bash \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_PREFER_BINARY=1 \
    PATH="${PATH}:/root/.local/bin" \
    TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0;8.6;8.9;9.0" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}" \
    NVIDIA_VISIBLE_DEVICES=all \
    HF_HUB_ENABLE_HF_TRANSFER="1" \
    NVIDIA_DRIVER_CAPABILITIES=all

# Installation des dépendances système essentielles
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    git wget curl ca-certificates unzip zip openssh-server bash \
    python3.10 python3.10-dev python3-pip python3-setuptools \
    ffmpeg libsm6 libxext6 libgl1-mesa-glx libglib2.0-0 \
    build-essential ninja-build gcc g++ make cmake \
    nginx software-properties-common procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/bin/python3.10 /usr/bin/python && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3

# Configuration SSH pour RunPod
RUN mkdir -p /var/run/sshd && \
    echo 'root:runpod' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Mise à jour de pip
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# Installation de PyTorch avec CUDA 12.8
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

# Installation prioritaire de certains packages pour éviter des conflits
RUN pip3 install --no-cache-dir numpy>=1.25.0 einops safetensors>=0.4.2

# Installation de triton sans version spécifique
RUN pip3 install --no-cache-dir triton

# Clone et installation de ComfyUI dans le répertoire de travail de RunPod
WORKDIR /workspace
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI && \
    cd /workspace/ComfyUI && \
    pip3 install -r requirements.txt

# Installation de ComfyUI Manager et ses dépendances
RUN mkdir -p /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git /workspace/ComfyUI/custom_nodes/ComfyUI-Manager && \
    cd /workspace/ComfyUI/custom_nodes/ComfyUI-Manager && \
    pip3 install -r requirements.txt || echo "Pas de fichier requirements.txt pour ComfyUI-Manager ou installation incomplète"

# Installation d'extensions demandées
RUN git clone https://github.com/twri/sdxl_prompt_styler /workspace/ComfyUI/custom_nodes/sdxl_prompt_styler && \
    cd /workspace/ComfyUI/custom_nodes/sdxl_prompt_styler && \
    if [ -f "requirements.txt" ]; then pip3 install -r requirements.txt; fi

RUN git clone https://github.com/comfyanonymous/ComfyUI_TensorRT /workspace/ComfyUI/custom_nodes/ComfyUI_TensorRT && \
    cd /workspace/ComfyUI/custom_nodes/ComfyUI_TensorRT && \
    if [ -f "requirements.txt" ]; then pip3 install -r requirements.txt; fi

# Création des répertoires pour les modèles
RUN mkdir -p /workspace/ComfyUI/models/checkpoints \
             /workspace/ComfyUI/models/vae \
             /workspace/ComfyUI/models/loras \
             /workspace/ComfyUI/models/controlnet \
             /workspace/ComfyUI/models/upscale_models \
             /workspace/ComfyUI/models/clip \
             /workspace/ComfyUI/models/clip_vision \
             /workspace/ComfyUI/models/embeddings \
             /workspace/ComfyUI/models/unet \
             /workspace/ComfyUI/models/configs \
             /workspace/ComfyUI/models/text_encoders \
             /workspace/ComfyUI/models/diffusion_models \
             /workspace/ComfyUI/input \
             /workspace/ComfyUI/output \
             /workspace/ComfyUI/temp

# Configuration pour JupyterLab (requis par RunPod)
RUN pip3 install --no-cache-dir jupyterlab ipywidgets && \
    mkdir -p /root/.jupyter && \
    echo "c.ServerApp.ip = '0.0.0.0'" > /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin = '*'" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.port = 8888" >> /root/.jupyter/jupyter_lab_config.py

# Configuration du répertoire nginx pour RunPod
RUN mkdir -p /usr/share/nginx/html

# Création des fichiers log
RUN touch /var/log/comfyui.log /var/log/jupyter.log && \
    chmod 666 /var/log/comfyui.log /var/log/jupyter.log

# Copie des fichiers de configuration
COPY config/nginx.conf /workspace/ComfyUI/nginx.conf
COPY config/readme.html /workspace/ComfyUI/readme.html
COPY config/README.md /usr/share/nginx/html/README.md
COPY config/extra_model_paths.yml /workspace/ComfyUI/extra_model_paths.yml
COPY config/download_models.sh /workspace/ComfyUI/download_models.sh
COPY config/pre_start.sh /pre_start.sh
COPY config/start.sh /start.sh

# Attribution des permissions d'exécution aux scripts
RUN chmod +x /workspace/ComfyUI/download_models.sh /pre_start.sh /start.sh

# Exposition des ports
EXPOSE 3000 8188 8888 22

# Définition des volumes pour persistance des données
VOLUME ["/workspace/ComfyUI/models", "/workspace/ComfyUI/output", "/workspace/ComfyUI/input"]

# Supprime l'ENTRYPOINT par défaut de l'image NVIDIA pour être compatible avec RunPod
CMD ["/start.sh"]