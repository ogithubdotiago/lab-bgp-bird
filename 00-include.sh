#!/bin/bash

#custom_print
printc() {
    if [ "$2" == "yellow" ]; then
        COLOR="93m" #yellow
    else
        COLOR="92m" #green
    fi
    STARTCOLOR="\e[$COLOR"
    ENDCOLOR="\e[0m"
    printf "$STARTCOLOR%b$ENDCOLOR" "$1"
}
