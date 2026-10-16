# verify_infra — Verifi 인프라

Oracle TELOS Challenge 2026 · 팀 Verifi. 애플리케이션 코드는 [verify_app](https://github.com/hacksungboo/verify_app).

```
verify_infra/
├── app-server/            # 앱 서버(team-4-1): frontend · backend · db-tunnel · cloudflared
│   ├── docker-compose.yml
│   ├── .env.example
│   └── keys/              # DB 서버 SSH 키 넣는 곳 (커밋 안 됨)
├── db-server/             # DB 서버(team-4-2): Oracle Database 23ai Free
│   ├── docker-compose.yml
│   ├── .env.example
│   └── init/              # 첫 기동 시 실행되는 SQL
├── scripts/
│   ├── install-docker.sh  # Oracle Linux에 Docker 설치
│   ├── deploy.sh          # 최신 이미지로 갱신
│   └── check.sh           # 시연 전 점검
└── docs/
    ├── deploy-guide.md     # ★ 처음 배포할 때 이것만 따라 하면 됨
    ├── cloudflare-tunnel.md
    └── tokyo-dr-plan.md
```

## 빠른 시작

1. 두 서버에 Docker 설치 → `scripts/install-docker.sh`
2. DB 서버: `db-server/` 에서 `.env` 작성 → `docker compose up -d`
3. Cloudflare 터널 생성 → 토큰 복사 ([docs/cloudflare-tunnel.md](docs/cloudflare-tunnel.md))
4. 앱 서버: `app-server/` 에서 `.env` 작성, `keys/db.key` 복사 → `../scripts/deploy.sh`
5. `https://verifi.ccmall.shop`

자세한 순서와 문제 해결은 **[docs/deploy-guide.md](docs/deploy-guide.md)**.

## 서버

| 역할 | 이름 | 공인 IP | 여는 포트 |
|---|---|---|---|
| 앱 서버 | team-4-1 | 146.56.139.138 | 없음 (터널) |
| DB 서버 | team-4-2 | 131.186.25.47 | 없음 (SSH 터널, 1521은 127.0.0.1만) |

## 비밀값 규칙

- `.env`, `*.key` 는 커밋하지 않아요 (`.gitignore` 처리됨)
- OpenAI 키, 터널 토큰, DB 비밀번호는 서버의 `.env` 에만
