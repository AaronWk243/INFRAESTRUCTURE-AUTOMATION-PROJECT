#!/bin/env bash
docker stop $(docker ps -aq)
docker rm -f $(docker ps -aq)

rm -rf /opt/stack001
