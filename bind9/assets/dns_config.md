Arquivos:

```text
named.conf.local
```

é o arquivo onde você **declara que uma zona existe**.

```text
db.ade.local
```

é o arquivo onde você **define os registros DNS dessa zona**.

Pense assim:

```text
named.conf.local  -> índice / catálogo das zonas
db.ade.local      -> conteúdo da zona ade.local
```

---

# 1. `/etc/bind/named.conf.local`

```bash
sudo tee /etc/bind/named.conf.local >/dev/null <<'EOF'
// Insert zone configurations here
zone "ade.local" {
    type master;
    file "/etc/bind/zones/db.ade.local";
};
EOF
```

Esse arquivo diz ao BIND:

> “Eu sou responsável pela zona `ade.local`, e os registros dela estão no arquivo `/etc/bind/zones/db.ade.local`.”

## Bloco da zona

```conf
zone "ade.local" {
    type master;
    file "/etc/bind/zones/db.ade.local";
};
```

### `zone "ade.local"`

Define o nome da zona DNS.

Ou seja, o BIND vai responder por nomes como:

```text
ade.local
www.ade.local
apache.ade.local
ns1.ade.local
```

### `type master`

Significa que esse servidor é o **servidor primário/autoritativo** dessa zona.

Em outras palavras: ele tem a cópia principal dos registros DNS de `ade.local`.

Existem outros tipos, por exemplo:

```conf
type slave;
```

Usado quando outro BIND replica a zona a partir do servidor master.

### `file "/etc/bind/zones/db.ade.local"`

Diz onde está o arquivo real com os registros da zona.

Então, quando alguém pergunta:

```text
Qual é o IP de www.ade.local?
```

O BIND olha dentro de:

```text
/etc/bind/zones/db.ade.local
```

---

# 2. `/etc/bind/zones/db.ade.local`

Esse é o arquivo que contém os registros DNS.

```dns
$TTL 86400
```

## `$TTL 86400`

Define o TTL padrão dos registros da zona.

TTL significa **Time To Live**.

```text
86400 segundos = 24 horas
```

Isso quer dizer que um cliente ou resolvedor pode manter a resposta em cache por até 24 horas.

Por exemplo, se alguém consulta:

```text
www.ade.local -> 192.168.56.51
```

essa resposta pode ficar cacheada por 86400 segundos.

Em laboratório, você pode usar um TTL menor:

```dns
$TTL 300
```

Isso equivale a 5 minutos e facilita testes.

---

# 3. Registro SOA

```dns
@   IN  SOA ns1.ade.local. admin.ade.local. (
        2026061901 ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400      ; Negative Cache TTL
)
```

O SOA significa **Start of Authority**.

Ele é obrigatório em uma zona DNS. Ele diz:

> “Esta é a origem autoritativa da zona `ade.local`.”

## `@`

Dentro de um arquivo de zona, `@` representa o nome da própria zona.

Como o arquivo é da zona:

```text
ade.local
```

então:

```dns
@
```

significa:

```text
ade.local.
```

Essa linha:

```dns
@ IN SOA ns1.ade.local. admin.ade.local.
```

equivale a:

```dns
ade.local. IN SOA ns1.ade.local. admin.ade.local.
```

## `IN`

Significa **Internet class**.

Quase sempre você verá `IN` em registros DNS comuns.

## `SOA ns1.ade.local. admin.ade.local.`

Aqui existem dois campos importantes:

```dns
ns1.ade.local.
```

É o servidor DNS primário da zona.

```dns
admin.ade.local.
```

É o e-mail do responsável pela zona, mas escrito em formato DNS.

Importante: em DNS, o e-mail não usa `@`.

Então:

```dns
admin.ade.local.
```

representa:

```text
admin@ade.local
```

## Ponto final nos nomes

Repare nos pontos finais:

```dns
ns1.ade.local.
admin.ade.local.
```

Esse ponto final significa: **nome absoluto/FQDN**.

Se você esquecer o ponto, o BIND pode interpretar como relativo à zona.

Por exemplo:

```dns
ns1.ade.local
```

sem ponto poderia virar:

```text
ns1.ade.local.ade.local
```

Por isso, em SOA, NS e CNAME, é comum colocar o ponto final.

---

# 4. Campos do SOA

## Serial

```dns
2026061901 ; Serial
```

É a versão da zona.

Sempre que você alterar o arquivo da zona, incremente o serial.

Exemplo:

```dns
2026061901
2026061902
2026061903
```

Formato comum:

```text
AAAAMMDDNN
```

Onde:

```text
2026 06 19 01
ano  mês dia versão
```

O serial é especialmente importante quando existem servidores secundários, porque eles usam esse número para saber se precisam atualizar a zona.

## Refresh

```dns
3600 ; Refresh
```

Tempo, em segundos, para um servidor secundário verificar se houve mudança no master.

```text
3600 segundos = 1 hora
```

## Retry

```dns
1800 ; Retry
```

Se o secundário tentou atualizar e falhou, ele tenta novamente depois desse tempo.

```text
1800 segundos = 30 minutos
```

## Expire

```dns
604800 ; Expire
```

Se o secundário ficar muito tempo sem falar com o master, depois desse tempo ele considera a zona expirada.

```text
604800 segundos = 7 dias
```

## Negative Cache TTL

```dns
86400 ; Negative Cache TTL
```

Tempo que respostas negativas podem ficar em cache.

Exemplo: alguém pergunta por:

```text
teste.ade.local
```

e esse registro não existe.

A resposta “não existe” pode ser cacheada por esse tempo.

---

# 5. Registro NS

```dns
@       IN  NS      ns1.ade.local.
```

Esse registro diz:

> “O servidor de nomes da zona `ade.local` é `ns1.ade.local`.”

Como `@` representa `ade.local`, isso equivale a:

```dns
ade.local. IN NS ns1.ade.local.
```

Mas esse registro sozinho não basta. Você também precisa dizer qual é o IP de `ns1.ade.local`.

Isso é feito aqui:

```dns
ns1     IN  A       192.168.56.53
```

---

# 6. Registro A do servidor DNS

```dns
ns1     IN  A       192.168.56.53
```

Aqui você está dizendo:

```text
ns1.ade.local -> 192.168.56.53
```

Como `ns1` não tem ponto final, ele é relativo à zona `ade.local`.

Então:

```dns
ns1 IN A 192.168.56.53
```

vira:

```dns
ns1.ade.local. IN A 192.168.56.53
```

Esse é o IP do seu servidor BIND.

---

# 7. Registros do Apache

```dns
@       IN  A       192.168.56.51
www     IN  A       192.168.56.51
apache  IN  A       192.168.56.51
```

Esses registros apontam nomes para o IP do servidor Apache.

## Registro raiz da zona

```dns
@ IN A 192.168.56.51
```

Significa:

```text
ade.local -> 192.168.56.51
```

Então, ao acessar:

```bash
curl http://ade.local
```

o DNS responde com:

```text
192.168.56.51
```

## Registro `www`

```dns
www IN A 192.168.56.51
```

Significa:

```text
www.ade.local -> 192.168.56.51
```

## Registro `apache`

```dns
apache IN A 192.168.56.51
```

Significa:

```text
apache.ade.local -> 192.168.56.51
```

---

# Fluxo completo

Quando você executa:

```bash
dig @192.168.56.53 www.ade.local
```

acontece isto:

```text
1. O cliente pergunta ao DNS 192.168.56.53:
   "Qual é o IP de www.ade.local?"

2. O BIND verifica:
   "Eu tenho uma zona chamada ade.local?"

3. Ele encontra em named.conf.local:
   zone "ade.local" {
       file "/etc/bind/zones/db.ade.local";
   };

4. Ele abre o arquivo db.ade.local.

5. Encontra:
   www IN A 192.168.56.51

6. Responde:
   www.ade.local = 192.168.56.51
```

---

# Resultado esperado dos registros

Sua zona cria estes nomes:

```text
ade.local          -> 192.168.56.51
www.ade.local      -> 192.168.56.51
apache.ade.local   -> 192.168.56.51
ns1.ade.local      -> 192.168.56.53
```

O `192.168.56.53` é o DNS.

O `192.168.56.51` é o Apache
