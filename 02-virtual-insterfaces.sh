#!/bin/bash

source $(dirname $0)/00-include.sh

printc "\n######################################\n"
printc "# Criando virtual network interfaces #\n"
printc "######################################\n"

for id in {1..2}; do
    printc "\n# Configurando virtual network interfaces vm${id}\n" "yellow"
    multipass exec -v vm${id} -- sudo sysctl --write net.ipv4.ip_forward=1
    multipass exec -v vm${id} -- sudo ip netns add vm${id}_pod
    multipass exec -v vm${id} -- sudo ip link add dev veth_vm${id} type veth peer veth_vm${id}_pod
    multipass exec -v vm${id} -- sudo ip link set dev veth_vm${id} up
    multipass exec -v vm${id} -- sudo ip link set dev veth_vm${id}_pod netns vm${id}_pod
    multipass exec -v vm${id} -- sudo ip netns exec vm${id}_pod ip link set dev lo up
    multipass exec -v vm${id} -- sudo ip netns exec vm${id}_pod ip link set dev veth_vm${id}_pod up
    multipass exec -v vm${id} -- sudo ip netns exec vm${id}_pod ip address add 10.0.${id}.10 dev veth_vm${id}_pod
    multipass exec -v vm${id} -- sudo ip netns exec vm${id}_pod ip route add default via 10.0.${id}.10
    multipass exec -v vm${id} -- sudo ip route add 10.0.${id}.10/32 dev veth_vm${id}
    multipass exec -v vm${id} -- sudo iptables --append FORWARD --in-interface ens3 --out-interface veth_vm${id} --jump ACCEPT
    multipass exec -v vm${id} -- sudo iptables --append FORWARD --in-interface veth_vm${id} --out-interface ens3 --jump ACCEPT
    multipass exec -v vm${id} -- sudo iptables --append POSTROUTING --table nat --out-interface ens3 --jump MASQUERADE

    printc "\n# Teste de ping para o ip no netns vm${id}\n" "yellow"
    multipass exec vm${id} -- ping -c 1 10.0.${id}.10
    
    printc "\n# Teste para acesso externo ao netns vm${id}\n" "yellow"
    multipass exec vm${id} -- sudo ip netns exec vm${id}_pod ping -c 1 8.8.8.8

    printc "\n# Habilitando arp proxy vm${id}\n" "yellow"
    multipass exec vm${id} -- sudo sysctl --write net.ipv4.conf.veth_vm${id}.proxy_arp=1

    printc "\n# Novo teste para acesso externo ao netns vm${id}\n" "yellow"
    multipass exec vm${id} -- sudo ip netns exec vm${id}_pod ping -c 1 8.8.8.8
done
