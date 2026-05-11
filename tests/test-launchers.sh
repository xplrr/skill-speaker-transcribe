#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

if SPEAKER_TRANSCRIBE_DEV_ROOT="$tmp/no-venv" "$repo/scripts/ensure-speaker-transcribe.sh" check --json 2>"$tmp/err"; then
  echo "expected invalid dev root to fail" >&2
  exit 1
fi

grep -q "SPEAKER_TRANSCRIBE_DEV_ROOT" "$tmp/err"
grep -q "uv sync --extra dev --extra full" "$tmp/err"
