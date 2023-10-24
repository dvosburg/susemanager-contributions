ubuntu_grub_mkconfig_alias:
  cmd.run:
    - name: ln -s /usr/sbin/grub-mkconfig /usr/sbin/grub2-mkconfig

ubuntu_grub_directory_alias:
  cmd.run:
    - name: ln -s /boot/grub /boot/grub2
