#!/usr/bin/env sh
set -eu

# 1. Explicit development override
if [ -n "${SPEAKER_TRANSCRIBE_DEV_ROOT:-}" ]; then
  dev_python="${SPEAKER_TRANSCRIBE_DEV_ROOT}/.venv/bin/python"
  if [ ! -x "$dev_python" ]; then
    echo "SPEAKER_TRANSCRIBE_DEV_ROOT is set but .venv/bin/python is missing or not executable: $dev_python" >&2
    echo "Run: cd \"$SPEAKER_TRANSCRIBE_DEV_ROOT\" && uv sync --extra dev --extra full" >&2
    exit 1
  fi
  exec "$dev_python" -m speaker_transcribe "$@"
fi

run_installed() {
  if command -v speaker-transcribe >/dev/null 2>&1; then
    exec speaker-transcribe "$@"
  fi
  echo "speaker-transcribe was installed but is not on PATH." >&2
  if command -v uv >/dev/null 2>&1; then
    echo "Check uv tool bin directory with: uv tool dir --bin" >&2
  fi
  if command -v pipx >/dev/null 2>&1; then
    echo "If using pipx, run: pipx ensurepath" >&2
  fi
  exit 1
}

# 2. Already on PATH
if command -v speaker-transcribe >/dev/null 2>&1; then
  exec speaker-transcribe "$@"
fi

# 3. Bootstrap with uv
if command -v uv >/dev/null 2>&1; then
  uv tool install "speaker-transcribe[full]"
  run_installed "$@"
fi

# 4. Bootstrap with pipx
if command -v pipx >/dev/null 2>&1; then
  pipx install "speaker-transcribe[full]"
  run_installed "$@"
fi

echo "speaker-transcribe is not installed and neither uv nor pipx is available" >&2
exit 1
