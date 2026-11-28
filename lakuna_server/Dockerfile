# Image server Lakuna (F2-01 tahap 5). Bangun dari akar repo:
#   docker build -f lakuna_server/Dockerfile .
# Paket deploy VPS memakai image ini lewat lakuna_server/deploy/.

# Tahap build
FROM dart:3.13.7 AS build

# Workspace kecil: hanya server dan paket yang dipakainya. Dependensi dev
# server (klien, lakuna_data, tes) dibuang agar tidak menarik Flutter;
# versi lain tetap mengikuti pubspec.lock repo.
WORKDIR /app
COPY pubspec.lock .
COPY packages/lakuna_domain packages/lakuna_domain
COPY lakuna_server lakuna_server
RUN printf '%s\n' \
  'name: _' \
  'publish_to: none' \
  'environment:' \
  '  sdk: ^3.13.0' \
  'workspace:' \
  '  - lakuna_server' \
  '  - packages/lakuna_domain' \
  > pubspec.yaml \
  && sed -i '/^dev_dependencies:/,$d' lakuna_server/pubspec.yaml \
  && sed -i '/^dev_dependencies:/,$d' packages/lakuna_domain/pubspec.yaml \
  && rm -rf lakuna_server/test lakuna_server/.dart_tool lakuna_server/build \
  && dart pub get

# Server dan CLI admin (kode aktivasi) dikompilasi.
WORKDIR /app/lakuna_server
RUN dart build cli --target bin/main.dart --output build/server \
  && dart build cli --target bin/admin.dart --output build/admin \
  && mv build/server/bundle/bin/main build/server/bundle/bin/server \
  && cp build/admin/bundle/bin/admin build/server/bundle/bin/admin \
  && mkdir -p config web migrations

# Tahap akhir
FROM alpine:3.22
WORKDIR /app

ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

LABEL org.opencontainers.image.source="https://github.com/yusufabdillahputra/yap-lakuna"
LABEL org.opencontainers.image.description="Server sync Lakuna (Serverpod)"
LABEL org.opencontainers.image.licenses="NOASSERTION"

COPY --from=build /runtime/ /
COPY --from=build /app/lakuna_server/build/server/bundle/ ./
COPY --from=build /app/lakuna_server/config/ config/
COPY --from=build /app/lakuna_server/web/ web/
COPY --from=build /app/lakuna_server/migrations/ migrations/
COPY --from=build /app/lakuna_server/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

# 8080 API (lewat Caddy). Insights 8081 dan web 8082 tidak dibuka keluar.
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/readyz || exit 1

ENTRYPOINT ["/bin/sh", "-c", "exec ./bin/server --mode=$runmode --server-id=$serverid --logging=$logging --role=$role --apply-migrations"]
