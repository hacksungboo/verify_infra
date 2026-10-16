# Cloudflare 터널 만들기 — verifi.ccmall.shop

`ccmall.shop` 이 이미 Cloudflare에 등록되어 있다는 전제예요. 터널은 서버가 Cloudflare로 **나가는** 연결만 쓰기 때문에 OCI 보안 목록을 건드릴 필요가 없어요.

## 1. 터널 생성

1. https://one.dash.cloudflare.com → 계정 선택 → **Networks → Tunnels** → **Create a tunnel**
2. 유형: **Cloudflared** → 이름: `verifi-seoul`
3. 설치 화면에서 OS는 아무거나 고르고, 명령어에 들어 있는 **`eyJ…` 로 시작하는 토큰만 복사**
   → 앱 서버 `.env` 의 `CLOUDFLARE_TUNNEL_TOKEN` 에 넣기
   (토큰은 비밀번호와 같아요. 채팅·깃헙에 붙이지 마세요)
4. **Next**

## 2. 퍼블릭 호스트네임

| 항목 | 값 |
|---|---|
| Subdomain | `verifi` |
| Domain | `ccmall.shop` |
| Path | (비움) |
| Service Type | `HTTP` |
| URL | `frontend:80` |

**Save tunnel** → DNS에 `verifi.ccmall.shop` CNAME이 자동으로 생겨요.

> URL이 `localhost:80` 이 아니라 `frontend:80` 인 이유: cloudflared가 compose 네트워크 안의 컨테이너라서 서비스 이름으로 찾아요.

## 3. 확인

```bash
docker compose logs cloudflared | grep -i "Registered tunnel connection"   # 4줄 정도 보이면 정상
curl -I https://verifi.ccmall.shop/healthz
```

Cloudflare 대시보드 터널 상태가 **HEALTHY** 가 되면 끝.

## 4. 권장 설정 (선택)

- **SSL/TLS → Edge Certificates → Always Use HTTPS**: 켜기
- SSE(실시간 진행률)는 Cloudflare를 그대로 통과해요. 백엔드가 15초마다 ping을 보내서 100초 유휴 타임아웃에 걸리지 않아요.

## 5. 도쿄 예비 리전과의 관계

같은 터널 토큰으로 도쿄 인스턴스에서도 cloudflared를 띄우면 **커넥터가 2개인 하나의 터널**이 돼요. 서울이 죽으면 Cloudflare가 자동으로 도쿄 커넥터로 보내고, 화면 배지는 `ap-tokyo-1` 로 바뀌어요. 자세한 건 [tokyo-dr-plan.md](./tokyo-dr-plan.md).
