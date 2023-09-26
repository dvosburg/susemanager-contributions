set_transactional_update_reboot_beacons_conf:
  file.managed:
{%- if salt['file.directory_exists']('/etc/venv-salt-minion') %}
    - name: /etc/venv-salt-minion/minion.d/beacons.conf
{%- else %}
    - name: /etc/salt/minion.d/beacons.conf
{%- endif %}
    - user: root
    - group: root
    - mode: 655
    - template: jinja
    - source: salt://manager_org_1/beacon-for-slemicro/etc/venv-salt-minion/minion.d/beacons.conf
