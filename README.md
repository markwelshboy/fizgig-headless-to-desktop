# Fizgig Headless-to-Desktop

CUDA 12.8 container image for running [Fizgig](https://github.com/shootthesound/Fizgig) in a persistent XFCE desktop through noVNC, with optional SSH access.

## Included

- NVIDIA CUDA 12.8.1 and cuDNN development runtime
- Python 3.12 virtual environment at `/opt/venv`
- Fizgig installed at `/opt/Fizgig`
- XFCE desktop on Xvfb
- noVNC on port `5090`
- direct VNC on port `5900`
- OpenSSH on port `22`
- persistent Fizgig data under `/workspace/Fizgig`

Fizgig's own `requirements.txt` is installed without importing dependency pins from the ComfyUI desktop image.

## Persistent directories

The launcher links these application directories into `/workspace/Fizgig`:

- `dataset`
- `cache`
- `output_loras`
- `profiles`

Mount `/workspace` as persistent storage on RunPod or another container host.

## Build

```bash
docker build -t fizgig-desktop:latest .
```

Pin Fizgig to a branch, tag, or commit at build time:

```bash
docker build \
  --build-arg FIZGIG_REF=master \
  -t fizgig-desktop:latest .
```

## Run locally

```bash
docker run --rm --gpus all \
  -p 5090:5090 \
  -p 5225:22 \
  -v fizgig-workspace:/workspace \
  -e SSH_PASSWORD='change-me' \
  fizgig-desktop:latest
```

Open `http://localhost:5090/vnc.html` for the desktop. Fizgig starts automatically and is also available from the desktop shortcut.

For key-based SSH, supply the public key as `PUBLIC_KEY` instead of, or in addition to, `SSH_PASSWORD`.

## Environment variables

| Variable | Default | Purpose |
|---|---:|---|
| `LAUNCH_FIZGIG` | `true` | Start Fizgig automatically |
| `NOVNC_PORT` | `5090` | noVNC/websockify port |
| `VNC_PORT` | `5900` | x11vnc port |
| `SCREEN_WIDTH` | `1920` | Virtual desktop width |
| `SCREEN_HEIGHT` | `1080` | Virtual desktop height |
| `SCREEN_DEPTH` | `24` | Virtual desktop color depth |
| `SSH_PASSWORD` | unset | Optional root SSH password |
| `PUBLIC_KEY` | unset | Optional root authorized SSH public key |

## Updating Fizgig inside a running container

```bash
update-fizgig
```

The helper refuses to update if `/opt/Fizgig` contains local changes. Image rebuilds remain the reproducible way to pin a known Fizgig revision.

## RunPod ports

Expose TCP ports `22` and `5090`. Port `5090` is the browser desktop; map port `22` to the provider-assigned public SSH port.
