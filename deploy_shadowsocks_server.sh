#!/usr/bin/env bash

# shellcheck disable=SC2128
SOURCED=false && [ "$0" = "$BASH_SOURCE" ] || SOURCED=true

if ! $SOURCED; then
  set -euo pipefail
  IFS=$'\n\t'
fi

if [ "$#" -lt 1 ]; then
  (>&2 echo "Error. Missing argument.")
  (>&2 echo "Usage:")
  (>&2 echo "deploy_shadowsocks_server.sh <ssh_port> <shadowsocks_port>")
fi

ansible-playbook -v \
                 -i inventories/production \
                 --ask-vault-pass -e@inventories/production/group_vars/shadowsocks-servers.vault.yml \
                 --extra-vars "ssh_server_ports=[$1] shadowsocks_server_port=$2" \
                    install_shadowsocks.yml 
