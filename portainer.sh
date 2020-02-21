#!/usr/bin/env bash
# -*- coding: utf-8 -*-

REQUIRED="docker"
PORTAINER_PORT=9000

docker_kill_portainer() {
  if docker ps --filter ancestor="portainer/portainer" -q >/dev/null 2>&1; then
    docker kill $(docker ps -a --filter ancestor="portainer/portainer" -q)
   { echo >&2"Existing container process killed"}
  fi
}

docker_rm_portainer() {
  if docker ps -a --filter ancestor="portainer/portainer" -q >/dev/null 2>&1; then
   { docker rm $(docker ps -a --filter ancestor="portainer/portainer" -q) }
   { echo >&2"Existing container removed" }
  fi
}

docker_run() {
  if docker run -d -p $PORTAINER_PORT:$PORTAINER_PORT --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer; then
    echo "================================================="
    echo "Daemon is running, visit: http://localhost:$PORTAINER_PORT"
  fi
}

help() {
  echo '=================================================='
  echo 'Usage: $ bash ./portainer.sh'
  echo '\n'
  echo '[OPTIONS]'
  echo 'help | -h | -help ---- show usage'
  echo 'kill | -k | -kill ---- to kill existing container only'
  echo '\n'
  echo 'Docs: https://portainer.readthedocs.io/en/stable/index.html'
  echo '=================================================='
}

if ! type $REQUIRED >/dev/null 2>&1 ; then
   { echo >&2 "I require $REQUIRED but it's not installed.  Aborting."; exit 1; }
else
  case $1 in
  kill | -k | --kill)
      docker_kill_portainer
      docker_rm_portainer
      ;;
  help | -h | --help)
      help
      ;;
  * )
    help
    docker_kill_portainer
    docker_rm_portainer
    docker_run
    ;;
  esac
fi
