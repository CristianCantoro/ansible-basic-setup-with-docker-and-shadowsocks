ansible-basic-setup-with-docker-and-shadowsocks
-----------------------------------------------

This is an ansible playbook to setup a new machine with Docker and deploy a
container with shadowsocks.

Most of the task are separated into roles that could be split from this
repository, but I still have to figure out how to organize everything so that
it is easily reusable.

## Workflow

1. Update root password and add SSH key (role: `add-user`).

2. Enable locales (role: `locales`).

3. Set new hostname (role: `set-hostname`).

4. Resize boot partition (role: `resize-boot-partition`).

5. Add swap (role: `swap`).

6. Upgrade system (role: `upgrade-release`).

7. Install basic packages (role: `install-basics`).

8. Install Docker (role: `ansible-docker`).

9. Add shadowsocks user (role: `add-user`).

10. Secure SSH (role: `secure-ssh`).

11. Enable UFW (role: `set-ufw`).

12. Deploy docker container for shadowsocks (role: `deploy-docker-shadowsocks-libev`).


## Roles:

* `add-user`:
  ensure a user exists in the system, adding it if needed and add your SSH key
  to the file `authorized_keys` of sadi user. Optionally, set a new random
  password for the user.

* `ansible-docker`:
  [nickjj's ansible-docker](https://github.com/nickjj/ansible-docker.git) role,
  with [PR #19](https://github.com/nickjj/ansible-docker/pull/19) applied.

* `ansible-ssh-hardening`:
  [dev-sec's ansible-ssh-hardening](https://github.com/dev-sec/ansible-ssh-hardening.git)
  role.

* `deploy-docker-shadowsocks-libev`:
  ensure [docker compose](https://docs.docker.com/compose/) is installed and
  [EasyPi's docker-shadowsocks-libev](https://github.com/EasyPi/docker-shadowsocks-libev)
  docker container is deployed.

* `install-basics`:
  ensure a list of basic packages are installed.

* `locales`:
  ensure a list of locales are activated and generated.

* `reboot`:
  reboot the machine (role not used at the moment).

* `resize-boot-partition`:
  resize the boot partion if necessary and if there is a swap partition after
  it that can be shrinked.

* `root-password-change`:
  change root password (role not used at the moment).

* `secure-ssh`:
  this is a meta-role to make ssh secure
    * apply `ansible-ssh-hardening`.
    * disable X11 forwarding.
    * apply `ssh-filter`.

* `set-hostname`:
  ensure that the hostname of the machine is set
    * get current hostname.
    * set system's hostname.
    * ensure /etc/hostname file has the same hostname.
    * ensure /etc/hosts file has the same hostname.

* `set-ufw`:
  set [Uncomplicated FireWall (UFW)](http://gufw.org/) policy and enable UFW
  with custom UFW ports.

* `ssh-filter`:
  apply geoip filtering to ssh [ssh-geoip-filter](https://github.com/CristianCantoro/ssh-geoip-filter)

* `swap`:
  add swap space (as per this [DigitalOcean tutorial](https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04)),
  and set `swappiness` and `vfs_cache_pressure`.

* `upgrade-release`:
  Upgrade Ubuntu release up to Ubuntu 16.04 LTS.
