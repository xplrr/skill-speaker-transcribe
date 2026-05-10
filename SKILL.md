---
name: speaker-transcribe
description: Use when the user wants speaker-attributed transcription from a local media file or YouTube URL, or needs to set up, check, or manage the speaker-transcribe CLI tool
---

# speaker-transcribe

Bootstraps and invokes the `speaker-transcribe` CLI for speaker-attributed transcription. The launcher scripts auto-install the tool if missing, then forward all arguments — no manual install steps needed.

## When to use

- User wants to transcribe audio/video with speaker attribution
- User wants to transcribe a YouTube video
- User needs to set up or check the speaker-transcribe environment
- User wants to resume a partial transcription run

## Operational rules

1. Use the launcher script to ensure the CLI is available — do not run pip/uv/pipx commands directly
2. On Unix: `scripts/ensure-speaker-transcribe.sh <args>`
3. On Windows: `scripts\ensure-speaker-transcribe.ps1 <args>`
4. The launcher auto-installs if needed, then forwards all arguments to `speaker-transcribe`
5. If the user is developing speaker-transcribe locally, they set `SPEAKER_TRANSCRIBE_DEV_ROOT`

## Common commands

| Command | Example |
|---------|---------|
| Transcribe YouTube | `scripts/ensure-speaker-transcribe.sh run "https://youtube.com/watch?v=..."` |
| Transcribe local file | `scripts/ensure-speaker-transcribe.sh run recording.wav` |
| Check environment | `scripts/ensure-speaker-transcribe.sh check --json` |
| Setup | `scripts/ensure-speaker-transcribe.sh setup --json` |
| Resume partial run | `scripts/ensure-speaker-transcribe.sh resume <run-dir>` |
| List models | `scripts/ensure-speaker-transcribe.sh models list --json` |

## Interpreting output

- `check --json` returns a JSON object with `transcription.ready`, `diarization.ready`, and `storage` fields
- If `diarization.ready` is false, speaker attribution won't work — guide the user through HF token setup
- Run artifacts are saved to a directory named after the source; the markdown transcript is at `05_transcript-markdown.md`
