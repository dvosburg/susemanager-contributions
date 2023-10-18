copy_file_to_etc_if_not_there:
  file.copy:
    - name: /etc/transactional-update.conf
    - source: /usr/etc/transactional-update.conf

transactional_update_set_rebootmethod_systemd:
  file.keyvalue:
    - name: /etc/transactional-update.conf
    - key_values:
       REBOOT_METHOD: 'systemd'
       ZYPPER_AUTO_IMPORT_KEYS: '1'
    - separator: '='
    - uncomment: '# '
    - append_if_not_found: True
