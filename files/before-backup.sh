# shellcheck shell=sh
#!/usr/bin/with-contenv sh

COMPRESSED_BACKUPS_PATH="$(find /backup \( -type d -name 'mailcow-*' \) | sort | tail -n 1)"
DECOMPRESSED_BACKUPS_PATH=/backup/mailcow/

timestamp() {
  date -I'seconds' # ISO-8601 format
}

extract_files() {
  if [ -d ${DECOMPRESSED_BACKUPS_PATH} ]; then
    rm -rf ${DECOMPRESSED_BACKUPS_PATH}
  fi
  mkdir ${DECOMPRESSED_BACKUPS_PATH}

  TGZ_FILES="$(find "${COMPRESSED_BACKUPS_PATH}" \( -type f -name 'backup_*.tar.gz' \))"
  GZ_FILE="$(find "${COMPRESSED_BACKUPS_PATH}" \( -type f -name backup_mysql.gz \))"
  for tgz in ${TGZ_FILES}; do
    tar xzf "${tgz}" -C ${DECOMPRESSED_BACKUPS_PATH}
  done

  zcat "${GZ_FILE}" > ${DECOMPRESSED_BACKUPS_PATH}/backup_mysql
}

echo "$(timestamp) - Starting backup"
extract_files
