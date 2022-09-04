#!/bin/bash

source $(dirname $0)/00-include.sh

source 00-include.sh ; sleep 5
source 01-create-vms.sh ; sleep 5
source 02-virtual-insterfaces.sh ; sleep 5
source 03-manual-route.sh ; sleep 5
source 04-dynamic-route.sh ; sleep 5
source 05-clean.sh ; sleep 5
