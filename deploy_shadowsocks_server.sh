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
  deploy_shadowsocks_server.sh [options] [-s <ssh_port>] [-S <ssserver_port>]

Deploy a BOINC server.

Options:
  -h                            Show this help and exits.
  -s <ssh_port>                 SSH server port [default: 22].
  -S <ssserver_port>            Shadowsocks server port [default: 443].

Example:
  deploy_shadowsocks_server.sh"
}

flag_help=false
ssh_port=22
ssserver_port=443
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
      ssserver_port="$OPTARG"

      int_regex='^[0-9]+$'
      if ! [[ "$ssserver_port" =~ $int_regex ]] ; then
        (>&2 echo "Error: option -s needs a number, " \
                  "got $ssserver_port instead.")
        exit 1
      elif ! [[ "$ssserver_port" -gt 0  && \
                "$ssserver_port" -le 65536 ]]; then
        (>&2 echo "Error: option -S is for Shadowsocks server's port, and " \
                  "it must be 0 < S <= 65536." \
                  "Got $ssserver_port instead.")
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

if [[ "$ssserver_port" -gt 0 ]]; then
  options+=(--extra-vars "{\"shadowsocks_server_port\": $ssserver_port}")
fi

set -x
# shellcheck disable=SC2086
ansible-playbook -v \
                 -i inventories/production/hosts \
                   --ask-vault-pass -e@inventories/production/group_vars/shadowsocks-servers.vault.yml \
                   ${options[*]:-} \
                    install_shadowsocks.yml

exit 0
