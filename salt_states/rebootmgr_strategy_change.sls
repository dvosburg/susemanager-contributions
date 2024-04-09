copy_file_to_etc_if_not_there:
  file.copy:
    - name: /etc/transactional-update.conf
    - source: /usr/etc/transactional-update.conf
    
transactional_update_set_rebootmethod_rebootmgr:
  file.keyvalue:
    - name: /etc/transactional-update.conf
    - key_values:
       REBOOT_METHOD: 'rebootmgr'
    - separator: '='
    - uncomment: '# '
    - append_if_not_found: True

rebootmgr_strategy_change:
  file.keyvalue:
    - name: /etc/rebootmgr.conf
    - key_values:
       strategy: 'instantly'
       window-duration: '23h59m'
    - separator: '='
    - uncomment: '# '
    - append_if_not_found: True

append_to_tukit_config:
  file.keyvalue:
    - name: /etc/tukit.conf
    - key_values:
       BINDDIRS[1]: '"/run/dbus"'
    - separator: '='
    - uncomment: '# '
    - append_if_not_found: True
