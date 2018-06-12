# `mailcow` role
[![Build Status](https://travis-ci.org/coaxial/ansible-role-mailcow.svg?branch=master)](https://travis-ci.org/coaxial/ansible-role-mailcow)

This playbook will setup a mailcow email server and hourly borg backups (optional, see Variables to disable)
Backups are saved to `/var/backup` and removed once handled by borg.
The last 24 hourly, 7 daily, 4 weekly, 6 monthly and 1 yearly backups are kept.

Min config for the mailcow host is 1Ghz CPU, 1GB RAM, 5GB disk. Recommended is 1.5GB RAM + swap if clamd is enabled. Plan additional storage space for generating the hourly backup, and for the optional swap file (1x the RAM)

## Prerequisites

- Up and running Ubuntu host (other distros not supported for now)
- Docker
- A borg backup repository if backups are enabled (cf. https://borgbackup.readthedocs.org/en/latest/quickstart.html)
- SSH keys and passphrase matching the borg repo

## Variables

name | purpose | default value | note
---|---|---|---
`mailcow__hostname` | set the `MAILCOW_HOSTNAME` in `mailcow.conf` (cf. https://mailcow.github.io/mailcow-dockerized-docs/install/) | not set | must be set
`mailcow__additional_san` | set the `ADDITIONAL_SAN` in `mailcow.conf` to allow for extra domains (cf. https://mailcow.github.io/mailcow-dockerized-docs/firststeps-ssl/#additional-domain-names) | undefined, optional | comma separated values: `lala.example.com,yay.example.org` (do not repeat the `mailcow__hostname`)
`mailcow__skip_known_hosts` | whether to use a custom `known_hosts` file for the borgmatic backups | `false` | `true` or `false`, lets the borgmatic container connect to a remote borg repo without prompting about accepting the key
`mailcow__dbpass` | set the `dbpass` in `mailcow.conf` (cf. https://mailcow.github.io/mailcow-dockerized-docs/install/) | not set | must be set
`mailcow__dbroot` | set the `dbroot` in `mailcow.conf` (cf. https://mailcow.github.io/mailcow-dockerized-docs/install/) | not set | must be set
`mailcow__http_port` | set the `HTTP_PORT` in `mailcow.conf` (cf. https://mailcow.github.io/mailcow-dockerized-docs/install/) | `80`
`mailcow__http_bind` | set the `HTTP_BIND` in `mailcow.conf` (cf. https://mailcow.github.io/mailcow-dockerized-docs/install/) | `0.0.0.0`
`mailcow__https_port` | set the `HTTPS_PORT` in `mailcow.conf` (cf. https://mailcow.github.io/mailcow-dockerized-docs/install/) | `443`
`mailcow__https_bind` | set the `HTTPS_BIND` in `mailcow.conf` (cf. https://mailcow.github.io/mailcow-dockerized-docs/install/) | `0.0.0.0`
`mailcow__tz` | set the `TZ` in `mailcow.conf` | `UTC` | [list of possible values](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
`mailcow__skip_le` | set the `SKIP_LETS_ENCRYPT` in `mailcow.conf` | `n` | `y` or `n`
`mailcow__skip_clamd` | set the `SKIP_CLAMD` in `mailcow.conf` | `n` | `y` or `n`
`mailcow__ssh_key_name` | filename for the ssh keys to use with borg (i.e. if the keys are named `mykey_rsa` and `mykey_rsa.pub`, this variable should be set to `mykey_rsa`) | `borg_ssh_key`
`mailcow__borg_repo_host` | indicate where the borg repo is hosted (i.e. the part before `:` in a borg repo URL) | not set | must be set (i.e. `user@my.borghost.tld`)
`mailcow__borg_repo_name` | name for the borg repo, i.e. the part after `:` and before `::` in a borg repo URL | `mailcow` | i.e. `myrepo` from `user@my.borghost.tld:myrepo::backupname`
`mailcow__ntp_servers` | override default ntp servers for synchronizing the time on the docker host. | `0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org` | must be a string of space separated hostnames/FQDNs/IPs
`mailcow__enable_swap` | use a swap file (recomended for hosts with less than 3GB of RAM) | `true` | will create a swapfile at /swapfile that is the same size as the amoung of RAM on the host
`mailcow__enable_backups` | enable hourly backups to a borg repository | `true` | set to `true` or `false`
`mailcow__git_version` | checkout a specific version of mailcow | `master` | any commit, branch name, or tag from the mailcow git repo


## Files

In the `files/` directory:

name | purpose | note
---|---|---
`borg_ssh_key{,.pub}` | ssh keys for connecting to the remote borg repo (set the `mailcow__ssh_key_name` if not using the default name). | only used if `mailcow__enable_backups` is set to `true`
`passphrase` | remote borg repo passphrase | only if `mailcow__enable_backups`
`known_hosts` | custom known_hosts file for the borgmatic container to avoid unknown key errors | cf. `mailcow__skip_known_hosts` variable above. To get an up to date key for your server, run `ssh-keyscan 93.184.216.34`. Only used if `mailcow__enable_backups` is `true`

## Backups

If `mailcow__enable_backups` is set, backups will be generated every hour on the hour using the [mailcow backup script](https://github.com/mailcow/mailcow-dockerized/blob/master/helper-scripts/backup_and_restore.sh).

The [docker-borgmatic](https://github.com/coaxial/docker-borgmatic) container will send the backup to the specified borg repo every hour at 30 past and clean up the backup directory after it. For remote borg repos, [rsync.net](http://www.rsync.net/products/attic.html) is pretty good.

## Usage

Minimal playbook:

```yaml
---
- hosts: all
  become: true
  gather_facts: false
  vars:
    mailcow__borg_repo_host: user@example.com
    mailcow__hostname: test
    mailcow__dbpass: test
    mailcow__dbroot: test
    rawpython__os_family: Debian

  roles:
    - coaxial.raw-python  # bootstrap python on bare Ubuntu/Debian
    - coaxial.mailcow
```
