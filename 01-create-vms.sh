#!/bin/bash

source $(dirname $0)/00-include.sh

printc "\n#############################\n"
printc "# Criando VMs com multipass #\n"
printc "#############################\n"

for id in {1..2}; do
    printc "\n# Criando vm${id}\n" "yellow"
    multipass launch \
      --cloud-init vm${id}-cloud-init.yaml \
      --name vm${id} \
      --mem 2048M \
      22.04 
done
