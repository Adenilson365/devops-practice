## Comandos

### DD - DiskDump

- sintaxe:
  ```shell
  dd if=origem of=destino count=vzs_de_copia bs=tamanho_bloco
  ```

  - count - numero de blocos a ser copiado
  - bs - tamanho dos blocos
    > Para copiar inteiro não precisa determinar o bs e count

[Video - Comando DD](https://www.youtube.com/watch?v=Q0B0rUmllV0)

> Serve para fazer copia bruta, e entende bit a bit.

- Ao copiar um disco, por exemplo `/dev/sda`, será copiado integralmente para saida, incluindo o espaço livre. Se o disco tem 60GB e usa 10GB, o arquivo final terá 60GB. Por isso não é adequado para backup.
- o file de destino precisa ser o mesmo tamanho da origem.

- Comandos relacionados

1. cfdisk
