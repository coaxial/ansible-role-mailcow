import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_backup_service_dir(host):
    f = host.file('/opt/docker-borgmatic')

    assert not f.exists


def test_backup_dir(host):
    d = host.file('/var/backup')

    assert not d.exists
