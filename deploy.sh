#!/usr/bin/env zsh

addon='DevSuite'

# options: boolean
dryRun=false
verbose=false
quiet=false

# ----------- Don't modify below this line -----------
script_path="${0:A}"
script_name=${0:t}

# rsync_bin="$(brew --prefix rsync)/bin/rsync"
rsync_bin=rsync

# @see SHELL/wow-dev.sh for ENV VARS

excludeFile="./dev/rsync-excludes.txt"

deployTargets=(
  # "${WOW_CLASSIC_ANNIV_DEPLOY}/${addon}"
  "${WOW_CLASSIC_ERA_DEPLOY}/${addon}"
  # "${WOW_CLASSIC_DEPLOY}/${addon}"  # MoP
  # "${WOW_RETAIL_DEPLOY}/${addon}"
)

tstamp() { printf "%s.%03d\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$(( $(gdate +%N) / 1000000 ))"; }
log() { echo "[$(tstamp)] $*"; }
log_err() { echo "[$(tstamp)] $*" >&2; }

if [[ ! -f "$excludeFile" ]]; then
  log_err "Error: exclude file not found: $excludeFile"
  exit 1
fi

function show_targets() {
  echo "Deploy targets:"
  for tgt in "${deployTargets[@]}"; do
    echo " • ${tgt}"
  done
}

function _Main() {
  src=.
  local baseDeployDir
  local rsyncShortArgs=
  local rsyncFlags=()

  for dest in "${deployTargets[@]}"; do
    baseDeployDir=$(basename "$dest")
    
    rsyncFlags=(--delete --prune-empty-dirs)
    rsyncFlags+=("--out-format= • %n => ${dest}/%n")

    if [[ ! -d "${dest}" ]]; then 
      mkdir -p "$dest" || {
        echo "Error: Failed to create target: ${dest}" >&2
        exit 1 
      }
    fi
    if [[ "$baseDeployDir" != "$addon" ]]; then
      echo "Error: Target must be addon directory '${addon}', got: ${baseDeployDir} (${dest})" >&2
      exit 1
    fi

    [[ ${verbose} == "true" ]] && rsyncShortArgs="${rsyncShortArgs}v"
    cmd=("$rsync_bin" -rt"${rsyncShortArgs}" "${rsyncFlags[@]}" --exclude-from="$excludeFile" "$src/" "$dest/")
    [[ ${dryRun} == "true" ]] && cmd+=(--dry-run)

    if [[ ! ${quiet} == "true" ]]; then
      printf '[%s] Executing:' "$(tstamp)"
      printf ' %q' "${cmd[@]}"
      echo
    else
      printf '[%s] Deploying: [%s]\n' "$(tstamp)" "${dest}"
    fi

    "${cmd[@]}"
    if [[ ! ${quiet} == "true" ]]; then
      printf '[%s] Deploy complete: [%s]\n' "$(tstamp)" "${dest}"
    fi
    echo "-------------------------"
    
  done

}

function _Watch() {
  local passArgs=()
  [[ "${quiet}" == "true" ]] && passArgs+=("-q")

  log "Running in watch mode: ./${script_name}" "${passArgs[@]}"

  fswatch -I -o -l 0.2 \
    -e '.*' \
    -i '\.toc$' \
    -i '\.lua$' \
    -i '\.xml$' \
    -e '.*/\.git/.*' -e '.*/\.vscode/.*' \
    -e '.*\.swp$' -e '.*~$' -e '.*\.log$' \
    . | xargs -n1 -I{} "$script_path" "${passArgs[@]}"
}

# --- arg parsing ---
mode="run"

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      echo "[usage] ./${script_name} [options]"
      echo "options: no args          => deploys this addon into its target destinations"
      echo "         -w|--watch       => runs this script in watch mode"
      echo "         -t|--target.     => shows the deploy targets"
      echo "         -v|--verbose     => verbose rsync"
      echo "         -d|--dry-run     => verbose rsync"
      echo "         -h --help        => shows this help"
      exit 0
      ;;
    -v)
      verbose=true
      ;;
    -d|--dry-run)
      dryRun=true
      ;;
    -t|--targets)
      show_targets
      exit 0
      ;;
    -q|--quiet)
      quiet=true
      ;;
    -w|--watch)
      mode="watch"
      ;;
  esac
done

# --- execution ---
if [[ "$mode" == "watch" ]]; then
  _Main "$@" && _Watch
else
  _Main "$@"
fi

