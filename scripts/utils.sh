#!/usr/bin/env bash

run_timed_command() {
  # runtime variables
  local start
  local end
  local runtime

  # current execution
  local cmd="${1}"
  start=$(date +%s)
  echo_success "\$ ${cmd}"
  eval "${cmd}"

  # get the exit code
  local ret=$?

  # finish the execution
  end=$(date +%s)
  runtime=$((end-start))

  if [ $ret -eq 0 ]; then
    echo_success "==> '${cmd}' succeeded in ${runtime} seconds."
    return 0
  else
    echo_error "==> '${cmd}' failed (${ret}) in ${runtime} seconds."
    return $ret
  fi
}

echo_error() {
  local header="${2}"

  if [ -n "${header}" ]; then
    printf "\n\033[0;31m** %s **\n\033[0m" "${1}" >&2;
  else
    printf "\033[0;31m%s\n\033[0m" "${1}" >&2;
  fi
}

echo_info() {
  local header="${2}"

  if [ -n "${header}" ]; then
    printf "\n\033[0;33m** %s **\n\033[0m" "${1}" >&2;
  else
    printf "\033[0;33m%s\n\033[0m" "${1}" >&2;
  fi
}

echo_success() {
  local header="${2}"

  if [ -n "${header}" ]; then
    printf "\n\033[0;32m** %s **\n\033[0m" "${1}" >&2;
  else
    printf "\033[0;32m%s\n\033[0m" "${1}" >&2;
  fi
}
