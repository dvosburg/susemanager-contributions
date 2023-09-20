update_pkg:
  pkg.uptodate:
    - refresh : True
    - novendorchange: False
    
int_reboot_if_needed:
  cmd.run:
    - name: shutdown -r +5
{%- if grains['os_family'] == 'RedHat' and grains['osmajorrelease'] >= 8 %}
    - onlyif: 'dnf -q needs-restarting -r; [ $? -eq 1 ]'
{%- elif grains['os_family'] == 'RedHat' and grains['osmajorrelease'] <= 7 %}
    - onlyif: 'needs-restarting -r; [ $? -eq 1 ]'
{%- elif grains['os_family'] == 'Debian' %}
    - onlyif: 
      - test -e /var/run/reboot-required
{%- elif grains['os_family'] == 'Suse' and grains['osmajorrelease'] <= 12 %}
    - onlyif:
      - test -e /boot/do_purge_kernels
{%- else %}
    - onlyif: 'zypper ps -s; [ $? -eq 102 ]'
{%- endif %}
