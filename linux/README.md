# Comandos

## DD - DiskDump

- sintaxe:

  ```shell
  dd if=origem of=destino count=vzs_de_copia bs=tamanho_bloco
  ```

  - count - numero de blocos a ser copiado
  - bs - tamanho dos blocos
    > Para copiar inteiro não precisa determinar o bs e count. O tamanho do dados será count \* bs

[Video - Comando DD](https://www.youtube.com/watch?v=Q0B0rUmllV0)

> Serve para fazer copia bruta, e entende bit a bit.

- Ao copiar um disco, por exemplo `/dev/sda`, será copiado integralmente para saida, incluindo o espaço livre. Se o disco tem 60GB e usa 10GB, o arquivo final terá 60GB. Por isso não é adequado para backup.
- o file de destino precisa ser o mesmo tamanho da origem.

### Origens:

- /dev/zero -> Dispositivo especial do linux que gera infinitos bytes zerados
- /dev/random -> Lê dados aleatórios
- /dev/null -> Descarta os dados, util para testes de leitura.

### Opções (flags):

- oflag -> Controla se usa cache do sistema ou não, para stress test use direct
- conv=datasync -> força a sincronizar a escrita antes de encerrar a task, sem essa flag ele pode encerrar com os dados ainda em cache.

- Comandos relacionados

1. cfdisk

## Service - Systemd units

[Service Section](./src/service/README.md)
