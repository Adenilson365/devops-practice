# Subnetting — Cálculo de Sub-redes IPv4

## 1. O que é Subnetting?

Subnetting é a técnica de dividir uma rede IP em redes menores, chamadas **sub-redes (subnets)**.

É utilizado para organizar endereços IP, segmentar ambientes, otimizar recursos de rede e facilitar o gerenciamento de infraestrutura.

**Exemplos de utilização:**

- AWS VPC e Subnets
- Kubernetes e EKS
- VPN Site-to-Site
- Redes on-premises
- VPC Peering e Transit Gateway
- Segmentação de redes públicas e privadas

## 2. Entendendo CIDR

CIDR (_Classless Inter-Domain Routing_) define quantos bits de um endereço IP são utilizados para identificar a rede.

O IPv4 possui **32 bits**.

Exemplo:

```text
10.0.0.0/16

16 bits → Rede
16 bits → Hosts
```

Quanto maior o prefixo CIDR, menor será a quantidade de endereços disponíveis.

### Tabela de referência

| CIDR | Máscara         | Total de IPs | IPs disponíveis AWS |
| ---- | --------------- | -----------: | ------------------: |
| /16  | 255.255.0.0     |       65.536 |              65.531 |
| /17  | 255.255.128.0   |       32.768 |              32.763 |
| /18  | 255.255.192.0   |       16.384 |              16.379 |
| /19  | 255.255.224.0   |        8.192 |               8.187 |
| /20  | 255.255.240.0   |        4.096 |               4.091 |
| /21  | 255.255.248.0   |        2.048 |               2.043 |
| /22  | 255.255.252.0   |        1.024 |               1.019 |
| /23  | 255.255.254.0   |          512 |                 507 |
| /24  | 255.255.255.0   |          256 |                 251 |
| /25  | 255.255.255.128 |          128 |                 123 |
| /26  | 255.255.255.192 |           64 |                  59 |
| /27  | 255.255.255.224 |           32 |                  27 |
| /28  | 255.255.255.240 |           16 |                  11 |

**Regra:** cada incremento de 1 no prefixo CIDR divide pela metade a quantidade de endereços IP.

## 3. Fórmulas principais

**Quantidade total de IPs:**

```text
2^(32 - CIDR)
```

Exemplo `/20`:

```text
2^(32 - 20)
2^12 = 4096 IPs
```

**Quantidade de sub-redes:**

```text
2^(novo_prefixo - prefixo_original)
```

Exemplo: dividir `/16` em `/20`.

```text
20 - 16 = 4 bits

2^4 = 16 sub-redes
```

**Cálculo do incremento:**

```text
256 - valor do octeto relevante da máscara
```

Exemplo `/18`:

```text
Máscara: 255.255.192.0

256 - 192 = 64
```

Os blocos começam em:

```text
10.0.0.0/18
10.0.64.0/18
10.0.128.0/18
10.0.192.0/18
```

## 4. Exemplo — Dividindo uma rede /16

Rede original:

```text
10.0.0.0/16
```

Total: **65.536 endereços IP**.

### Divisão em /17

```text
10.0.0.0/16
│
├── 10.0.0.0/17
│   └── 10.0.0.0 até 10.0.127.255
│
└── 10.0.128.0/17
    └── 10.0.128.0 até 10.0.255.255
```

Resultado: 2 sub-redes com 32.768 IPs cada.

### Divisão em /18

```text
10.0.0.0/16
│
├── 10.0.0.0/18
│   └── 10.0.0.0 até 10.0.63.255
│
├── 10.0.64.0/18
│   └── 10.0.64.0 até 10.0.127.255
│
├── 10.0.128.0/18
│   └── 10.0.128.0 até 10.0.191.255
│
└── 10.0.192.0/18
    └── 10.0.192.0 até 10.0.255.255
```

Resultado: 4 sub-redes com 16.384 IPs cada.

### Divisão com tamanhos diferentes — VLSM

VLSM (_Variable Length Subnet Mask_) permite utilizar tamanhos diferentes de sub-redes dentro da mesma rede.

```text
10.0.0.0/16
│
├── 10.0.0.0/17       → 32.768 IPs
├── 10.0.128.0/18     → 16.384 IPs
└── 10.0.192.0/18     → 16.384 IPs
```

Total: 65.536 endereços, sem sobreposição.

## 5. Subnetting na AWS

Na AWS, cada subnet IPv4 possui **5 IPs reservados**.

Exemplo para `10.0.1.0/24`:

| IP         | Finalidade             |
| ---------- | ---------------------- |
| 10.0.1.0   | Endereço de rede       |
| 10.0.1.1   | Roteador da VPC        |
| 10.0.1.2   | DNS reservado pela AWS |
| 10.0.1.3   | Uso futuro da AWS      |
| 10.0.1.255 | Broadcast reservado    |

```text
Total: 256 IPs
Reservados: 5 IPs

Disponíveis: 251 IPs
```

A AWS não oferece broadcast tradicional na VPC, mas mantém o último endereço reservado.

### Exemplo de VPC para EKS

```text
VPC: 10.100.0.0/16

├── EKS AZ-A: 10.100.0.0/19
├── EKS AZ-B: 10.100.32.0/19
├── EKS AZ-C: 10.100.64.0/19
│
├── Public AZ-A: 10.100.96.0/24
├── Public AZ-B: 10.100.97.0/24
├── Public AZ-C: 10.100.98.0/24
│
├── DB AZ-A: 10.100.255.0/26
├── DB AZ-B: 10.100.255.64/26
└── DB AZ-C: 10.100.255.128/26
```

O planejamento considera três Availability Zones e evita sobreposição entre sub-redes.

## 6. Sobreposição de redes (CIDR Overlap)

CIDR overlap acontece quando duas redes compartilham parte do mesmo intervalo de endereços.

Exemplo:

```text
Rede A: 10.0.0.0/17
Range:  10.0.0.0 - 10.0.127.255

Rede B: 10.0.64.0/18
Range:  10.0.64.0 - 10.0.127.255
```

A segunda rede está contida na primeira.

**Possíveis impactos:**

- Problemas de roteamento
- Restrições em VPC Peering
- Conflitos em conexões VPN
- Problemas de comunicação entre ambientes híbridos

É importante validar a sobreposição tanto entre sub-redes quanto entre os blocos CIDR das VPCs e redes conectadas.

## 7. Subnetting com Terraform

Terraform possui a função `cidrsubnet()` para calcular sub-redes automaticamente.

Sintaxe:

```hcl
cidrsubnet(prefix, newbits, netnum)
```

- `prefix`: CIDR original.
- `newbits`: quantidade de bits adicionados ao prefixo.
- `netnum`: índice da sub-rede desejada, começando em zero.

Exemplo:

```hcl
locals {
  vpc_cidr = "10.100.0.0/16"

  subnet_eks_a = cidrsubnet(local.vpc_cidr, 3, 0)
  subnet_eks_b = cidrsubnet(local.vpc_cidr, 3, 1)
  subnet_eks_c = cidrsubnet(local.vpc_cidr, 3, 2)
}
```

Resultado:

```text
subnet_eks_a = 10.100.0.0/19
subnet_eks_b = 10.100.32.0/19
subnet_eks_c = 10.100.64.0/19
```

Também existe a função `cidrhost()` para calcular um endereço de host dentro de um CIDR.

## 8. Comandos úteis

**Linux — visualizar interfaces e endereços:**

```bash
ip addr show
```

**Visualizar rotas:**

```bash
ip route show
```

**Calcular sub-redes com ipcalc:**

```bash
ipcalc 10.0.0.0/18
```

**Validar overlap com Python:**

```python
import ipaddress

rede_a = ipaddress.ip_network("10.0.0.0/17")
rede_b = ipaddress.ip_network("10.0.64.0/18")

print(rede_a.overlaps(rede_b))
# True
```

## 9. Boas práticas

- Planejar o endereçamento antes de criar VPCs.
- Evitar sobreposição entre VPCs e redes on-premises.
- Dimensionar as subnets considerando o crescimento futuro.
- Distribuir recursos entre múltiplas Availability Zones.
- Reservar espaço para expansão e novos serviços.
- Validar os CIDRs antes do provisionamento com Terraform.
- Considerar o consumo de IPs por ENIs e pods em clusters EKS.
- Lembrar que uma subnet pública ou privada na AWS é definida principalmente por seu roteamento, não pelo seu CIDR.

## Referências

- [AWS — VPC Subnet CIDR Blocks](https://docs.aws.amazon.com/vpc/latest/userguide/subnet-sizing.html)
- [Terraform — cidrsubnet](https://developer.hashicorp.com/terraform/language/functions/cidrsubnet)
- [Python — ipaddress](https://docs.python.org/3/library/ipaddress.html)
- [CIDRxyz](https://cidr.xyz/)
- [Binary - Calculator](https://www.prepostseo.com/tool/binary-to-decimal-converter)

---

**Resumo:** subnetting é fundamental para arquitetura de redes, infraestrutura como código e conectividade entre ambientes cloud e on-premises. Dominar CIDR, cálculo de endereços, VLSM e CIDR overlap é essencial para construir redes escaláveis e evitar problemas de roteamento.
