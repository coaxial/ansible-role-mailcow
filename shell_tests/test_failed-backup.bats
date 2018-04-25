#!./lib/bats/bin/bats

load 'lib/bats-support/load'
load 'lib/bats-assert/load'
load 'helpers/mocks/stub'

stub date \
  "-I'seconds' : echo 2018-04-25T18:34:43-04:00"

@test "Should echo a timestamp and a message" {
  assert_equal "$(sh -c ./templates/failed-backup.sh)" "2018-04-25T18:34:43-04:00 - Backup failed"
}
