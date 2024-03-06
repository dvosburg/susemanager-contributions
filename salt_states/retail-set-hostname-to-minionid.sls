set_hostname_to_minion_id:
  cmd.run:
    - name: hostset=`cat /etc/venv-salt-minion/minion_id | sed 's/\./-/'` && hostnamectl set-hostname $hostset
