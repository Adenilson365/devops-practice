### LDAP com OpenLDAP

- Instalar slapd no centOS 9
- [Documentação](https://www.ibm.com/docs/pt-br/rpa/23.0.x?topic=ldap-installing-configuring-openldap#installing-openldap-on-linux)

- Para instalar o slapd, rode o script install-ldap.sh
- Arquivos de configuração (obs: Arquivos são alterados via ldapmodify)
- /etc/openldap/slapd.d/cn=config

### Configurar LDAP

- Modificar o mdb com ldapmodify
  > É necessário cuidado extra com espaços no fim de linha

```shell
ldapmodify -H ldapi:/// -f db.ldif
```

### Vagrant

- [Registry](https://portal.cloud.hashicorp.com/vagrant/discover)
