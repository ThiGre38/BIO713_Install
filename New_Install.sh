#!/usr/bin/env bash
#: Title       : Install.sh
#: Date        : 2026-04-08
#: Updated     : 2026-04-15
#: Author      : Thierry Gautier <thierry.gautier@univ-grenoble-alpes.fr>
#: Version     : 2.0b
#: Description : Automatic install of python for the BIO713 Practical.
#: Usage       : ./Install.sh [options]
#: Options     : --version
set -euo pipefail

# ---- parameters ----
# # Colors for status messages
VERSION=2.0b
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ---- some functions ----
function title_sup(){
echo -e " ${BLUE}###################################################${NC}"
echo -e " ${BLUE}#              ${YELLOW}AUTOMATIC CONFIGURATION            ${BLUE}#${NC}"
echo -e " ${BLUE}#              ${YELLOW}    MacOS and Linux                ${BLUE}#${NC}"
echo -e " ${BLUE}#                     ${YELLOW} (BIO713)                   ${BLUE}#${NC}"
echo -e " ${BLUE}#         ${GREEN}®2026 TG - UFR chimie biologie          ${BLUE}#${NC}"
echo -e " ${BLUE}###################################################${NC}"
echo
echo -e "${CYAN}==>${NC} Installer: Pixi shell, JupyterLab, ReportLab ${CYAN}<==${NC}"
echo "This works on macOS and popular Linux distros."
echo
}

# ---- detect OS ----
function detect_os() {
OS="$(uname -s)"
IS_MAC=0
IS_LINUX=0
OSV=`uname -o`
OSR=`uname -r`
proc=` uname -m`
case "$OS" in
  Darwin*) IS_MAC=1;
    echo -e "             ${GREEN}>${NC} Script launched on MacOS";;
  Linux*)  IS_LINUX=1;
    echo -e "             ${GREEN}>${NC} Script launched on Linux";;
  *) echo -e "${RED}==> Error${NC}: Unsupported OS $OS"; exit 1 ;;
esac
echo "             Processor: ${proc}"
echo -e "             OS version: ${OSV}, ${OSR}"
}
# ---- ensure basic deps ----
if command -v curl >/dev/null 2>&1; then
  :
else
  echo -e "\n${YELLOW}Warning${NC}:"
  echo -e "${YELLOW}curl not found. Please install curl and re-run.${NC}"
  exit 1
fi

# ---- Install pixi (Rust-based, installs to user home) ----
install_pixi() {
  if command -v pixi >/dev/null 2>&1; then
    echo -e "    ${GREEN}==>${NC} pixi: already installed."
    return 0
  fi
  echo
  echo -e "    ${GREEN}==>${NC} Installing pixi..."
  curl -fsSL https://pixi.sh/install.sh | bash
  # pixi installer typically puts ~/.pixi/bin in PATH; ensure it
  export PATH="$HOME/.pixi/bin:$PATH"
  if ! command -v pixi >/dev/null 2>&1; then
    echo "    ${YELLOW}Warning${NC}: pixi install completed, but pixi not found in PATH."
    echo "Try: export PATH=\"\$HOME/.pixi/bin:\$PATH\" and re-run."
    exit 1
  fi
}

# ---- Use pixi to create an env + install Python packages ----
install_python_pkgs() {
  local env="py"
  # Ensure pixi can create/run envs
  if ! command -v pixi >/dev/null 2>&1; then
    echo "${RED}==> Error${NC}: pixi is required but not available."
    exit 1
  fi

  echo "Creating/using pixi environment: $env"
  # Minimal pixi config: Python + packages via PyPI
  # We keep it compact: use pixi 'init' and then 'add' for python deps.
  if [ ! -f "pixi.toml" ]; then
    # Create in current dir to keep things simple
    pixi init "$env" || true
  fi

  # Add dependencies (idempotent enough for common use)
  # If pixi.toml exists, these commands will update it.
  cd $env
  echo -e "    ${GREEN}==>${NC} Installing via pixi (this may download wheels/packages)..."
  pixi add python || true
  pixi add jupyterlab || true
  pixi add reportlab || true
  pixi install --no-progress || pixi install || true

  echo -e "    ${GREEN}==>${NC} Done.\n To use, type:"
  echo " pixi shell -e $env"

  echo -e "\n To activate pixi, relaunch the terminal"

}

# ---- Main function ----
main() {
  title_sup
  detect_os

  echo
  echo -e "${CYAN}==>${NC} Installing JupyterLab & ReportLab  ${CYAN}<==${NC}"
  echo "Using pixi environment to keep Python deps tidy."

  install_pixi
  install_python_pkgs

  echo
  echo -e "${CYAN}==>${NC} Installation complete! ${CYAN}<==${NC}"
  echo
  echo -e "${GREEN}==>${NC} Restart your terminal and run the Checking.sh script."
  echo " Type either ./Checking.sh or bash Checking.sh"
  echo
  echo -e "${YELLOW}==> Note${NC}:"
  echo "- If your shell doesn't automatically pick up pixi on the next login,"
  echo "  add this to your ~/.bashrc or ~/.zshrc:"
  echo "    export PATH=\"\$HOME/.pixi/bin:\$PATH\""
  echo
}

main "$@"
