#!./lib/bats/bin/bats

load 'lib/bats-support/load'
load 'lib/bats-assert/load'
load 'helpers/mocks/stub'


@test "Should echo a timestamp and a message" {
  stub date \
    "-Iseconds : echo '2018-04-25T18:34:43-04:00'"
  stub mkdir "true"
  stub find "true"
  stub tar "true"
  stub gunzip "true"
  stub mv "true"

  run sh -c ./files/before-backup.sh
  assert_output "2018-04-25T18:34:43-04:00 - Starting backup"

  unstub date
  unstub mkdir
  unstub find
  unstub tar
  unstub gunzip
  unstub mv
}
