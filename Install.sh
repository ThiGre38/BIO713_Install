#!/bin/bash



echo -e "\n 1. -> Creates the hierarchy..."
mkdir -p ~/Documents/BIO713/TP/files/pombe

echo -e "\n 2. -> Install pixi..."
curl -fsSL https://pixi.sh/install.sh | sh
source ~/.zshrc

echo -e "\n 3. -> Verify pixi installation..."
pixi self-update

echo -e "\n 4. -> Initialize the TP directory to use..."
cd ~/Documents/BIO713
pixi init TP
cd TP
pixi add biopython jupyterlab reportlab
pixi install

echo -e "\n 5. -> All steps done..."
echo -e "\n READY !\n"

cd ~/Documents/BIO713/TP
echo -e "\n 6. -> Please move to the following directory: "
pwd
echo -e "\n 7. -> Then enter the following commands"
echo -e " pixi shell\n"
echo -e "\n 8. -> Start Jupyter by entering the command:"
echo -e " jupyter lab &\n"
