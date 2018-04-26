#shellcheck shell=sh
#!/usr/bin/with-contenv sh

COMPRESSED_BACKUPS_PATH="$(find /backup \( -type d -name 'mailcow-*' \) | sort | tail -n 1)"
DECOMPRESSED_BACKUPS_PATH=/backup/mailcow/

timestamp() {
  date -I'seconds' #ISO-8601 format
}

cleanup() {
  rm -rf "${COMPRESSED_BACKUPS_PATH}" ${DECOMPRESSED_BACKUPS_PATH}
}

last_backup_info() {
  export BORG_REMOTE_PATH=borg1
  export BORG_PASSCOMMAND='cat /borgmatic/passphrase'
  export BORG_RSH='ssh -i /borgmatic/{{ mailcow__ssh_key_name }}'
  export BORG_CACHE_DIR='/cache'
  # vars will be replaced by Ansible's templating engine
  # shellcheck disable=SC1083
  last_backup_name="$(borg list --short --last 1 {{ mailcow__borg_repo_host }}:{{ mailcow__borg_repo_name }})"

  # BORG_REMOTE_PATH=borg1 BORG_PASSCOMMAND="cat /borgmatic/passphrase" BORG_RSH='ssh -i /borgmatic/backup_rsa'

  borg info "{{ mailcow__borg_repo_host }}:{{ mailcow__borg_repo_name }}::${last_backup_name}"
}

last_backup_info
cleanup
echo "$(timestamp) - Backup completed"
