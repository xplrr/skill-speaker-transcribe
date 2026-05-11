# skill-speaker-transcribe

A companion skill that helps AI coding agents use the [`speaker-transcribe`](https://github.com/xplrr/speaker-transcribe) CLI for speaker-attributed transcription.

- Skill repository: https://github.com/xplrr/skill-speaker-transcribe
- Tool repository: https://github.com/xplrr/speaker-transcribe

## Installation

Register this skill with your agent framework:

- **Claude Code** — symlink or copy to `~/.claude/skills/`
- **Copilot CLI** — place in `.github/extensions/` or the plugin directory
- **General** — clone alongside your project and reference `SKILL.md`

## How it works

The launcher scripts (`<skill-dir>/scripts/ensure-speaker-transcribe.sh` on Unix, `<skill-dir>\scripts\ensure-speaker-transcribe.ps1` on Windows) check for an existing `speaker-transcribe` install, bootstrap it via `uv` or `pipx` if missing, then forward all CLI arguments. No manual install steps are needed — agents just call the launcher.

If `SPEAKER_TRANSCRIBE_DEV_ROOT` is set, it must point to a source checkout with a ready virtual environment:

```bash
cd "$SPEAKER_TRANSCRIBE_DEV_ROOT" && uv sync --extra dev --extra full
```

An invalid dev override now fails fast with setup instructions instead of silently falling back to auto-install.

If bootstrap succeeds but the executable is still missing from `PATH`, the launchers now stop with remediation hints (`uv tool dir --bin` for `uv`, `pipx ensurepath` for `pipx`) instead of failing with a less clear command-not-found error.

See `SKILL.md` for the current command reference, including the `run`, `setup`, `diarize`, and `models download` forms that match the live CLI parser.

## Development override

Point `SPEAKER_TRANSCRIBE_DEV_ROOT` at a local source checkout to bypass the installed version:

```bash
export SPEAKER_TRANSCRIBE_DEV_ROOT="$HOME/projects/speaker-transcribe"
```

```powershell
$env:SPEAKER_TRANSCRIBE_DEV_ROOT = "$env:USERPROFILE\Projects\speaker-transcribe"
```

## Prerequisites

- Python 3.10+
- `uv` (preferred) or `pipx`
- `ffmpeg` and `ffprobe` (OS-level install)

## License

MIT. See [`LICENSE`](LICENSE).
