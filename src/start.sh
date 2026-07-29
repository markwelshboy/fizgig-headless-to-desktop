#!/usr/bin/env bash
set -euo pipefail

mkdir -p /workspace/logs /root/.vnc /root/Desktop

if [[ -n "${PUBLIC_KEY:-}" ]]; then
  install -d -m 0700 /root/.ssh
  printf '%s\n' "${PUBLIC_KEY}" > /root/.ssh/authorized_keys
  chmod 0600 /root/.ssh/authorized_keys
fi

if [[ -n "${SSH_PASSWORD:-}" ]]; then
  echo "root:${SSH_PASSWORD}" | chpasswd
fi

sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
/usr/sbin/sshd

rm -f /tmp/.X0-lock /tmp/.X11-unix/X0
Xvfb "${DISPLAY}" -screen 0 "${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH}" -ac +extension GLX +render -noreset \
  >>/workspace/logs/xvfb.log 2>&1 &

for _ in $(seq 1 50); do
  xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1 && break
  sleep 0.1
done

export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 0700 "${XDG_RUNTIME_DIR}"

dbus-launch --exit-with-session startxfce4 >>/workspace/logs/xfce.log 2>&1 &

x11vnc -display "${DISPLAY}" -forever -shared -rfbport "${VNC_PORT}" -nopw \
  >>/workspace/logs/x11vnc.log 2>&1 &

websockify --web=/usr/share/novnc/ "${NOVNC_PORT}" localhost:"${VNC_PORT}" \
  >>/workspace/logs/novnc.log 2>&1 &

if [[ "${LAUNCH_FIZGIG:-true}" == "true" ]]; then
  sleep 2
  /usr/local/bin/launch-fizgig >>/workspace/logs/fizgig.log 2>&1 &
fi

echo "Fizgig desktop is ready: noVNC=${NOVNC_PORT}, VNC=${VNC_PORT}, SSH=22"
exec tail -F /workspace/logs/fizgig.log /workspace/logs/xfce.log
