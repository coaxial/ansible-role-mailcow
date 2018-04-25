# shellcheck shell=sh
#!/usr/bin/with-contenv sh

timestamp() {
  # ISO-8601 format
  date -I'seconds'
}

notify_admin() {
  # TODO
  touch /dev/null
}

notify_admin
echo "$(timestamp) - Backup failed"
