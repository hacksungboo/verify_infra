#!/usr/bin/env bash
# 시연 전 점검. 앱 서버에서 실행.
cd "$(dirname "$0")/../app-server" 2>/dev/null || true
ok(){ printf "  \033[32m✓\033[0m %s\n" "$1"; }; ng(){ printf "  \033[31m✗\033[0m %s\n" "$1"; }

echo "1) OCI 메타데이터 (콘솔 없이 인스턴스 정보 확인)"
if meta=$(curl -fsS -m 2 -H "Authorization: Bearer Oracle" http://169.254.169.254/opc/v2/instance/ 2>/dev/null); then
  ok "$(echo "$meta" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["displayName"],"·",d["canonicalRegionName"],"·",d["shape"])')"
else ng "메타데이터 서비스 응답 없음"; fi

echo "2) 컨테이너"
docker compose ps --format '  {{.Service}}\t{{.State}}\t{{.Status}}' 2>/dev/null || ng "docker compose 실행 불가"

echo "3) 로컬 API"
if h=$(curl -fsS -m 3 http://127.0.0.1:8080/api/health); then ok "$h"; else ng "nginx/백엔드 응답 없음"; fi

echo "4) 공개 주소 (Cloudflare 경유)"
host=$(grep -E '^PUBLIC_HOSTNAME=' .env 2>/dev/null | cut -d= -f2); host=${host:-verifi.ccmall.shop}
if curl -fsS -m 5 "https://$host/api/health" >/dev/null; then ok "https://$host 정상"; else ng "https://$host 응답 없음 (터널/퍼블릭 호스트네임 확인)"; fi

echo "5) 응답한 인스턴스 (화면 상단 배지와 같아야 함)"
curl -fsS -m 5 "https://$host/api/system" 2>/dev/null | python3 -c 'import sys,json;d=json.load(sys.stdin);i=d["instance"];print("  ",i.get("display_name"),i.get("region"),"| DB:",d["db"].get("version","?")[:60])' || true
