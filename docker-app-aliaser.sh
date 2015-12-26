#!/bin/bash

APP_OPTS=${HOME}/.dockerapps

function createAppAliases() {
  if [[ -f ${APP_OPTS} ]]; then
    for APP_NAME in $(cat ${APP_OPTS} | jq -r ".apps[].name")
    do
      alias ${APP_NAME}="createOrStartContainer ${APP_NAME} $@"
    done
  fi
}

function createOrStartContainer() {
  local APP=$1
  local APP_ARGS=$2
  local IMAGE=$(cat ${APP_OPTS} | jq -r ".apps[] | select(.name == \"${APP}\").image")
  local ARGS="$(cat ${APP_OPTS} | jq -r ".apps[] | select(.name == \"${APP}\").args")"
  local DAEMONIZE="$(cat ${APP_OPTS} | jq -r ".apps[] | select(.name == \"${APP}\").daemonize")"
  local AUTOREMOVE="$(cat ${APP_OPTS} | jq -r ".apps[] | select(.name == \"${APP}\").autoremove")"
  local PULL="$(cat ${APP_OPTS} | jq -r ".apps[] | select(.name == \"${APP}\").pull")"
  local CMD="$(cat ${APP_OPTS} | jq -r ".apps[] | select(.name == \"${APP}\").command")"
  local DOCKER_ARGS=""
  local EXTRA_ARGS="-it"
  local CREATED="false"

  if [[ ! -z "${IMAGE}" ]]; then
    [ ! -f /var/run/docker.pid ] && return

    local CONTAINER_INFO="$(docker inspect --format '{{.Name}}:{{.State.Running}}' ${APP})"
    local NAME="$(echo ${CONTAINER_INFO} | cut -f1 -d:)"
    local RUNNING="$(echo ${CONTAINER_INFO} | cut -f2 -d:)"

    if [[ "${NAME}" == "/${APP}" ]] && [[ "${RUNNING}" == "false" ]]; then
      if [[ "${PULL}" == "false" ]]; then
        docker start ${APP}
        CREATED="true"
      else
        docker rm -f ${APP}
      fi
    elif [[ "${NAME}" == "/${APP}" ]] && [[ "${RUNNING}" == "true" ]]; then
      CREATED="true"
    fi

    if [[ "${PULL}" == "true" ]]; then
      docker pull "${IMAGE}"
    fi

    if [[ "${CREATED}" == "false" ]]; then
      if [[ "${DAEMONIZE}" == "null" || ( ! -z "${DAEMONIZE}" && "${DAEMONIZE}" == "true") ]]; then
        EXTRA_ARGS="${EXTRA_ARGS} -d"
      else
        if [[ "${AUTOREMOVE}" != "null" ]] && [[ "${AUTOREMOVE}" == "true" ]]; then
          EXTRA_ARGS="${EXTRA_ARGS} --rm"
        fi
      fi

      if [[ "${ARGS}" != "null" ]]; then
        DOCKER_ARGS="${ARGS}"
      fi

      eval "docker run --name ${APP} ${DOCKER_ARGS} ${EXTRA_ARGS} ${IMAGE} ${CMD} ${APP_ARGS}"
    fi
  else
    echo "${APP} is not configured"
  fi
}

createAppAliases
