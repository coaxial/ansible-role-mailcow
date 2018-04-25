import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_firewall_ports(host):
    ports = [25, 80, 110, 143, 443, 465, 587, 993, 995, 4190]

    for port in ports:
        assert host.ansible("ufw",
                            "rule=allow port=%s state=present" % port
                            )["changed"] is False


def test_timesync(host):
    f = host.file('/etc/systemd/timesyncd.conf')

    assert f.contains(r"0\.pool\.ntp\.org")
    assert f.user == 'root'
    assert f.group == 'root'
    assert f.mode == 0o0644


def test_borgmatic_files(host):
    ssh_pub_key = host.file('/opt/docker-borgmatic/borgmatic/borg_ssh_key.pub')
    ssh_pri_key = host.file('/opt/docker-borgmatic/borgmatic/borg_ssh_key')
    passphrase = host.file('/opt/docker-borgmatic/borgmatic/passphrase')
    config = host.file('/opt/docker-borgmatic/borgmatic/config.yaml')
    jobber = host.file('/opt/docker-borgmatic/borgmatic/.jobber')
    run_borgmatic = host.file(
        '/opt/docker-borgmatic/borgmatic/run-borgmatic.sh'
    )

    for file in [ssh_pub_key, ssh_pri_key, passphrase, config, jobber]:
        assert file.exists
        assert file.mode == 0o0400
        assert file.user == 'root'
        assert file.group == 'root'

    assert run_borgmatic.mode == 0o500


def test_mailcow_files(host):
    settings = host.file('/opt/mailcow-dockerized/mailcow.conf')
    backup_dir = host.file('/var/backup')

    assert settings.exists
    assert settings.mode == 0o0400
    assert settings.user == 'root'
    assert settings.group == 'root'

    assert backup_dir.exists
    assert backup_dir.mode == 0o0777
    assert backup_dir.user == 'root'
    assert backup_dir.group == 'root'


def test_backup_cron(host):
    crontab = host.file('/var/spool/cron/crontabs/root')

    assert crontab.contains(r"helper-scripts/backup_and_restore.sh backup all")


def test_swap(host):
    swapfile = host.file('/swapfile')
    swappiness = host.sysctl('vm.swappiness')
    pressure = host.sysctl('vm.vfs_cache_pressure')
    sysctl_file = host.file('/etc/sysctl.conf')

    assert swapfile.exists
    assert swapfile.mode == 0o0600
    assert swapfile.user == 'root'
    assert swapfile.group == 'root'

    assert sysctl_file.contains(r"vm\.swappiness=10")
    assert swappiness == 10
    assert sysctl_file.contains(r"vm\.vfs_cache_pressure=50")
    assert pressure == 50
