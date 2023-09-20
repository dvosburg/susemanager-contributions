install_apache2_software:
  pkg.installed:
{%- if grains['os_family'] == 'RedHat' %}
    - name: httpd
{%- else %}
    - name: apache2
{%- endif %}
    
apache_service:
  service.running:
{%- if grains['os_family'] == 'RedHat' %}
    - name: httpd
{%- else %}
    - name: apache2
{%- endif %}
    - enable: True

disable_firewall:
  service.dead:
{%- if grains['os_family'] == 'Suse' and grains['osmajorrelease'] <= 12 %}
    - name: SuSEfirewall2
{%- else %}
    - name: firewalld
{%- endif %}
    - enable: False

enforce_desired_index_html:
  file.managed:
    - source: salt://manager_org_4/apache_web_server/srv/www/htdocs/index.html
{%- if grains['os_family'] == 'Suse' %}
    - name: /srv/www/htdocs/index.html
{%- else %}
    - name: /var/www/html/index.html
{%- endif %}
