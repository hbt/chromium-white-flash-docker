# Chromium docker build 

## What is it?

dockerfile + instructions on how to build chromium for ubuntu 14.04

This used to build chromium for https://github.com/hbtlabs/chromium-white-flash-fix

## Why?

building chromium within docker is safer since:

- chromium installs too many dependencies and updates/upgrades libraries
- chromium build/install instructions can get complicated and having a repeatable process is reliable


## How to build chromium?

`docker-compose build chromium`
`docker-compose run chromium`

## What about other chromium versions?

Update the dockerfile and select the version you want. Instructions might need to be tweaked if dependencies are missing or built is broken.


## Why is the src inside docker instead of mounted as a volume?

Chromium Python code fails due to cross-device link issues when dealing with mounted volumes.
Possible fixes would be in latest docker versions and alternative filesystems. 
The workaround is not worth the time a copy would take. 


## What are the sh scripts for?

experiment with tweaks, development etc.
Make sure to commit the container (save as docker image) to not lose progress


## Recommendations

- rent cloud vm with highcpus since compilation can take hours on regular computers. 
- estimated cost from start to finish ~4$ on 64vcpu google cloud 
