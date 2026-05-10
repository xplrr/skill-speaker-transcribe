#!/usr/bin/env sh
set -eu

# 1. Explicit development override
if [ -n "${SPEAKER_TRANSCRIBE_DEV_ROOT:-}" ] && [ -x "${SPEAKER_TRANSCRIBE_DEV_ROOT}/.venv/bin/python" ]; then
  exec "${SPEAKER_TRANSCRIBE_DEV_ROOT}/.venv/bin/python" -m speaker_transcribe "$@"
fi

# 2. Already on PATH
if command -v speaker-transcribe >/dev/null 2>&1; then
  exec speaker-transcribe "$@"
fi

# 3. Bootstrap with uv
if command -v uv >/dev/null 2>&1; then
  uv tool install "speaker-transcribe[full]"
  exec speaker-transcribe "$@"
fi

# 4. Bootstrap with pipx
if command -v pipx >/dev/null 2>&1; then
  pipx install "speaker-transcribe[full]"
  exec speaker-transcribe "$@"
fi

echo "speaker-transcribe is not installed and neither uv nor pipx is available" >&2
exit 1
