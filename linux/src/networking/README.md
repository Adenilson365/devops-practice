# Networking

### Comandos
- Listar interfaces: `ip link` ou `ip addr`
  - `UP` Interface habilitada administrativamente
  - `LOWER_UP` Kernel detectou link funcionando na camada física/virtual
- Adicionar ip secundário a interface `sudo ip addr add 192.168.10.20/24 dev eth0` remover `sudo ip addr del 192.168.10.20/24 dev eth0`

| Objetivo | Comando |
|---|---|
| Ver interfaces | `ip link` |
| Ver IPs | `ip addr` |
| Ver rotas | `ip route` |
| Descobrir rota real | `ip route get 8.8.8.8` |
| Ver ARP/neighbors | `ip neigh` |
| Ver sockets | `ss -tulpn` |
| Ver conexões TCP | `ss -ntp` |
| Testar DNS | `dig dominio.com` |
| Resolver como aplicação | `getent hosts dominio.com` |
| Testar conectividade | `ping IP` |
| Ver caminho | `traceroute IP` |
| Testar porta TCP | `nc -vz IP porta` |
| Capturar pacotes | `tcpdump` |
| Configuração NetworkManager | `nmcli` |
| Ver DNS systemd | `resolvectl` |
| Ver firewall | `nft list ruleset` |
| Ver parâmetros do kernel | `sysctl` |
| Ver namespaces | `ip netns list` |
| Ver estatísticas NIC | `ip -s link` |
| Ver driver/hardware | `ethtool eth0` |