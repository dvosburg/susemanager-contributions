ubuntu_grub_mkconfig_alias:
  file.symlink:
    - name: /usr/sbin/grub2-mkconfig
    - target: /usr/sbin/grub-mkconfig
    - onlyif:
      - test ! -L  /usr/sbin/grub2-mkconfig

ubuntu_grub_directory_alias:
  file.symlink:
    - name: /boot/grub2
    - target: /boot/grub
    - onlyif:
      - test ! -L /boot/grub2
