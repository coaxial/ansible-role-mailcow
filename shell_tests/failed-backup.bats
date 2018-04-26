#!./lib/bats/bin/bats

load 'lib/bats-support/load'
load 'lib/bats-assert/load'
load 'helpers/mocks/stub'


@test "Should echo a timestamp and a message" {
  stub date \
    "-Iseconds : echo '2018-04-25T18:34:43-04:00'"

  run sh -c ./files/failed-backup.sh
  assert_output "2018-04-25T18:34:43-04:00 - Backup failed"

  unstub date
}
