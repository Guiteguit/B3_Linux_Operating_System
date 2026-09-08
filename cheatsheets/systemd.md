# Cheat sheet — systemd

```bash
systemctl status <service>
systemctl start <service>
systemctl stop <service>
systemctl restart <service>
systemctl reload <service>
systemctl enable <service>
systemctl disable <service>
systemctl is-active <service>
systemctl is-enabled <service>
systemctl daemon-reload
journalctl -u <service>
```

`start` agit maintenant. `enable` agit sur le prochain boot. `daemon-reload` recharge les fichiers d'unités.
