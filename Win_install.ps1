<#
Install/Remove Pixi + a local project env (JupyterLab + reportlab)
Transcription of the provided bash script behavior.

Usage:
  .\Win_install.ps1            # install (default)
  .\Win_install.ps1 -Remove   # totally remove install (best-effort)

What Remove does:
  - Deletes: ~/Documents/BIO713/TP
  - If pixi was installed by this script (marker exists), deletes: ~/.pixi
    and removes the marker.

Notes:
  - Requires: curl (or Invoke-WebRequest availability), and a working shell.
  - "Reverting original computer state" is best-effort; we only undo what we created.
#>

[CmdletBinding()]
param(
  [switch]$Remove
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-HomeDir {
  if ($env:USERPROFILE) { return $env:USERPROFILE }
  # Fallback
  return (Resolve-Path "~").Path
}

function Ensure-Curl {
  $cmd = Get-Command curl -ErrorAction SilentlyContinue
  if (-not $cmd) {
    Write-Host "Error: curl not found. Please install curl and re-run." -ForegroundColor Red
    exit 1
  }
}

function Install-Pixi {
  if (Get-Command pixi -ErrorAction SilentlyContinue) {
    Write-Host "pixi: already installed."
    return
  }

  Write-Host "Installing pixi..."
  # curl -fsSL https://pixi.sh/install.sh | bash
  # On Windows, we use: curl ... | sh
  # If you don't have 'sh' (Git Bash/WSL), install may fail.
  $installUrl = "https://pixi.sh/install.sh"
  $script = (Invoke-WebRequest -Uri $installUrl -UseBasicParsing).Content

  # Try to run with sh if available; otherwise, fail with a clear message.
  $sh = Get-Command sh -ErrorAction SilentlyContinue
  if (-not $sh) {
    Write-Host "Error: cannot run pixi installer because 'sh' was not found." -ForegroundColor Red
    Write-Host "On Windows, try using Git Bash (which provides 'sh') or WSL, then re-run." -ForegroundColor Yellow
    exit 1
  }

  # Run installer script through sh
  $temp = New-TemporaryFile
  try {
    Set-Content -Path $temp -Value $script -Encoding UTF8
    & $sh.Source $temp | Out-Host
  } finally {
    Remove-Item -Force $temp -ErrorAction SilentlyContinue
  }

  $home = Get-HomeDir
  $markerDir = Join-Path $home ".pixi_remove_marker"
  if (-not (Test-Path $markerDir)) { New-Item -ItemType Directory -Path $markerDir | Out-Null }
  $markerPath = Join-Path $markerDir "marker"
  "" | Out-File -FilePath $markerPath -Encoding ASCII

  $env:Path = "$home\.pixi\bin;$env:Path"
  if (-not (Get-Command pixi -ErrorAction SilentlyContinue)) {
    Write-Host "Error: pixi not found in PATH after installation." -ForegroundColor Red
    Write-Host "Try adding this to your shell profile:" -ForegroundColor Yellow
    Write-Host "  `"$home\.pixi\bin`" to PATH, then re-run."
    exit 1
  }
}

function Cleanup {
  Write-Host "== Remove mode =="

  $home = Get-HomeDir
  $targetDir = Join-Path $home "Documents\BIO713\TP"

  if (Test-Path $targetDir) {
    Write-Host "Deleting project directory: $targetDir"
    Remove-Item -Recurse -Force $targetDir
  } else {
    Write-Host "Project directory not found (skipping): $targetDir"
  }

  # Best-effort remove ~/.pixi only if marker exists
  $markerPath = Join-Path (Join-Path $home ".pixi_remove_marker") "marker"
  if (Test-Path $markerPath) {
    Write-Host "pixi was installed by this script (marker found)."
    $pixiDir = Join-Path $home ".pixi"
    Write-Host "Attempting to remove: $pixiDir"
    if (Test-Path $pixiDir) {
      Remove-Item -Recurse -Force $pixiDir
    }
    Remove-Item -Force $markerPath -ErrorAction SilentlyContinue
    Write-Host "pixi removal attempted."
  } else {
    Write-Host "pixi removal skipped."
    Write-Host "Reason: marker not found, so we can't safely assume pixi was installed by this script." -ForegroundColor Yellow
    Write-Host "If you added PATH changes manually, remove them from your shell profile."
  }

  Write-Host
  Write-Host "== Remove complete =="
}

function MainInstall {
  $home = Get-HomeDir
  $targetDir = Join-Path $home "Documents\BIO713\TP"
  New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
  Set-Location $targetDir

  Write-Host "== Installer: Pixi shell, JupyterLab, ReportLab =="
  Write-Host "Target: $targetDir (self-contained)"
  Write-Host "Working in: $targetDir"
  Write-Host

  Ensure-Curl
  Install-Pixi

  $envName = "Documents\BIO713\TP"

  Write-Host "Initializing pixi project (if needed)..."
  if (-not (Test-Path (Join-Path $targetDir "pixi.toml"))) {
    # pixi init --name py >/dev/null 2>&1 || true
    # PowerShell doesn't have easy cross-version suppression; just run and ignore errors.
    try { pixi init $envName | Out-Null } catch { }
  }

  Write-Host "Adding Python + packages to pixi env: $envName"
  foreach ($pkg in @("python","jupyterlab","reportlab", "biopython")) {
    try { pixi add $pkg | Out-Null } catch { }
  }

  Write-Host "Syncing environment..."
  try {
    pixi install --no-progress | Out-Null
  } catch {
    try { pixi install | Out-Null } catch { }
  }

  Write-Host
  Write-Host "== Quick sanity checks =="
  try {
    pixi run -- python -c "import jupyterlab; print('JupyterLab OK')"
  } catch {
    Write-Host "Sanity check for JupyterLab failed (continuing): $($_.Exception.Message)" -ForegroundColor Yellow
  }
  try {
    pixi run -- python -c "import reportlab; print('ReportLab OK', reportlab.Version)"
  } catch {
    Write-Host "Sanity check for ReportLab failed (continuing): $($_.Exception.Message)" -ForegroundColor Yellow
  }
  try {
    pixi run -- python -c "import Bio; print('BioPython OK', Bio.__version__)"
  } catch {
    Write-Host "Sanity check for BioPython failed (continuing): $($_.Exception.Message)" -ForegroundColor Yellow
  }

  Write-Host
  Write-Host "To start a shell with the env:"
  Write-Host "  pixi shell -e $envName"
  Write-Host
  Write-Host "To launch JupyterLab:"
  Write-Host "  pixi run -e $envName -- jupyter-lab"
  Write-Host
  Write-Host "== Done! =="
}

if ($Remove) {
  Cleanup
} else {
  MainInstall
}
