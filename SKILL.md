# speaker-transcribe skill

Use this skill when the user wants speaker-attributed transcription from a local media file or YouTube URL.

## Capabilities

- Transcribe local audio/video files with per-speaker attribution
- Download and transcribe YouTube videos
- Support multiple whisper backends (OpenAI Whisper, WhisperX, OpenVINO)
- Speaker diarization via pyannote

## Operational rules

- Invoke `scripts/ensure-speaker-transcribe.sh` on Unix-like systems or `scripts\ensure-speaker-transcribe.ps1` on Windows to ensure the CLI is available
- Do not invent package-manager commands in the prompt — the launcher handles installation automatically
- If the user is actively developing `speaker-transcribe`, they may point `SPEAKER_TRANSCRIBE_DEV_ROOT` at a source checkout
- Pass CLI arguments directly to the launcher script; it forwards them to `speaker-transcribe`

## Example usage

```bash
# Transcribe a local file
scripts/ensure-speaker-transcribe.sh transcribe recording.wav

# Transcribe a YouTube URL
scripts/ensure-speaker-transcribe.sh transcribe "https://www.youtube.com/watch?v=..."

# Check installation and environment
scripts/ensure-speaker-transcribe.sh check --json

# Run interactive setup
scripts/ensure-speaker-transcribe.sh setup
```
