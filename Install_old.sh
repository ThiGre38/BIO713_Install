#!/bin/bash
#: Title       : Install.sh
#: Date        : 2026-04-08
#: Updated     :
#: Author      : Thierry Gautier <thierry.gautier@univ-grenoble-alpes.fr>
#: Version     : 1.0b
#: Description : Automatic install python modules for the BIO713 Practical.
#: Usage       : ./Install.sh [options]
#: Options     : --version

# tell the script to exit immediately on any error rather than continuing to
# the next command after the command with the error
set -e

# tell the script to exit when you press ctrl-c
trap "exit" INT

# print each command being executed
# set -x

# TO CHECK AND USE
# set -euo pipefail

# Colors for status messages
VERSION=1.0b
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

function title_sup(){
echo -e " ${BLUE}###################################################${NC}"
echo -e " ${BLUE}#              ${YELLOW}AUTOMATIC CONFIGURATION            ${BLUE}#${NC}"
echo -e " ${BLUE}#                ${YELLOW}    MacOS                        ${BLUE}#${NC}"
echo -e " ${BLUE}#                    ${YELLOW}for BIO713                   ${BLUE}#${NC}"
echo -e " ${BLUE}#         ${GREEN}®2026 TG - UFR chimie biologie          ${BLUE}#${NC}"
echo -e " ${BLUE}###################################################${NC}"
}

# Testing the environnement (MacOS or Linux)
# TODO : Windows
title_sup

echo -e "\n ${MAGENTA} 1.>>>>>>>>>>>${NC} Detecting environment."
# Initialise variables
unameResult=`uname -s`
isMacOS=false
isLinux=false
proc=` uname -m`
if [[ "$unameResult" == 'Darwin' ]]; then isMacOS=true
     echo -e "             ${GREEN}>${NC} Script launched on MacOS"
     echo "             Processor: ${proc}"
     OSV=`sw_vers 2>/dev/null | awk '/ProductVersion/ { print $2 }'`
     echo -e "             OS version: ${OSV}"
elif [[ "$unameResult" == 'Linux' ]]; then isLinux=true
     echo -e "             ${GREEN}>${NC} Script launched on Linux"
     echo -e "\n           ${YELLOW} This environment is not yet supported.${NC}"
     exit 0
else echo -e "\n             ${RED}> ERROR: Insupported environment."
     echo -e "\n ${RED} >>>>>>>>>>> This script works only on MacOS and Linux.${NC}"
     echo -e " ${YELLOW} >>>>>>>>>>> Contact a teacher for help <<<<<<<<<<<${NC}"
     echo -e "  ${RED}          ************ BYE ****************${NC}\n"; exit 1
fi

echo -e "\n ${MAGENTA} 2.>>>>>>>>>>>${NC} Installing the modules."
echo -e "\n${CYAN} 1. -> Creates the hierarchy...${NC}"
mkdir -p ~/Documents/BIO713/TP/files/pombe

echo -e "\n${CYAN} 2. -> Install pixi...${NC}"
curl -fsSL https://pixi.sh/install.sh | sh
source ~/.zshrc

echo -e "\n${CYAN} 3. -> Verify pixi installation...${NC}"
pixi self-update

echo -e "\n${CYAN} 4. -> Initialize the TP directory to use...${NC}"
cd ~/Documents/BIO713
pixi init TP
cd TP
pixi add biopython jupyterlab reportlab
pixi install

echo -e "\n${CYAN} 5. -> All steps done...${NC}"
echo -e "\n READY !\n"

cd ~/Documents/BIO713/TP
echo -e "\n ${MAGENTA} 3.>>>>>>>>>>>${NC} Running the app."
echo " Please copy-paste the following commands:"
echo -e "\n${CYAN} 6. -> Please move to the following directory:${NC}"
echo -e "cd ${PWD}\n"
echo -e "\n${CYAN} 7. -> Then enter the following commands:${NC}"
echo -e " pixi shell\n"
echo -e "\n${CYAN} 8. -> Start Jupyter by entering the command:${NC}"
echo -e " jupyter lab &\n"
