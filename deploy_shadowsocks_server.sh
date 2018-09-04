#!/usr/bin/env bash

# shellcheck disable=SC2128
SOURCED=false && [ "$0" = "$BASH_SOURCE" ] || SOURCED=true

if ! $SOURCED; then
  set -euo pipefail
  IFS=$'\n\t'
fi

usage() {
  echo \
"Usage:
  deploy_shadowsocks_server.sh [options] [<ssh_port>]

Deploy a BOINC server.

Options:
  -h                            Show this help and exits.
  -s <ssh_port>                 Value of the option ssh_server_ports.
  -S <shadowsocks_server_port>  Value of the option shadowsocks_server_port.

Example:
  deploy_shadowsocks_server.sh"
}

flag_help=false
ssh_port='0'
shadowsocks_server_port='0'
while getopts ":hs:S:" opt; do
  case $opt in
    h)
      flag_help=true
      ;;
    s)
      ssh_port="$OPTARG"

      int_regex='^[0-9]+$'
      if ! [[ "$ssh_port" =~ $int_regex ]] ; then
        (>&2 echo "Error: option -s needs a number," \
                  "got $ssh_port instead.")
        exit 1
      elif ! [[ "$ssh_port" -gt 0  && "$ssh_port" -le 65536 ]]; then
        (>&2 echo "Error: option -s is for an ssh_port:" \
                  "0 < ssh_port <= 65536. Got $ssh_port instead.")
        exit 1
      fi
      ;;
    S)
      shadowsocks_server_port="$OPTARG"

      int_regex='^[0-9]+$'
      if ! [[ "$shadowsocks_server_port" =~ $int_regex ]] ; then
        (>&2 echo "Error: option -s needs a number, " \
                  "got $shadowsocks_server_port instead.")
        exit 1
      elif ! [[ "$shadowsocks_server_port" -gt 0  && \
                "$shadowsocks_server_port" -le 65536 ]]; then
        (>&2 echo "Error: option -S is for Shadowsocks server's port, and " \
                  "it must be 0 < S <= 65536." \
                  "Got $shadowsocks_server_port instead.")
        exit 1
      fi
      ;;
    \?)
      (>&2 echo "Invalid option: -$OPTARG")
      ;;
    :)
      (>&2 echo "Option -$OPTARG requires an argument.")
      exit 1
      ;;
  esac
done

if $flag_help; then
  usage
  exit 0
fi

options=()
if [[ "$ssh_port" -gt 0 ]]; then
  options+=(--extra-vars "{\"ssh_server_ports\": [$ssh_port] }")
fi

if [[ "$shadowsocks_server_port" -gt 0 ]]; then
  options+=(--extra-vars "{\"shadowsocks_server_port\": $shadowsocks_server_port}")
fi

set -x
# shellcheck disable=SC2086
ansible-playbook -v \
                 -i inventories/production/hosts \
                   --ask-vault-pass -e@inventories/production/group_vars/shadowsocks-servers.vault.yml \
                   ${options[*]:-} \
                    install_shadowsocks.yml

exit 0
