#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "== Local LLM Agent Stack =="
echo "Project: $PROJECT_DIR"

command -v docker >/dev/null 2>&1 || {
  echo "ERROR: Docker is not installed or not in PATH."
  echo "Install Docker Desktop for Windows and enable WSL2 integration."
  exit 1
}

docker compose version >/dev/null 2>&1 || {
  echo "ERROR: Docker Compose is unavailable."
  exit 1
}

if grep -q "CHANGE_ME_TO_A_LONG_RANDOM_SECRET" .env 2>/dev/null; then
  if command -v openssl >/dev/null 2>&1; then
    SECRET="$(openssl rand -hex 32)"
  else
    SECRET="$(date +%s%N)-$(hostname)"
  fi
  sed -i "s/CHANGE_ME_TO_A_LONG_RANDOM_SECRET/$SECRET/" .env
fi

if grep -q "CHANGE_ME_SEARXNG_SECRET" searxng/settings.yml 2>/dev/null; then
  if command -v openssl >/dev/null 2>&1; then
    SECRET="$(openssl rand -hex 32)"
  else
    SECRET="$(date +%s%N)-$(hostname)"
  fi
  sed -i "s/CHANGE_ME_SEARXNG_SECRET/$SECRET/" searxng/settings.yml
fi

echo "[1/5] Pulling images..."
docker compose pull

echo "[2/5] Starting services..."
docker compose up -d

echo "[3/5] Waiting for Ollama..."
for i in {1..30}; do
  if curl -fsS http://localhost:11434/api/tags >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "[4/5] Pulling models..."
docker compose exec -T ollama ollama pull gpt-oss:20b
docker compose exec -T ollama ollama pull qwen3:14b
docker compose exec -T ollama ollama pull nomic-embed-text

echo "[5/5] Status"
docker compose ps

echo
echo "Open WebUI:    http://localhost:3000"
echo "SearXNG:       http://localhost:8080"
echo "Open Terminal: http://localhost:8000/docs"
echo "Ollama API:    http://localhost:11434"
echo
echo "Models:"
docker compose exec -T ollama ollama list
