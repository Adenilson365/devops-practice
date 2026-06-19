### DNS register

| Tipo     | Nome                                  | Função                                                                | Exemplo                                          |
| -------- | ------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------ |
| `A`      | Address Record                        | Aponta um nome para um endereço IPv4                                  | `www IN A 192.168.56.51`                         |
| `AAAA`   | IPv6 Address Record                   | Aponta um nome para um endereço IPv6                                  | `www IN AAAA 2001:db8::10`                       |
| `CNAME`  | Canonical Name                        | Cria um alias para outro nome DNS                                     | `blog IN CNAME www.ade.local.`                   |
| `MX`     | Mail Exchange                         | Define o servidor responsável por receber e-mails do domínio          | `@ IN MX 10 mail.ade.local.`                     |
| `TXT`    | Text Record                           | Armazena textos usados para verificação, SPF, DKIM, DMARC etc.        | `@ IN TXT "v=spf1 include:_spf.google.com ~all"` |
| `NS`     | Name Server                           | Define quais servidores DNS são autoritativos pela zona               | `@ IN NS ns1.ade.local.`                         |
| `SOA`    | Start of Authority                    | Define informações principais da zona DNS                             | `@ IN SOA ns1.ade.local. admin.ade.local. (...)` |
| `PTR`    | Pointer Record                        | Faz resolução reversa: IP para nome                                   | `51 IN PTR apache.ade.local.`                    |
| `SRV`    | Service Record                        | Indica host e porta de um serviço específico                          | `_ldap._tcp IN SRV 10 5 389 ldap.ade.local.`     |
| `CAA`    | Certification Authority Authorization | Define quais autoridades podem emitir certificados TLS para o domínio | `@ IN CAA 0 issue "letsencrypt.org"`             |
| `NAPTR`  | Naming Authority Pointer              | Usado em serviços como SIP, ENUM e telecom                            | `@ IN NAPTR ...`                                 |
| `DS`     | Delegation Signer                     | Usado em DNSSEC para delegar confiança entre zonas                    | `ade.local. IN DS ...`                           |
| `DNSKEY` | DNS Public Key                        | Publica chaves públicas usadas pelo DNSSEC                            | `ade.local. IN DNSKEY ...`                       |
| `TLSA`   | TLS Authentication                    | Associa certificado TLS a nome/porta, usado com DANE                  | `_443._tcp.www IN TLSA ...`                      |

### Most Common

| Tipo    | Uso comum                                |
| ------- | ---------------------------------------- |
| `A`     | Apontar domínio para servidor IPv4       |
| `AAAA`  | Apontar domínio para servidor IPv6       |
| `CNAME` | Criar alias                              |
| `MX`    | Configurar e-mail                        |
| `TXT`   | Verificação de domínio, SPF, DKIM, DMARC |
| `NS`    | Delegação/autoritativo da zona           |
| `SOA`   | Controle da zona                         |
| `PTR`   | DNS reverso                              |
