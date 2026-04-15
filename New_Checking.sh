#!/usr/bin/env bash
set -euo pipefail

echo "== Checker: Pixi shell, JupyterLab, ReportLab =="
echo "This works on macOS and popular Linux distros."
echo

# ---- detect OS ----
OS="$(uname -s)"
IS_MAC=0
IS_LINUX=0
case "$OS" in
  Darwin*) IS_MAC=1 ;;
  Linux*)  IS_LINUX=1 ;;
  *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

# --- Verifications ----
# pixi

if command -v pixi >/dev/null 2>&1; then
    echo " ✔ pixi is correctly installed."
else
    echo " 𐄂 pixi is not yet installed."
    echo "First run the install.sh script..."
    echo "...or restart your terminal if you already ran the install.sh script."
    exit 1
fi

env='py'
cd $env


  echo "Quick checks:"
  version=`pixi run python --version`
  echo " ✔ ${version}"
  version=`pixi run jupyter lab --version`
  echo " ✔ Jupyter lab: ${version}"
  version=`pixi run python -c 'import reportlab; print(reportlab.Version)'`
  echo " ✔ ReportLab: ${version}"
