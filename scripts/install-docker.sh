#!/usr/bin/env bash
# Oracle Linux 8/9 (opc 계정)에 Docker Engine + compose 플러그인을 설치한다.
#   curl -fsSL https://raw.githubusercontent.com/hacksungboo/verify_infra/main/scripts/install-docker.sh | bash
set -euo pipefail

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  echo "이미 설치됨: $(docker --version), $(docker compose version)"; exit 0
fi

echo "[1/4] podman 등 충돌 패키지 제거 (Oracle Linux 9 기본 포함)"
sudo dnf remove -y podman podman-docker buildah runc containers-common 2>/dev/null || true

echo "[2/4] Docker CE 저장소 추가 (git도 함께 설치)"
sudo dnf install -y dnf-utils git
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "[3/4] 설치"
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

echo "[4/4] opc 계정이 sudo 없이 docker를 쓰도록"
sudo usermod -aG docker "${USER:-opc}"

echo
echo "완료: $(docker --version)"
echo "※ 그룹 반영을 위해 SSH를 끊었다가 다시 접속하세요 (또는 newgrp docker)."
