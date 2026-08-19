# Local LLM Agent Stack for Windows + WSL2

Components:
- Ollama
- GPT-OSS 20B
- Qwen3 14B
- nomic-embed-text
- Open WebUI
- Open Terminal
- SearXNG

## Recommended environment

Windows 11 + Docker Desktop + WSL2 backend + NVIDIA RTX 5070 Ti 16GB.

## 1. Prerequisites

Install Docker Desktop for Windows. In Docker Desktop:
Settings -> General -> Use WSL 2 based engine
Settings -> Resources -> WSL Integration -> enable your Ubuntu distro.

From WSL Ubuntu, verify:

```bash
docker version
docker compose version
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi
```

If the NVIDIA test fails, fix Docker Desktop/WSL GPU integration before continuing.

## 2. Install

In WSL Ubuntu:

```bash
cd /path/to/llm-agent-stack
chmod +x setup.sh
./setup.sh
```

The script starts all containers and pulls GPT-OSS 20B, Qwen3 14B and nomic-embed-text.

## 3. URLs

- Open WebUI: http://localhost:3000
- SearXNG: http://localhost:8080
- Open Terminal API docs: http://localhost:8000/docs
- Ollama API: http://localhost:11434

## 4. Open WebUI first-time setup

Open http://localhost:3000 and create the administrator account.

Models should appear automatically because Open WebUI connects to the Ollama container at `http://ollama:11434`.

Enable Web Search in:
Admin Settings -> Web Search.

SearXNG is already configured with JSON search output and the internal URL:
`http://searxng:8080/search?q=<query>`

## 5. Open Terminal

The compose file starts Open Terminal in an isolated container.

In Open WebUI, configure the Open Terminal connection using:
- Server: `http://open-terminal:8000`
- API key: value of `OPEN_TERMINAL_API_KEY` in `.env`

Do not mount your Windows home directory into Open Terminal. Create a dedicated working area instead.

## 6. PDF / Word / PPT

For ordinary document Q&A, upload PDF/DOCX/PPTX directly into Open WebUI and use Knowledge/RAG.

For programmatic analysis, use Open Terminal. The terminal container is isolated from the host unless you explicitly add mounts.

## 7. MCP

Open WebUI supports MCP. Add Streamable HTTP MCP servers under:
Admin Settings -> Tools / External Tools.

Start with only a few tools. Do not expose a large number of tools to a small local model.

## 8. Useful commands

```bash
docker compose ps
docker compose logs -f open-webui
docker compose logs -f ollama
docker compose logs -f searxng
docker compose logs -f open-terminal

docker compose restart
docker compose down
docker compose up -d

docker compose exec ollama ollama list
docker compose exec ollama ollama run gpt-oss:20b
```

## 9. Update

```bash
docker compose pull
docker compose up -d
```

For a major Open WebUI upgrade, back up the `open-webui` volume first.

## 10. Storage

Model files can consume tens of GB. Docker Desktop's disk image must have enough free space.

The compose stack uses named volumes:
- ollama
- open-webui
- open-terminal
- searxng-cache

## 11. Security

This is a local development stack. Do not expose ports 3000, 8000, 8080 or 11434 directly to the public Internet.

Open Terminal can execute commands inside its container. Treat it as an agent execution environment and keep host files isolated.

## 12. Optional Nemotron

If you want to test the small local Nemotron model:

```bash
docker compose exec ollama ollama pull nemotron-3-nano:4b
```

For a cloud Nemotron model, configure Ollama Cloud separately rather than trying to fit the large Super/Ultra local models into 16GB VRAM.
