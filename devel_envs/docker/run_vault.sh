#!/bin/bash

docker rm --force vault_server1
docker run --cap-add IPC_LOCK --name vault_server1 --hostname server1 -v ${PWD}/vault:/vault -p 8200:8200 vault:1.6.3 server
