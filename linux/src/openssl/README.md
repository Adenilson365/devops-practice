### Comandos

- Pegar o cerfiticado rais de um servidor

```sh
echo | openssl s_client -connect google.com:443  2>/dev/null | openssl x509
```
