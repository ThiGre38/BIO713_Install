#!/usr/bin/env bash
#: Title       : Install.sh
#: Date        : 2026-04-08
#: Updated     : 2026-04-16
#: Author      : Thierry Gautier <thierry.gautier@univ-grenoble-alpes.fr>
#: Version     : 2.0
#: Description : Automatic install of python for the BIO713 Practical.
#: Usage       : ./Install.sh [options]
#: Options     : --help, --remove, --check
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
HIERARCHY_DIR="${HOME}/Documents/BIO713/TP/files/pombe"
TARGET_DIR="${HOME}/Documents/BIO713/TP"

# ---- some functions ----
function title_sup(){
echo -e "\n ${BLUE}###################################################${NC}"
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

function usage() {
  cat <<'EOF'

Usage:
  ./Install.sh           Install (default)
  ./Install.sh --check   Check for proper installation
  ./Install.sh --remove  Totally remove the install and revert changes
  ./Install.sh --help    Display this message and quit.

What “remove” does:
  - Deletes the target directory: ~/Documents/BIO713/Practical
  - If pixi was installed by this script, it will try to remove ~/.pixi (and restore nothing else)

UGA - Grenoble, TG©2026
EOF
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
function install_pixi() {
    echo
    echo -e "${CYAN}==>${NC} Installing JupyterLab & ReportLab  ${CYAN}<==${NC}"
    echo "Using pixi environment to keep Python deps tidy."

    if command -v pixi >/dev/null 2>&1; then
        echo -e "    ${GREEN}==>${NC} pixi: already installed."
        return 0
        fi
    echo
    echo -e "    ${GREEN}==>${NC} Installing pixi..."
    curl -fsSL https://pixi.sh/install.sh | bash
    # Mark that pixi likely came from this script (best-effort)
    mkdir -p "$(dirname "$HOME/.pixi_remove_marker")" 2>/dev/null || true
    : > "$HOME/.pixi_remove_marker"
    # pixi installer typically puts ~/.pixi/bin in PATH; ensure it
    export PATH="$HOME/.pixi/bin:$PATH"
    if ! command -v pixi >/dev/null 2>&1; then
        echo "    ${YELLOW}Warning${NC}: pixi install completed, but pixi not found in PATH."
        echo "Try: export PATH=\"\$HOME/.pixi/bin:\$PATH\" and re-run."
        exit 1
    fi
}

function cleanup() {
    echo
    echo -e "${YELLOW}==>${NC} Installer: ${RED}Remove mode${NC} ${YELLOW}<==${NC}"


    if [ -d "$TARGET_DIR" ]; then
        echo -e "${YELLOW}==>${NC} Deleting project directory: $TARGET_DIR ${YELLOW}<==${NC}"
        rm -Rf "$TARGET_DIR"
    else
        echo -e "${YELLOW}==>${NC} Project directory not found (skipping): $TARGET_DIR ${YELLOW}<==${NC}"
    fi

    BIO713="${HOME}/Documents/BIO713"
    if [ -d "${BIO713}" ];then
        echo -e "${YELLOW}==>${NC} Deleting BIO713 directory: $BIO713 ${YELLOW}<==${NC}"
        rm -Rf "$BIO713"
    else
        echo -e "${YELLOW}==>${NC} BIO713 directory not found (skipping): $BIO713 ${YELLOW}<==${NC}"
    fi

    # Best-effort: only remove ~/.pixi if we believe we installed it
    if [ -f "$HOME/.pixi_remove_marker" ]; then
        echo -e "${GREEN}==>${NC} pixi was installed by this script (marker found)."
        echo "Attempting to remove: $HOME/.pixi"
        rm -rf "$HOME/.pixi" || true
        rm -f "$HOME/.pixi_remove_marker" || true
        echo -e "${GREEN}==>${NC} pixi removal attempted. ${YELLOW}<==${NC}"
    else
        echo -e "${RED}==>${NC} pixi removal skipped. ${RED}<==${NC}"
        echo "Reason: marker not found, so we can't safely assume pixi was installed by this script."
        echo "If you added PATH changes manually, you should remove them from your shell profile."
    fi

    echo
    echo -e "${GREEN}==>${NC} Remove complete ${GREEN}<==${NC}"
}

# ---- Use pixi to create an env + install Python packages ----
function install_python_pkgs() {
    mkdir -p "$HIERARCHY_DIR"
    # Ensure pixi can create/run envs
    if ! command -v pixi >/dev/null 2>&1; then
        echo "${RED}==> Error${NC}: pixi is required but not available."
        exit 1
    fi

  echo "Creating/using pixi environment: $TARGET_DIR"
  # Minimal pixi config: Python + packages via PyPI
  # We keep it compact: use pixi 'init' and then 'add' for python deps.
  if [ ! -f "$TARGET_DIR/pixi.toml" ]; then
    # Create in current dir to keep things simple
    pixi init "$TARGET_DIR" || true
  fi

  # Add dependencies (idempotent enough for common use)
  # If pixi.toml exists, these commands will update it.
  cd $TARGET_DIR
  echo -e "    ${GREEN}==>${NC} Installing via pixi (this may download wheels/packages)..."
  pixi add python || true
  pixi add jupyterlab || true
  pixi add biopython || true
  pixi add reportlab || true
  pixi install --no-progress || pixi install || true

  echo -e "    ${GREEN}==>${NC} Done.\n To use, type:"
  echo " pixi shell -e $TARGET_DIR"

  echo -e "\n To activate pixi, relaunch the terminal"

}

function check_pixi() {
    echo
    echo -e "${CYAN}==>${NC} Checking the installation of pixi and deps ${CYAN}<==${NC}"
    if command -v pixi >/dev/null 2>&1; then
        version=`pixi --version`
        echo -e " ${GREEN}✔${NC} ${version}"
    else
        echo  -e " ${RED}𐄂${NC} pixi is not yet installed."
        echo "First run ./Install.sh ..."
        echo "...or restart your terminal if you already ran the ./Install.sh."
        exit 1
    fi
}

function check_env() {
    echo
    echo -e "${CYAN}==>${NC} Checker: Pixi shell, JupyterLab, ReportLab ${CYAN}<==${NC}"
    echo "This works on macOS and popular Linux distros."
    echo
    # Test of the directory
    if [ ! -d "$TARGET_DIR" ];then
        echo -e "\n${RED}Error${NC}: The pixi environment for the practical is not detected."
        echo -e "Please run first ./Install.sh, then re-run ./Install.sh --check.\n"
        exit 1
    else
        cd $TARGET_DIR
        echo -e "${GREEN}==> Working in: $TARGET_DIR <==${NC}"
        echo
    fi
}

function check_deps() {
    if ! command -v `pixi run python --version` >/dev/null 2>&1;then
        echo  -e " ${RED}𐄂${NC} pixi is not yet installed."
        BADPYT=false
    else
        version=`pixi run python --version`
        echo -e " ${GREEN}✔${NC} ${version}"
        BADPYT=true
    fi
    version=`pixi run jupyter lab --version` || true
    if [[ "$version" == " " ]]; then
        echo  -e " ${RED}𐄂${NC} jupyter lab is not yet installed."
        BADJUP=false
    else
        echo -e " ${GREEN}✔${NC} Jupyter lab ${version}"
        BADJUP=true
    fi
    version=`pixi run python -c 'import Bio; print(Bio.__version__)'` || true
    if [[ "$version" == " " ]]; then
        echo -e " ${RED}𐄂${NC} BioPython is not yet installed."
        BADBPY=false
    else
        echo -e " ${GREEN}✔${NC} BioPython ${version}"
        BADBPY=true
    fi
    version=`pixi run python -c 'import reportlab; print(reportlab.Version)'` || true
    if [[ "$version" == " " ]]; then
        echo  -e " ${RED}𐄂${NC} ReportLab is not yet installed."
        BADREP=false
    else
        echo -e " ${GREEN}✔${NC} ReportLab ${version}"
        BADREP=true
    fi
    echo
    if [[ "$BADPYT" == "true" && "$BADJUP" == "true" && "$BADREP" == "true" && "$BADBPY" == "true" ]];then
        echo -e "${CYAN}==>${NC} Installation complete! ${CYAN}<==${NC}"
        echo; exit 0
    else
        echo -e "${RED} ==>${NC} Installation incomplete! ${RED}<==${NC}"
        echo -e "${RED} ==>${NC} Check the procedure or ask the prof. ${RED}<==${NC}"
        echo; exit 1
    fi
}

# ---- Main function ----
function main() {

    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        usage
        exit 0
    fi

    MODE="install"
    if [[ "${1:-}" == "--remove" ]]; then
        MODE="remove"
    fi

    CHECK=0
    if [[ "${1:-}" == "--check" ]];then
        CHECK=true
    fi

    title_sup
    detect_os

    if [[ "$CHECK" == "true" ]];then
        check_env
        check_pixi
        check_deps
        exit 0
    fi

    if [[ "$MODE" == "remove" ]]; then
        cleanup
        echo
        echo -e "${YELLOW}==> Note${NC}:"
        echo "- Check that pixi has been removed from your path, if you wanted it removed."
        echo "  Delete or comment out in your ~/.bashrc or ~/.zshrc:"
        echo "    export PATH=\"\$HOME/.pixi/bin:\$PATH\""
        echo
    else
        install_pixi
        install_python_pkgs
        echo
        echo -e "${CYAN}==>${NC} Installation complete! ${CYAN}<==${NC}"
        echo
        echo -e "${GREEN}==>${NC} Restart your terminal to use python and jupyter lab."
        echo " You can also check you installation by typing ./Install --check"
        echo
        echo -e "${YELLOW}==> Note${NC}:"
        echo " If your shell doesn't automatically pick up pixi on the next login,"
        echo " add this to your ~/.bashrc or ~/.zshrc:"
        echo "    export PATH=\"\$HOME/.pixi/bin:\$PATH\""
        echo
    fi
}

main "$@"
