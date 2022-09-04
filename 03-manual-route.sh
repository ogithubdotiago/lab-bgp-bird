#!/bin/bash

source $(dirname $0)/00-include.sh

printc "\n#####################\n"
printc "# Roteamento manual #\n"
printc "#####################\n"

printc "\nvm1\n" "yellow"

    printc "\n# Teste de ping de vm1 para netns vm2\n"
    multipass exec -v vm1 -- ping -c 1 10.0.2.10

    printc "\n# Criando rotas estaticas\n"
    multipass exec -v vm1 -- sudo ip route add 10.0.2.0/24 via 198.20.0.2
    printc "sudo ip route add 10.0.2.0/24 via 198.20.0.2\n" "yellow"

    printc "\n# Novo teste de ping para netns vm2\n"
    multipass exec -v vm1 -- ping -c 1 10.0.2.10

    printc "\n# Deletando rotas estaticas\n"
    multipass exec -v vm1 -- sudo ip route delete 10.0.2.0/24 via 198.20.0.2
    printc "sudo ip route delete 10.0.2.0/24 via 198.20.0.2\n" "yellow"

printc "\nvm2\n" "yellow"

    printc "\n# Teste de ping de vm2 para netns vm1\n"
    multipass exec -v vm2 -- ping -c 1 10.0.1.10

    printc "\n# Criando rotas estaticas\n"
    multipass exec -v vm2 -- sudo ip route add 10.0.1.0/24 via 198.20.0.1
    printc "sudo ip route add 10.0.1.0/24 via 198.20.0.1\n" "yellow"

    printc "\n# Novo teste de ping para netns vm1\n"
    multipass exec -v vm2 -- ping -c 1 10.0.1.10

    printc "\n# Deletando rotas estaticas\n"
    multipass exec -v vm2 -- sudo ip route delete 10.0.1.0/24 via 198.20.0.1
    printc "sudo ip route delete 10.0.1.0/24 via 198.20.0.1\n" "yellow"