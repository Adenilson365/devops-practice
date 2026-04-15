### LDAP com OpenLDAP

#

### Objetivo

- Adquirir um conhecimento de base sobre LDAP, compreender seu funcionamento e cria rum laboratório sobre para fixar conceitos.
- Não tem intenção de se tornar admin de ldap
- Gerar melhor entendimento para facilitar uso e integração com outros sistemas de autenticação
- Diferenciar suas funcionalidades
- Fortalecer os conceitos de Autorização e Autenticação.

#

- Instalar slapd no centOS 9
  - [Documentação](https://www.ibm.com/docs/pt-br/rpa/23.0.x?topic=ldap-installing-configuring-openldap#installing-openldap-on-linux)
  - [Documentação Opeldap](https://www.openldap.org/doc/)

  - Para instalar o slapd, rode o script install-ldap.sh
  - Arquivos de configuração (obs: Arquivos são alterados via ldapmodify)
  - /etc/openldap/slapd.d/cn=config

#

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
ldapadd -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
ldapadd -H ldapi:/// -f /etc/openldap/schema/nis.ldif

```

- Adicionar o base e a entry do usuário

```shell
ldapadd -x -W -D "cn=ldapadm,dc=knz,dc=dev,dc=br" -f base.ldif

# W -> Aceitar a senha no shell
# D -> Passar o dn do usuário root do ldap
```

- Adicionar user-groups

```shell
ldapmodify -H ldapi:/// -f acl.ldif
ldapadd -H ldapi:/// -f group.ldif
ldapadd -H ldapi:/// -f add-member-to-group.ldif
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

- Testar se o usuário está funcional
  > Rode no ldap-server e use a senha criada para o usuário

```shell
ldapwhoami -x -D "uid=joao,ou=Marketing,o=filial-rs,c=BR,dc=knz,dc=dev,dc=br" -W
#saida esperada: dn:uid=joao,ou=Marketing,o=filial-rs,c=BR,dc=knz,dc=dev,dc=br
```

### Denbian-Client

- Instale com os comandos do install-client.sh
- Busca de usuário

```shell
ldapsearch  192.168.56.20 -x o=* -b c=BR,dc=knz,dc=dev,dc=br
```

- Configurar
  > Ao Instalar o lib-pam vai solicitar informações sobre o ad e pre configurar.
- Valide o: `vim /etc/nsswitch.conf`
  - Precisa conter a ordem de autenticação do usuário, tenha login local, senão for possível chama o ldap

```shell
passwd:         files systemd ldap
group:          files systemd ldap
shadow:         files systemd ldap

```

- Edite o common_session para adicionar a função de criar diretório quando logar com ad, adicione ao `/etc/pam.d/common-session` a linha: `session required        pam_mkhomedir.so skel=/etc/skel umask=077 `

- Logs de autenticação no debian via journalctl -f

```log
Apr 10 09:34:50 client-debian nslcd[32922]: [4a3fe6] <passwd="joao"> (re)loading /etc/nsswitch.conf
Apr 10 09:34:50 client-debian nslcd[32922]: [f9c13c] <passwd="pam_unix_non_existent:"> request denied by validnames option
Apr 10 09:35:00 client-debian su[33385]: pam_unix(su-l:auth): authentication failure; logname=vagrant uid=1000 euid=0 tty=/dev/pts/2 ruser=vagrant rhost=  user=joao
Apr 10 09:35:00 client-debian su[33385]: (to joao) vagrant on pts/2
Apr 10 09:35:00 client-debian su[33385]: pam_unix(su-l:session): session opened for user joao(uid=9999) by vagrant(uid=1000)

```

### Vagrant

- [Registry](https://portal.cloud.hashicorp.com/vagrant/discover)
