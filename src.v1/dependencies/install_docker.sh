#!/bin/bash

#install docker
sudo apt-get update
sudo apt-get install docker-ce
sudo usermod -a -G docker ${USER}
exit
