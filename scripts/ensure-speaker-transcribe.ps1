param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Args
)

$ErrorActionPreference = "Stop"

# 1. Explicit development override
if ($env:SPEAKER_TRANSCRIBE_DEV_ROOT) {
  $devExe = Join-Path $env:SPEAKER_TRANSCRIBE_DEV_ROOT ".venv\Scripts\python.exe"
  if (-not (Test-Path $devExe)) {
    [Console]::Error.WriteLine("SPEAKER_TRANSCRIBE_DEV_ROOT is set but .venv\Scripts\python.exe is missing: $devExe. Run: cd `"$env:SPEAKER_TRANSCRIBE_DEV_ROOT`"; uv sync --extra dev --extra full")
    exit 1
  }
  & $devExe -m speaker_transcribe @Args
  exit $LASTEXITCODE
}

function Invoke-InstalledSpeakerTranscribe {
  $cmd = Get-Command speaker-transcribe -ErrorAction SilentlyContinue
  if ($cmd) {
    & $cmd.Source @Args
    exit $LASTEXITCODE
  }
  [Console]::Error.WriteLine("speaker-transcribe was installed but is not on PATH. For uv check: uv tool dir --bin. For pipx run: pipx ensurepath.")
  exit 1
}

# 2. Already on PATH
$existing = Get-Command speaker-transcribe -ErrorAction SilentlyContinue
if ($existing) {
  & $existing.Source @Args
  exit $LASTEXITCODE
}

# 3. Bootstrap with uv
if (Get-Command uv -ErrorAction SilentlyContinue) {
  uv tool install "speaker-transcribe[full]"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
  Invoke-InstalledSpeakerTranscribe @Args
}

# 4. Bootstrap with pipx
if (Get-Command pipx -ErrorAction SilentlyContinue) {
  pipx install "speaker-transcribe[full]"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
  Invoke-InstalledSpeakerTranscribe @Args
}

throw "speaker-transcribe is not installed and neither uv nor pipx is available"
