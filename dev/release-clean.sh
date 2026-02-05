#!/usr/bin/env bash
rel_dir="./.release"

_Main() {
  # clean release with no zip
  if [[ -d "${rel_dir}" ]]; then
    rm -rf "${rel_dir}"
  fi

  if [[ -d "${rel_dir}" ]]; then
    echo "Failed to remove release dir"
    _ls_out=$(ls -ld "${rel_dir}" 2>&1)
    echo "  $_ls_out"
    return 1
  fi
  ./dev/release.sh -duz
}

_Main

