#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export UCF_FORCE_CONFFNEW=true

apt-get install python-software-properties software-properties-common -y
add-apt-repository ppa:teward/znc -y
apt-get update -y
apt-get install znc -y
apt-get clean
