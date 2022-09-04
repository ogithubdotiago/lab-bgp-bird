#!/bin/bash

source $(dirname $0)/00-include.sh

printc "\n#####################\n"
printc "# Roteamento dinamico #\n"
printc "#####################\n"

printc "\n# Instalando bird2\n"
    for id in {1..2}; do
        printc "\nvm${id}\n" "yellow"
        multipass exec vm${id} -- bash -c 'sudo apt update && sudo apt install bird2 --yes'
    done

printc "\n# Configurando bird2\n"

printc "\nvm1\n" "yellow"
cat <<EOF | multipass exec vm1 -- sudo tee /etc/bird/bird.conf
log syslog all;

router id 198.20.0.1;

protocol device {
}

protocol direct {
  ipv4;
}

protocol kernel {
  ipv4 {
    export all;
  };
}

protocol static {
  ipv4;
  route 10.0.1.0/24 blackhole;
}

protocol bgp vm2 {
  local 198.20.0.1 as 65000;
  neighbor 198.20.0.2 as 65000;

  ipv4 {
    import all;
    export all;
  };
}
EOF

printc "\nvm2\n" "yellow"
cat <<EOF | multipass exec vm2 -- sudo tee /etc/bird/bird.conf
log syslog all;

router id 198.20.0.2;

protocol device {
}

protocol direct {
  ipv4;
}

protocol kernel {
  ipv4 {
    export all;
  };
}

protocol static {
  ipv4;
  route 10.0.2.0/24 blackhole;
}

protocol bgp vm1 {
  local 198.20.0.2 as 65000;
  neighbor 198.20.0.1 as 65000;

  ipv4 {
    import all;
    export all;
  };
}
EOF

    for id in {1..2}; do
        printc "\nvm${id}\n" "yellow"
        multipass exec -v vm${id} -- sudo systemctl restart bird
    done
    sleep 30

printc "\n# Validando conexao bgp via birdc\n"
for id in {1..2}; do
    printc "\nvm${id}\n" "yellow"
    multipass exec vm${id} sudo birdc show protocols all
done

printc "\n# Validando rotas via birdc\n"
for id in {1..2}; do
    printc "\nvm${id}\n" "yellow"
    multipass exec vm${id} sudo birdc show route
done

printc "\n# Validando rotas via ip route\n"
for id in {1..2}; do
    printc "\nvm${id}\n" "yellow"
    multipass exec vm${id} -- ip route list
done

printc "\n# Validando conexao entre netns via ping\n"
    printc "\nvm1\n" "yellow"
    multipass exec vm1 -- ping -c 1 10.0.2.10

    printc "\nvm2\n" "yellow"
    multipass exec vm2 -- ping -c 1 10.0.1.10
