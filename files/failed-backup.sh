# shellcheck shell=sh
#!/usr/bin/with-contenv sh

timestamp() {
  date -I'seconds' # ISO-8601 format
}

notify_admin() {
  # TODO
  touch /dev/null
}

notify_admin
echo "$(timestamp) - Backup failed"
