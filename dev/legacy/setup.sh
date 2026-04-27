#!/usr/bin/env zsh

BUILD_DIR=./.release
RELEASE_SCRIPT=./dev/release.sh
TOC_FILE="setup.toc"
PKGMETA_FILE="setup.yml"

p() {
  printf "%-9s: %-40s\n" "$1" "$2"
}
ensure_dir() {
  local dir="$1"

  if [[ ! -d "$dir" ]]; then
    p "Executing" "mkdir -p $dir"
    mkdir -p "$dir"
  fi
}
ensure_file() {
  local file="$1"
  [[ -f "$file" ]] && return 0
  return "$?"
}

# Options:
# -d  Skip uploading.
# -u  Use Unix line-endings.
# -z  Skip zip file creation.
# -r  releasedir    Set directory containing the package directory. Defaults to "$topdir/.release".
# -m  pkgmeta.yaml  Set the pkgmeta file to use.
_Release() {
    local pkgmeta_path="./dev/${PKGMETA_FILE}"

    ensure_dir "$BUILD_DIR"
    cp "${pkgmeta_path}" "_${PKGMETA_FILE}" || {
      echo "Missing: ${pkgmeta_path}"
      return 1
    }
    ensure_file "./_${PKGMETA_FILE}" || {
      p "Missing: $file"
      return 1
    }
    cp ./dev/${TOC_FILE} _${TOC_FILE}

    local args="-duz -r ${BUILD_DIR} -m _${PKGMETA_FILE}"
    local cmd="${RELEASE_SCRIPT} ${args}"
    echo "Executing: ${cmd}"
    (eval "${cmd}" && echo "Execution Complete: ${cmd}") || {
      echo "Run failed."
      return 1
    }
    echo "Cleaning up..." && {
      rm _${PKGMETA_FILE}
      rm _${TOC_FILE}
    }
}

_Release
