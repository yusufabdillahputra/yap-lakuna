# Caddy dengan modul batas laju (rate limit) untuk endpoint aktivasi,
# kode pasang, dan login (F2-01 tahap 5).
FROM caddy:2.10-builder AS builder
RUN xcaddy build --with github.com/mholt/caddy-ratelimit

FROM caddy:2.10
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
