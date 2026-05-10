# skill-speaker-transcribe

A companion skill that bootstraps and launches the [`speaker-transcribe`](https://github.com/xplrr/speaker-transcribe) CLI for speaker-attributed transcription.

## Normal use

The launcher wrapper resolves `speaker-transcribe` using this priority order:

1. **Development override** — if `SPEAKER_TRANSCRIBE_DEV_ROOT` is set and points to a source checkout with a `.venv`, runs from there
2. **Existing install** — if `speaker-transcribe` is already on `PATH`, uses it directly
3. **Bootstrap with uv** — if `uv` is available, runs `uv tool install "speaker-transcribe[full]"` then launches
4. **Bootstrap with pipx** — if `pipx` is available, runs `pipx install "speaker-transcribe[full]"` then launches
5. **Fail loudly** — prints a clear error message with instructions

## Development override

Set `SPEAKER_TRANSCRIBE_DEV_ROOT` to a local `speaker-transcribe` checkout that has already been prepared with `uv sync`:

```bash
export SPEAKER_TRANSCRIBE_DEV_ROOT="$HOME/projects/speaker-transcribe"
```

```powershell
$env:SPEAKER_TRANSCRIBE_DEV_ROOT = "$env:USERPROFILE\Projects\speaker-transcribe"
```

The wrapper will use the checkout's `.venv` Python to run the CLI module directly, bypassing any installed version.

## Prerequisites

- Python 3.10+
- `uv` (preferred) or `pipx` for automatic bootstrap
- `ffmpeg` must be installed separately at the OS level

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition for agent consumption |
| `scripts/ensure-speaker-transcribe.sh` | Unix launcher/bootstrap wrapper |
| `scripts/ensure-speaker-transcribe.ps1` | Windows launcher/bootstrap wrapper |
| `tool-manifest.json` | Launcher and bootstrap metadata |

## License

MIT
