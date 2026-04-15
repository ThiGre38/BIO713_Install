#!/usr/bin/env bash
#: Title       : Checking.sh
#: Date        : 2026-04-15
#: Updated     : 
#: Author      : Thierry Gautier <thierry.gautier@univ-grenoble-alpes.fr>
#: Version     : 1.0b
#: Description : Checks the pix environment for the BIO713 Practical.
#: Usage       : ./Checking.sh [options]
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
echo -e "${CYAN}==>${NC} Checker: Pixi shell, JupyterLab, ReportLab ${CYAN}<==${NC}"
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

# --- Verifications ----

function check_pixi() {
    echo
    echo -e "${CYAN}==>${NC} Checking the installation of pixi and deps ${CYAN}<==${NC}"
    if command -v pixi >/dev/null 2>&1; then
        version=`pixi --version`
        echo -e " ${GREEN}✔${NC} ${version}"
        else
            echo  -e " ${RED}𐄂${NC} pixi is not yet installed."
            echo "First run the install.sh script..."
            echo "...or restart your terminal if you already ran the install.sh script."
            exit 1
    fi
}

function check_env() {
    ENV='py'
    # Test of the directory
    if [ ! -d "$ENV" ];then
        echo -e "\n${RED}ERROR${NC}: The pixi environment for the practical is not detected."
        echo "Please run first the Install.sh script, then re-run.\n"
        exit 1
        else
            cd $ENV
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
    
    if ! command -v `pixi run jupyter lab --version` >/dev/null 2>&1;then
        echo  -e " ${RED}𐄂${NC} jupyter lab is not yet installed."
        BADJUP=false
        pwd
    else
        version=`pixi run jupyter lab --version`
        echo -e " ${GREEN}✔${NC} Jupyter lab ${version}"
        BADJUP=true
    fi
    if ! command -v `pixi run python -c 'import reportlab; print(reportlab.Version)'` >/dev/null 2>&1;then
        echo  -e " ${RED}𐄂${NC} ReportLab is not yet installed."
        BADREP=false
    else
        version=`pixi run python -c 'import reportlab; print(reportlab.Version)'`
        echo -e " ${GREEN}✔${NC} ReportLab ${version}"
        BADREP=true
    fi
    echo
    if [[ "$BADPYT" == "true" && "$BADJUP" == "true" && "$BADREP" == "true" ]];then
        echo -e "${CYAN}==>${NC} Installation complete! ${CYAN}<==${NC}"
        echo; exit 0
    else
        echo -e "${RED} ==>${NC} Installation incomplete! ${RED}<==${NC}"
        echo -e "${RED} ==>${NC} Check the procedure or ask the prof. ${RED}<==${NC}"
        echo; exit 1
    fi
}

function main() {
    title_sup
    detect_os
    check_pixi
    check_env
    check_deps
    
}

main "$@"