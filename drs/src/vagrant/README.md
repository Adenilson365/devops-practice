### Instalação

[gcc](https://docs.aws.amazon.com/drs/latest/userguide/agent-install-linux-errors.html#error-gcc-not-found)
[Kernel](https://docs.aws.amazon.com/drs/latest/userguide/troubleshooting/DRS-INST-003)

- Verificar versão

```
uname -r
dpkg -l | grep linux-image
dpkg -l | grep linux-headers
```

- Atualizar headers

```
apt update \
apt install -y \
  linux-image-amd64 \
  linux-headers-amd64

```

- Validar trafego

```
# Porta
ss -ntp
tcpdump -nn port 1500
```

- inicio 08:29
