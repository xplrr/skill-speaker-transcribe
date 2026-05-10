---
name: speaker-transcribe
description: Use when the user wants speaker-attributed transcription from a local media file or YouTube URL, or needs to set up, check, or manage the speaker-transcribe CLI tool
---

# speaker-transcribe

Bootstraps and invokes the `speaker-transcribe` CLI for speaker-attributed transcription. The launcher scripts auto-install the tool if missing, then forward all arguments.

## When to use

- User wants to transcribe audio/video with speaker attribution
- User wants to transcribe a YouTube video (with optional time clipping)
- User needs to set up the environment (models, HF token, storage)
- User wants to check environment readiness
- User wants to resume a partial transcription run
- User wants to manage models or storage profiles

## Operational rules

1. Always use the launcher script — do not run pip/uv/pipx directly
2. On Unix: `<skill-dir>/scripts/ensure-speaker-transcribe.sh <args>`
3. On Windows: `<skill-dir>\scripts\ensure-speaker-transcribe.ps1 <args>`
4. If the user has `SPEAKER_TRANSCRIBE_DEV_ROOT` set, the launcher uses that checkout directly
5. Always pass `--json` for machine-readable output when parsing results programmatically

## Commands reference

### run — Transcribe a source

```sh
<skill-dir>/scripts/ensure-speaker-transcribe.sh run "<source>" [--start MM:SS] [--stop MM:SS] [--transcript-backend <backend>] [--model <tier>] [--device <device>] [--run-root <path>] [--json]
```

| Flag | Values | Purpose |
|------|--------|---------|
| `--transcript-backend` | `auto`, `whisper_fallback`, `openvino_whisper` | Force a specific transcription backend |
| `--model` | `large`, `turbo` | Model tier (large = highest quality, turbo = fastest) |
| `--device` | `auto`, `cpu`, `gpu`, `npu` | Target inference device |
| `--start` | Time offset (e.g. `00:15`, `90:00`) | Clip start |
| `--stop` | Time offset | Clip end |
| `--run-root` | Directory path | Custom output directory root |
| `--json` | — | Machine-readable JSON progress output |

Example — transcribe YouTube clip with GPU acceleration:
```sh
<skill-dir>/scripts/ensure-speaker-transcribe.sh run "https://youtube.com/watch?v=abc" --start 00:15 --stop 01:00 --device gpu --json
```

Example — transcribe local file with CPU fallback:
```sh
<skill-dir>/scripts/ensure-speaker-transcribe.sh run recording.wav --transcript-backend whisper_fallback --json
```

### check — Diagnose environment

```sh
<skill-dir>/scripts/ensure-speaker-transcribe.sh check --json
```

Returns JSON with fields:
- `ffmpeg.available` — whether ffmpeg is installed
- `transcription.ready` — whether a transcription model is available
- `diarization.ready` — whether speaker attribution is configured
- `diarization.reason` — if not ready: `hf_token_missing`, `pyannote_not_installed`, etc.
- `models.openvino.recommended_model` — best available model for this hardware
- `storage.profile` — current storage profile (`user` or `repo-local`)

### setup — Configure the environment

```sh
<skill-dir>/scripts/ensure-speaker-transcribe.sh setup [--profile <profile>] [--hf-token <token>] [--storage-profile <profile>] [--app-root <path>] [--json]
```

`setup` saves configuration, creates storage directories, records the HF token when provided, and reports readiness. It does not download all model assets. Use `models download --recommended --json` after setup.

| Flag | Purpose |
|------|---------|
| `--profile` | Setup profile to persist for later readiness/model workflows |
| `--storage-profile` | `user` (shared) or `repo-local` (per-project) |
| `--hf-token` | Provide HF token non-interactively |
| `--app-root` | Override the resolved application storage root |
| `--json` | Machine-readable output |

### resume — Continue a partial run

```sh
<skill-dir>/scripts/ensure-speaker-transcribe.sh resume <run-dir> [--json]
```

Use when a prior `run` completed as partial (e.g. missing HF token prevented speaker attribution). Fix the prerequisite first (e.g. run `setup`), then resume.

### diarize — Add speakers to existing transcript

```sh
<skill-dir>/scripts/ensure-speaker-transcribe.sh diarize <source-audio> --transcript <transcript-json> [--expected-speakers n] [--json]
```

Use this when the run already has transcript segments and you need to run speaker attribution against the source audio.

### models — Manage models

```sh
<skill-dir>/scripts/ensure-speaker-transcribe.sh models list [--json]
<skill-dir>/scripts/ensure-speaker-transcribe.sh models download --recommended --json
<skill-dir>/scripts/ensure-speaker-transcribe.sh models download <logical-name> --json
<skill-dir>/scripts/ensure-speaker-transcribe.sh models verify --json
<skill-dir>/scripts/ensure-speaker-transcribe.sh models path
```

Logical model names include `openvino-whisper-large-v3`, `openvino-whisper-medium`, `openvino-whisper-turbo`, `whisper-large-v3`, `whisper-turbo`, and `pyannote-speaker-diarization-3.1`.

### storage — Manage storage profile

```sh
<skill-dir>/scripts/ensure-speaker-transcribe.sh storage show
<skill-dir>/scripts/ensure-speaker-transcribe.sh storage use <profile>
```

Profiles: `user` (OS app data dir, shared) or `repo-local` (`.speaker-transcribe/` in git root, isolated).

### config — View/edit configuration

```sh
<skill-dir>/scripts/ensure-speaker-transcribe.sh config get <key>
<skill-dir>/scripts/ensure-speaker-transcribe.sh config set <key> <value>
<skill-dir>/scripts/ensure-speaker-transcribe.sh config path
```

Keys: `storage_profile`, `default_device`, `hf_token`, `models_dir`

## Hugging Face token setup flow

If `check --json` shows `diarization.ready: false` with reason `hf_token_missing`:

1. Tell user they need a Hugging Face account for speaker attribution
2. Direct them to accept model licenses:
   - https://huggingface.co/pyannote/speaker-diarization-3.1
   - https://huggingface.co/pyannote/segmentation-3.0
3. Direct them to create a token: https://huggingface.co/settings/tokens (read access sufficient)
4. Run: `<skill-dir>/scripts/ensure-speaker-transcribe.sh setup --hf-token <their-token> --json`
5. Verify with: `<skill-dir>/scripts/ensure-speaker-transcribe.sh check --json` — `diarization.ready` should be `true`

## Output artifacts

A completed run creates a directory with ordered files:

| File | Content |
|------|---------|
| `01_run-metadata.json` | Source info, timestamps, settings used |
| `02_transcript-segments.json` | Raw transcript segments with timestamps |
| `03_source-audio.*` | Saved local audio artifact for resume/backend work when available |
| `04_transcript-document.json` | Canonical document with speaker labels |
| `05_transcript-markdown.md` | Human-readable speaker-attributed transcript |
| `06_run-manifest.json` | Final status, paths to all artifacts |

The markdown transcript path is the primary user-facing output.

## Interpreting partial vs complete

- **Complete:** All artifacts present including `04_transcript-document.json` and `05_transcript-markdown.md` with speaker labels
- **Partial:** Run stopped before speaker attribution. Has `02_transcript-segments.json` but missing speaker-labeled outputs. Resume after fixing prerequisites.
