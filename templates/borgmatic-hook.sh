# shellcheck shell=sh
#!/usr/bin/with-contenv sh

export BORG_REMOTE_PATH=borg1
export BORG_PASSCOMMAND='cat /borgmatic/passphrase'
export BORG_RSH='ssh -i /borgmatic/{{ mailcow__ssh_key_name }}'
export BORG_CACHE_DIR='/cache'
repo_server_string='mailcow__borg_repo_host'
repo_name='{{ mailcow__borg_repo_name }}'

last_backup_name() {
# BORG_REMOTE_PATH=borg1 BORG_PASSCOMMAND="cat /borgmatic/passphrase" BORG_RSH='ssh -i /borgmatic/backup_rsa'
  borg list --short --last 1 "${repo_server_string}:${repo_name}"
}

timestamp() {
  # ISO-8601 format
  date -I'seconds'
}

last_backup_info() {
  borg info "${repo_server_string}:${repo_name}::$(last_backup_name)"
}

last_backup_info
