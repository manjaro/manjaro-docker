# Docker Base Image for Manjaro Linux

This repository contains all scripts and files needed to create a Docker base image for the Manjaro Linux distribution.

## Purpose

* Provide the Manjaro experience in a Docker MultiArch Docker Image for amd64 and arm64
* Provide the most simple but complete image to base every other upon
* `pacman` needs to work out of the box
* All installed packages have to be kept unmodified

## Installation guide

*Pull the docker image*
```
# docker pull manjarolinux/base
```

*Create the docker container*
```
# docker run -d -t --name manjaro-container manjarolinux 
```
*Go inside the container*
```
# docker exec -it manjaro-container bash
```