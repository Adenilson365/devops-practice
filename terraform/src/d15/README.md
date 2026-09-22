# Terraform Query

O `terraform query` é usado para **descobrir recursos que já existem no provider**, mesmo que ainda não estejam no Terraform State.

É especialmente útil em ambientes **brownfield**, onde a infraestrutura já existe e precisa ser incorporada ao Terraform.

## Objetivo

```text
Infra existente
    ↓
terraform query
    ↓
Descoberta dos recursos
    ↓
Geração/revisão da configuração
    ↓
Import
    ↓
Terraform State
```

## Arquivos

Queries são definidas em arquivos:

```text
*.tfquery.hcl
```

O principal bloco é:

```hcl
list "aws_instance" "instances" {
  provider = aws

  config {
    # filtros
  }
}
```

Executar:

```bash
terraform query
```

Gerar configuração:

```bash
terraform query -generate-config-out=generated.tf
```

---

## Argumentos principais

| Argumento          | Objetivo                                     |
| ------------------ | -------------------------------------------- |
| `limit`            | Limita a quantidade de resultados            |
| `count`            | Repete a query por índice                    |
| `for_each`         | Repete a query por chave/valor               |
| `include_resource` | Inclui a representação do recurso encontrado |

Exemplo:

```hcl
list "aws_instance" "instances" {
  limit = 20
}
```

---

## Query vs State vs Data

```text
terraform state list
→ O que o Terraform já gerencia?

terraform query
→ O que existe no provider?

data
→ Quero consumir uma informação da infraestrutura.

import
→ Quero passar a gerenciar um recurso existente.
```

---

## Brownfield

Infraestrutura que **já existe** antes da adoção do Terraform.

```text
ClickOps / Infra existente
        ↓
terraform query
        ↓
import
        ↓
Terraform
```

## Greenfield

Infraestrutura criada do zero via Terraform.

```text
Terraform
   ↓
plan
   ↓
apply
   ↓
Infra criada
```

## Bulk Import

`Bulk` significa **em massa**.

`Bulk import` é o processo de importar vários recursos existentes para o Terraform, evitando fazer tudo manualmente recurso por recurso.

```text
Brownfield
    ↓
Query
    ↓
Discovery
    ↓
Bulk Import
    ↓
State
```

## Modelo mental

```text
query   → descobrir
data    → consultar/consumir
import  → trazer para gerenciamento
state   → registrar
resource → definir estado desejado
```
