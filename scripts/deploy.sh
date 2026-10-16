#!/usr/bin/env bash
# 앱 서버에서 최신 이미지로 갱신한다.  사용: ./scripts/deploy.sh [태그]   (기본 latest)
set -euo pipefail
cd "$(dirname "$0")/../app-server"
[ -f .env ] || { echo ".env가 없어요. cp .env.example .env 후 값을 채우세요."; exit 1; }
if [ -n "${1:-}" ]; then sed -i "s/^IMAGE_TAG=.*/IMAGE_TAG=$1/" .env; fi

docker compose pull
docker compose up -d --remove-orphans
echo "기동 대기 중…"
for i in $(seq 1 60); do
  if curl -fsS http://127.0.0.1:8080/api/health >/dev/null 2>&1; then
    echo "정상: $(curl -fsS http://127.0.0.1:8080/api/health)"; docker compose ps; exit 0
  fi
  sleep 5
done
echo "5분 안에 정상 응답이 없어요. 로그를 확인하세요: docker compose logs --tail=100 backend db-tunnel"
exit 1
