# syntax=docker/dockerfile:1.7

FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_INPUT=1 \
    VENV=/opt/venv \
    FIZGIG_APP=/opt/Fizgig \
    FIZGIG_STATE=/workspace/Fizgig \
    DISPLAY=:0 \
    VNC_PORT=5900 \
    NOVNC_PORT=5090 \
    SCREEN_WIDTH=1920 \
    SCREEN_HEIGHT=1080 \
    SCREEN_DEPTH=24

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
      python3.12 python3.12-venv python3.12-dev python3-tk \
      git git-lfs curl ca-certificates jq \
      build-essential gcc g++ cmake ninja-build pkg-config \
      ffmpeg aria2 rsync tmux unzip wget vim less nano \
      libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
      libgomp1 libegl1 libopengl0 \
      openssh-server \
      xvfb x11vnc novnc websockify dbus-x11 xauth \
      mesa-utils libgl1-mesa-dri \
      xfce4-panel xfce4-session xfce4-settings xfce4-terminal \
      xfce4-appfinder xfwm4 thunar thunar-archive-plugin \
      xfdesktop4 xfce4-taskmanager tango-icon-theme \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd /var/run/sshd /workspace /workspace/logs \
    && git lfs install --system \
    && python3.12 -m venv "${VENV}"

ENV PATH="${VENV}/bin:${PATH}"

RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --upgrade "pip<25.2" "setuptools<82" wheel

ARG FIZGIG_REPO=https://github.com/shootthesound/Fizgig.git
ARG FIZGIG_REF=master

RUN git clone "${FIZGIG_REPO}" "${FIZGIG_APP}" \
    && git -C "${FIZGIG_APP}" checkout "${FIZGIG_REF}" \
    && python -m pip install --no-cache-dir -r "${FIZGIG_APP}/requirements.txt"

COPY src/start.sh /usr/local/bin/start-fizgig-container
COPY src/launch-fizgig.sh /usr/local/bin/launch-fizgig
COPY src/update-fizgig.sh /usr/local/bin/update-fizgig
COPY desktop/Fizgig.desktop /usr/share/applications/Fizgig.desktop

RUN chmod +x \
      /usr/local/bin/start-fizgig-container \
      /usr/local/bin/launch-fizgig \
      /usr/local/bin/update-fizgig \
    && mkdir -p /root/Desktop \
    && cp /usr/share/applications/Fizgig.desktop /root/Desktop/Fizgig.desktop \
    && chmod +x /root/Desktop/Fizgig.desktop

WORKDIR /workspace

EXPOSE 22 5090 5900

ENTRYPOINT ["/usr/local/bin/start-fizgig-container"]
