### LDAP com OpenLDAP

- Instalar slapd no centOS 9
- [Documentação](https://www.ibm.com/docs/pt-br/rpa/23.0.x?topic=ldap-installing-configuring-openldap#installing-openldap-on-linux)
- [Documentação Opeldap](https://www.openldap.org/doc/)

- Para instalar o slapd, rode o script install-ldap.sh
- Arquivos de configuração (obs: Arquivos são alterados via ldapmodify)
- /etc/openldap/slapd.d/cn=config

### Configurar LDAP

- Modificar o mdb com ldapmodify
  > É necessário cuidado extra com espaços no fim de linha

```shell
ldapmodify -H ldapi:/// -f db.ldif
```

- Modificar o monitor com o ldapmodify

```shell
ldapmodify -H ldapi:/// -f monitor.ldif
```

- Pasta de schemas: `/etc/openldap/schema`
- Importar os schemas:

```shell
ldapadd -H ldapi:/// -f cosine.ldif
ldapadd -H ldapi:/// -f nis.ldif
ldapadd -H ldapi:/// -f inetorgperson.ldif

```

- Adicionar o base e a entry do usuário

```shell
ldapadd -x -W -D "cn=ldapadm,dc=knz,dc=dev,dc=br" -f base.ldif
# x -> senha comum
# W -> Aceitar a senha no shell
# D -> Passar o dn do usuário root do ldap
```

- Criar Senha usuário joao

```shell
ldappasswd -S -W -D "cn=ldapadm,dc=knz,dc=dev,dc=br" -x "uid=joao,ou=Marketing,o=filial-rs,c=BR,dc=knz,dc=dev,dc=br"
# S -> para inserir a nova senha do usuário
# W -> para pedir a senha do administrador
# -D -> para passar o DN do administrador
# -x -> para passar o DN do usuário que será criado senha
```

- Buscar usuário

```shell
ldapsearch -x cn=joao -b dc=knz,dc=dev,dc=br
```

### Vagrant

- [Registry](https://portal.cloud.hashicorp.com/vagrant/discover)
