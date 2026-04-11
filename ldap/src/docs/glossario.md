- ldap = protocolo para manipulação de dados em diretórios/árvores (hierarquicos). Eficiente em leituras.
- ldif = LDAP Data Interchange Format
  - Extensão dos arquivos de configuração LDAP, cada bloco representa um objeto na árvore
- dn = Distinguished Name
  - É o caminho completo do objeto na árvore do LDAP, composto por pares key=value
  - A navegação é do menor nível para o topo.
  - Exemplo:
    ```
    dn: uid=joao,ou=users,dc=knz,dc=dev,dc=br
    dc=br
    └── dc=dev
        └── dc=knz
            └── ou=users
                └── uid=joao
    ```
- objetctClass = Definine o tipo de objeto e quais atributos ele precisa ou pode ter
  - Pode ter múltiplos objectClass em um DN, e herdar seus comportamentos
- top = Classe base e raiz de todos os objetos LDAP
- dc = domain component
  - representa um domínio dns: `dc=knz,dc=dev,dc=br` `knz.dev.br`
- **ou** = Organizational Unit
  - Representa um diretório ou pasta onde coloco objetos
  - exemplos ou: users,groups,computers
- **cn** = common name
  - Nome principal do objeto
  - Nem sempre único por isso existe uid
- **uid** = User ID ( Identificador único de usuário)
