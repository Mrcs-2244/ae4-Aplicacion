#!/usr/bin/env bash
# deploy.sh — reconstruye y verifica el despliegue (curso DPL, UT4 - AE4)
set -euo pipefail

PUERTO="${PUERTO:-8000}"
BASE="http://localhost:${PUERTO}"

cd "$(dirname "$0")"

mkdir -p data

echo "[1/3] Construyendo imagenes..."
docker compose build

echo "[2/3] Arrancando servicios..."
docker compose up -d

echo "[3/3] Esperando a que la aplicacion este sana en ${BASE}/healthz..."
INTENTOS=0
while [ "${INTENTOS}" -lt 30 ]; do
    if curl -sf "${BASE}/healthz" > /dev/null; then
        echo "Despliegue OK: ${BASE}/healthz responde 200 tras $((INTENTOS + 1)) intento(s)."
        docker compose ps
        exit 0
    fi
    INTENTOS=$((INTENTOS + 1))
    sleep 2
done

echo "ERROR: la aplicacion no respondio en 60 s" >&2
docker compose ps >&2
docker compose logs --tail=20 >&2
exit 1
