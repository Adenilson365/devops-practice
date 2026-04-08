### LDAP com OpenLDAP

- Instalar slapd no centOS 9
- [Documentação](https://www.ibm.com/docs/pt-br/rpa/23.0.x?topic=ldap-installing-configuring-openldap#installing-openldap-on-linux)
- Passos
  - Instale o repositório epel, depois os pacotes
    ```shell
    sudo dnf install epel-release
    sudo dnf -y install openldap openldap-servers openldap-clients
    ```
  - Inicie o serviço e liberar firewall

    ```shell
    sudo systemctl start slapd.service
    sudo systemctl enable slapd.service
    sudo firewall-cmd --permanent --add-port=389/tcp --add-port=389/udp
    sudo firewall-cmd --reload
    sudo setsebool -P allow_ypbind=1 authlogin_nsswitch_use_ldap=1
    sudo setsebool -P httpd_can_connect_ldap on

    ```

  - Arquivo de configuração em:
    ```shell
    vim /etc/openldap/ldap.conf
    ```
