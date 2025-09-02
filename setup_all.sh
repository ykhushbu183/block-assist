#!/usr/bin/env bash
set -Eeuo pipefail

echo "==> BlockAssist setup starting"

# --- Clone BlockAssist ---
if [ ! -d "blockassist" ]; then
  git clone https://github.com/gensyn-ai/blockassist.git
fi
cd blockassist

# --- Run project setup ---
./setup.sh

# --- Dependencies ---
sudo apt update
sudo apt install -y build-essential curl git libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev wget llvm libncurses5-dev libncursesw5-dev \
  xz-utils tk-dev libffi-dev liblzma-dev python3-openssl

# --- pyenv install or reuse ---
if [ -d "$HOME/.pyenv" ]; then
  echo "pyenv already exists, reusing it"
else
  curl https://pyenv.run | bash
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

sudo apt install -y make libxml2-dev libxmlsec1-dev

# --- Python 3.10.18 ---
~/.pyenv/bin/pyenv install -s 3.10.18
~/.pyenv/versions/3.10.18/bin/pip install --upgrade pip psutil readchar

# --- cuDNN ---
wget -q https://developer.download.nvidia.com/compute/cudnn/9.11.0/local_installers/cudnn-local-repo-ubuntu2204-9.11.0_1.0-1_amd64.deb
sudo dpkg -i cudnn-local-repo-ubuntu2204-9.11.0_1.0-1_amd64.deb
sudo cp /var/cudnn-local-repo-ubuntu2204-9.11.0/cudnn-local-4EC753EA-keyring.gpg /usr/share/keyrings/ || true
echo "deb [signed-by=/usr/share/keyrings/cudnn-local-4EC753EA-keyring.gpg] file:///var/cudnn-local-repo-ubuntu2204-9.11.0 /" | sudo tee /etc/apt/sources.list.d/cudnn-local.list

sudo apt update
sudo apt install -y libcudnn9 libcudnn9-dev

# --- CUDA Path ---
LINE='export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH'
grep -qxF "$LINE" "$HOME/.bashrc" || echo "$LINE" >> "$HOME/.bashrc"
source "$HOME/.bashrc"

# --- Run app ---
~/.pyenv/versions/3.10.18/bin/python run.py
