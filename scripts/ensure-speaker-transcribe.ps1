param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Args
)

$ErrorActionPreference = "Stop"

# 1. Explicit development override
if ($env:SPEAKER_TRANSCRIBE_DEV_ROOT) {
  $devExe = Join-Path $env:SPEAKER_TRANSCRIBE_DEV_ROOT ".venv\Scripts\python.exe"
  if (Test-Path $devExe) {
    & $devExe -m speaker_transcribe @Args
    exit $LASTEXITCODE
  }
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
  & (Get-Command speaker-transcribe).Source @Args
  exit $LASTEXITCODE
}

# 4. Bootstrap with pipx
if (Get-Command pipx -ErrorAction SilentlyContinue) {
  pipx install "speaker-transcribe[full]"
  & (Get-Command speaker-transcribe).Source @Args
  exit $LASTEXITCODE
}

throw "speaker-transcribe is not installed and neither uv nor pipx is available"
