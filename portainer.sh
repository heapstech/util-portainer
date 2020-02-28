#!/usr/bin/env bash
# -*- coding: utf-8 -*-

REQUIRED="docker"
PORTAINER_PORT=9000

docker_kill_portainer() {
  echo "Listing docker process"
  if docker ps --filter ancestor="portainer/portainer" -q >/dev/null 2>&1; then
    docker kill $(docker ps -a --filter ancestor="portainer/portainer" -q)
    echo >&2"Existing container process killed"
    echo "Done"
  fi
}

docker_rm_portainer() {
  echo "Listing docker process"
#  docker ps -a
  if docker ps -a --filter ancestor="portainer/portainer" -q >/dev/null 2>&1; then
    docker rm $(docker ps -a --filter ancestor="portainer/portainer" -q)
    echo >&2"Existing container removed"
#    docker ps -a
    echo "Done"
  fi
}

docker_run() {
  echo "================================================="
  echo "Daemon is started, visit: http://localhost:$PORTAINER_PORT"
  trap '' INT
  docker run -p $PORTAINER_PORT:$PORTAINER_PORT --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer
  cleanup
}

docker_run_daemon() {
  echo "================================================="
  echo "Daemon is started, visit: http://localhost:$PORTAINER_PORT"
  docker run -d -p $PORTAINER_PORT:$PORTAINER_PORT --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer
}

cleanup() {
  docker ps -a
#  docker_kill_portainer
  sleep 1
  echo "#C=L=E=A=N=U=P, Killing portainer"
#  docker_rm_portainer
  sleep 1
  echo "#C=L=E=A=N=U=P, Removing portainer"
}

help() {
  echo '========================== With parameter'
  echo 'Usage: $ bash ./portainer.sh' to start interactive shell
  echo ""
  echo '[OPTIONS]'
  echo 'help | -h | -help ---- show usage'
  echo 'kill | -k | -kill ---- to kill existing container only'
  echo ""
  echo 'Docs: https://portainer.readthedocs.io/en/stable/index.html'
  echo '=================================================='
}

interactive_menu() {
  echo '=========================== Interactive'
  echo 'Usage: $ bash ./portainer.sh'
  echo ""
  echo '[WITH PARAMETERS]'
  echo 'help | -h | -help ---- show usage'
  echo 'kill | -k | -kill ---- to kill existing container only'
  echo ""
  echo '[INTERACTIVE]'
  echo '1. Start with daemon'
  echo '2. Start without daemon'
  echo '3. Cleanup'
  echo '4. Exit'
  echo ""
  echo 'Docs: https://portainer.readthedocs.io/en/stable/index.html'
  echo '=================================================='
}
interactive() {
  while :
    do
      help
      interactive_menu
      echo -n "(Choose 1/2/3/4):"
      read line
      case "$line" in
      1)
        docker_kill_portainer
        docker_rm_portainer
        docker_run_daemon
        trap '' INT
        exit 1
        ;;
      2)
        docker_kill_portainer
        docker_rm_portainer
        docker_run
        cleanup
        exit 1
        ;;
      3)
        cleanup
        exit 1
        ;;
      4)
        exit 1
        ;;
      esac
    done

    exit 1
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
  daemon | -d | --daemon)
    docker_kill_portainer
    docker_rm_portainer
    docker_run_daemon
      ;;
  * )
    interactive
    ;;
  esac
fi
