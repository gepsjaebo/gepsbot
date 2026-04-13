#!/bin/bash
# chmod +x install_python3.12.sh && ./install_python3.12.sh

set -e

start_time=$SECONDS

echo "=== 1. 시스템 패키지 설치 ==="
sudo apt update
sudo apt install -y \
  build-essential \
  zlib1g-dev \
  libncurses5-dev \
  libgdbm-dev \
  libnss3-dev \
  libssl-dev \
  libreadline-dev \
  libffi-dev \
  libsqlite3-dev \
  libbz2-dev \
  liblzma-dev \
  tk-dev \
  uuid-dev \
  curl \
  wget \
  ca-certificates \
  software-properties-common

echo "=== 2. Python 3.12.4 다운로드 및 설치 ==="
cd /tmp
wget -O Python-3.12.4.tar.xz https://www.python.org/ftp/python/3.12.4/Python-3.12.4.tar.xz
tar -xf Python-3.12.4.tar.xz
cd Python-3.12.4

./configure --enable-optimizations
sudo make -j"$(nproc)" altinstall

cd /tmp
rm -rf /tmp/Python-3.12.4 /tmp/Python-3.12.4.tar.xz

echo "=== 3. pip 업그레이드 ==="
python3.12 -m ensurepip --upgrade || true
python3.12 -m pip install --upgrade pip setuptools wheel

echo "=== 4. Python 패키지 설치 ==="
python3.12 -m pip install --force-reinstall \
  "flask>=3.0,<4.0" \
  "requests>=2.31,<3.0" \
  "openai>=1.0,<2.0" \
  "pinecone>=5.0,<6.0" \
  "python-dotenv>=1.0,<2.0" \
  "tiktoken>=0.7,<1.0" \
  "pdfplumber>=0.11,<1.0" \
  "pandas>=2.0,<3.0" \
  "gunicorn>=21.0,<24.0"

echo "=== 5. alias 설정 ==="
if ! grep -q "alias python3='python3.12'" ~/.bashrc; then
  echo "alias python3='python3.12'" >> ~/.bashrc
fi

if ! grep -q "alias pip='python3.12 -m pip'" ~/.bashrc; then
  echo "alias pip='python3.12 -m pip'" >> ~/.bashrc
fi

echo "=== 6. 설치 확인 ==="
python3.12 --version
python3.12 -m pip --version
python3.12 -m pip list | grep -E "Flask|requests|openai|pinecone|python-dotenv|tiktoken|pdfplumber|pandas|gunicorn" || true

end_time=$SECONDS
elapsed=$(( end_time - start_time ))
echo "스크립트 실행 시간: $(( elapsed / 60 ))분 $(( elapsed % 60 ))초"
echo "새 터미널을 열거나 'source ~/.bashrc' 후 python3 / pip alias를 사용하세요."
