#!/bin/bash

source $(dirname $0)/00-include.sh

multipass delete --all --purge
