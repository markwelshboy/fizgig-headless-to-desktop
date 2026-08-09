#!/usr/bin/env bash
set -euo pipefail

APP="${FIZGIG_APP:-/opt/Fizgig}"
REF="${FIZGIG_REF:-master}"

if [[ ! -d "${APP}/.git" ]]; then
  echo "ERROR: ${APP} is not a Git checkout." >&2
  exit 1
fi

if [[ -n "$(git -C "${APP}" status --porcelain)" ]]; then
  echo "ERROR: ${APP} has local changes; refusing to overwrite them." >&2
  git -C "${APP}" status --short
  exit 1
fi

git -C "${APP}" fetch origin
git -C "${APP}" checkout "${REF}"
git -C "${APP}" pull --ff-only origin "${REF}"
python -m pip install --no-cache-dir -r "${APP}/requirements.txt"

echo "Fizgig updated to $(git -C "${APP}" rev-parse --short HEAD)."
