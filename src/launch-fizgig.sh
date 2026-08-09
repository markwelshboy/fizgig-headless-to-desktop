#!/usr/bin/env bash
set -euo pipefail

APP="${FIZGIG_APP:-/opt/Fizgig}"
STATE="${FIZGIG_STATE:-/workspace/Fizgig}"

mkdir -p "${STATE}"/{dataset,cache,output_loras,profiles}

for name in dataset cache output_loras profiles; do
  if [[ -e "${APP}/${name}" && ! -L "${APP}/${name}" ]]; then
    if [[ -n "$(find "${APP}/${name}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
      cp -an "${APP}/${name}/." "${STATE}/${name}/" || true
    fi
    rm -rf "${APP:?}/${name}"
  fi
  ln -sfn "${STATE}/${name}" "${APP}/${name}"
done

cd "${APP}"
export DISPLAY="${DISPLAY:-:0}"
exec python launch.pyw
