### Review variables and configure blocks.

- Version constraints table
  | Constraint | Meaning | Example |
  | ---------- | ---------------------------- | ------------------------------------------ |
  | `= 1.5.0` | Exactly this version | Only `1.5.0` |
  | `!= 1.5.0` | Anything except this version | `1.4.0`, `1.6.0`, etc. |
  | `> 1.5.0` | Greater than | `1.5.1`, `1.6.0`, `2.0.0` |
  | `>= 1.5.0` | Greater than or equal | `1.5.0`, `1.6.0`, `2.0.0` |
  | `< 2.0.0` | Lower than | `1.9.9`, `1.8.0`, etc. |
  | `<= 2.0.0` | Lower than or equal | Up to `2.0.0` |
  | `~> 1.5` | Compatible version | `1.5`, `1.6`, `1.9`, but not `2.0` |
  | `~> 1.5.0` | Compatible patch versions | `1.5.0`, `1.5.1`, `1.5.9`, but not `1.6.0` |

- We can also combine contraints, as shown below:

```sh
terraform {
required_version = ">= 1.10.0, < 2.0.0"

required_providers {
    aws = {
    source  = "hashicorp/aws"
    version = ">= 6.0.0, < 7.0.0"
    }
}
}
```

> This means that Terraform can use any AWS provider version greater than or equal to 6.0.0 and lower than 7.0.0

6.29.0 ❌
6.30.0 ✅
6.35.1 ✅
6.99.0 ✅
7.0.0 ❌

However, our terraform.lock.hcl file stores the provider current version installed by Terraform. If we want to upgrade version that still satisfies configured constraints we need to run `terraform init --upgrade`

![alt text](../../assets/state_lock_versions_constraints.png)

- after applying the upgrade

```json
provider "registry.terraform.io/hashicorp/local" {
  version     = "2.9.0"
  constraints = "~> 2.8"
```

- we can also perform downgrade by changing the versions constraitns in the provider block, for example: "constraints= "<=2.8.0"

```sh
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "<= 2.8"
    }
  }
}
```

```json
provider "registry.terraform.io/hashicorp/local" {
  version     = "2.8.0"
  constraints = "<= 2.8.0"
```

- When I applied a bounded version constraint, I noticed that terraform selected the minor version, or left version between them.

```sh
provider "registry.terraform.io/hashicorp/local" {
  version     = "2.7.0"
  constraints = "2.7.0, < 2.9.0"
```

- In this case, I made a mistake, I write `=2.7.0`, It allow terraform just select version equal, in other words, I set version. If I use >= instead, terraform can select version in the range beetwhen them.

```sh
provider "registry.terraform.io/hashicorp/local" {
  version     = "2.9.0"
  constraints = ">= 2.7.0, <= 2.9.0"
```

- Terraform generally select the newest version available that satisfies all constraints

### Variables

[Documentation](https://developer.hashicorp.com/terraform/language/values/variables)

- We can pass variable with Terraform CLI, as below

```
terraform apply -var="instance_type=t3.medium" -var="environment=prod"
terraform apply -var='subnet_ids=["subnet-12345","subnet-67890"]'
```

- Pass var-file

```
terraform apply -var-file="production.auto.tfvars"
```

- Export TF_VARS_name_of_variable

```
export TF_VAR_complex_config='{"key": "value", "list": ["a", "b"]}'

```

- **Variable Precedence**
- If the same input variable gets a value from multiple sources, Terraform follow an order:
  | Priority | Source | Example |
  | -------- | -------------------------------------- | ----------------------------------------------- |
  | Lowest | `default` in `variable` block | `default = "t3.micro"` |
  | ↑ | Environment variable `TF_VAR_*` | `TF_VAR_instance_type=t3.small` |
  | ↑ | `terraform.tfvars` | `instance_type = "t3.medium"` |
  | ↑ | `terraform.tfvars.json` | JSON equivalent |
  | ↑ | `*.auto.tfvars` / `*.auto.tfvars.json` | `prod.auto.tfvars` |
  | Highest | CLI `-var` / `-var-file` | `terraform apply -var="instance_type=t3.large"` |

### Validação de variáveis

A validação define regras para os valores recebidos por uma variável, como ambientes permitidos, intervalos numéricos e formatos de nomes. Quando uma condição retorna `false`, o Terraform apresenta a mensagem configurada e interrompe a operação. Veja a [documentação oficial de validação](https://developer.hashicorp.com/terraform/language/validate).

#### Estrutura do bloco

O bloco `validation` fica dentro de `variable`. A expressão `condition` deve produzir um booleano, e `error_message` deve explicar o valor esperado:

```hcl
variable "environment" {
  description = "Ambiente de execução."
  type        = string
  default     = "dev"
  nullable    = false

  validation {
    condition     = contains(["dev", "hml", "prd"], var.environment)
    error_message = "O ambiente deve ser dev, hml ou prd."
  }
}
```

Nesse exemplo, `"dev"` é válido, mas `"prod"` e `"DEV"` são inválidos. A comparação distingue maiúsculas de minúsculas.

| Propriedade        | Responsabilidade                                                                                                  |
| ------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `type`             | Define o tipo esperado; o Terraform pode realizar conversões compatíveis.                                         |
| `default`          | Fornece um valor quando a entrada é omitida; esse valor também deve atender às regras.                            |
| `nullable = false` | Impede que o valor final da variável seja `null`. Com um padrão não nulo, uma entrada `null` utiliza esse padrão. |
| `validation`       | Verifica regras adicionais sobre o valor.                                                                         |

Declarar `type = string` não impede `""` nem `"   "`. Da mesma forma, `type = number` permite números negativos e decimais. Essas restrições precisam ser expressas na validação. Consulte a [referência do bloco `variable`](https://developer.hashicorp.com/terraform/language/block/variable).

#### Intervalo numérico e múltiplas regras

Uma variável pode ter vários blocos `validation`; todos precisam ser satisfeitos. Separar regras permite fornecer mensagens mais específicas:

```hcl
variable "replicas" {
  description = "Quantidade de réplicas da aplicação."
  type        = number
  default     = 2
  nullable    = false

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 5
    error_message = "A quantidade de réplicas deve estar entre 1 e 5."
  }

  validation {
    condition     = floor(var.replicas) == var.replicas
    error_message = "A quantidade de réplicas deve ser um número inteiro."
  }
}
```

`3` atende às duas regras; `0` falha no intervalo; `2.5` falha na exigência de inteiro.

#### Strings vazias e formatos

Use `trimspace` com `length` para rejeitar uma entrada vazia ou composta apenas por espaços:

```hcl
variable "nome" {
  description = "Nome da aplicação."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.nome)) > 0
    error_message = "O nome deve conter ao menos um caractere diferente de espaço."
  }
}
```

Essa condição verifica o texto sem os espaços das extremidades, mas não modifica o valor de `var.nome`.

### Regex

Para validar um padrão, combine `regex` com `can`:

```hcl
variable "permissao" {
  description = "Permissão octal do arquivo."
  type        = string
  default     = "0644"
  nullable    = false

  validation {
    condition     = can(regex("^0[0-7]{3}$", var.permissao))
    error_message = "A permissão deve começar com 0 e conter mais três dígitos de 0 a 7, como 0644."
  }
}
```

- sintaxe: `regex("padrão", valor)`, se valor não corresponder ao padrão retorna erro, por isso usamos can, para transformar em true or false.
- Alguns padrões regex:
- `^` e `$` delimitam o início e o fim da string
- ^[a-z0-9-]+$ : aceita letras minúsculas, números, e hífen
- `+$` uma ou mais caracteres, ou seja, não aceita string vázia
- `*$` zero ou mais caracteres, ou seja, aceita string vázia.
- `{n}` - Delimita quantidade de caracteres: `^[0-9]{3}$` três numeros exemplo: `123` passa `62` ou `1254` não.
  - Precisa inserir os delimitadores, senão aceita valores além:

```sh
> regex("[0-9]{3}", 1234)
"123"
> regex("^[0-9]{3}$", 1234)
╷
│ Error: Error in function call
│
│   on <console-input> line 1:
│   (source code not available)
│
│ Call to function "regex" failed: pattern did not match any part of the given string.
```

- `^[a-z0-9-]{3,20}$` - De 3 a 20 caracteres
- `^app-` - Valores precisa iniciar com `app-`
- `^app-[a-z0-9-]+$` - Forçar inicar com valor e validar padrão do restante.
- `-prod$` - Equivalente caso queira que termine com determinado valor
- `[A-Z]` - Maiúsculas, `[a-z]` - Minúsculas `A-Za-z` - Ambas
- `.` - Significa qualquer caractere
- `\` - Escapa caracteres especiais, então para ter `.`, use `\\.` porque em hcl, barra também é especial. exemplo: api.example.com `regex("^.+\\.example\\.com$", var.domain)`

- Exemplo validando região

```json
variable "aws_region" {
  type = string

  validation {
    condition = can(
      regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region)
    )

    error_message = "Região Inválida, deve segui padrão aws exemplo: us-east-1"
  }
}
```

- **Simbolos**

| Regex    | Significado        |
| -------- | ------------------ |
| `^`      | início             |
| `$`      | fim                |
| `.`      | qualquer caractere |
| `[abc]`  | a, b ou c          |
| `[a-z]`  | letra minúscula    |
| `[A-Z]`  | letra maiúscula    |
| `[0-9]`  | número             |
| `+`      | 1 ou mais          |
| `*`      | 0 ou mais          |
| `?`      | 0 ou 1             |
| `{3}`    | exatamente 3       |
| `{3,10}` | entre 3 e 10       |
| `\|`     | OU                 |
| `()`     | agrupa             |
| `\.`     | ponto literal      |

`^` e `$` delimitam o início e o fim da string; `[0-7]{3}` exige três dígitos octais. `regex` gera erro quando não encontra correspondência, e `can` converte esse erro em `false`, permitindo apresentar a mensagem da validação. Veja a [documentação de `can`](https://developer.hashicorp.com/terraform/language/functions/can).

`can` verifica se a expressão pode ser avaliada, não se seu resultado é verdadeiro: `can(1 > 2)` retorna `true`. Portanto, use comparações diretamente em `condition`.

#### Operadores úteis

| Operador    | Significado                                 | Exemplo                                                  |
| ----------- | ------------------------------------------- | -------------------------------------------------------- |
| `==` / `!=` | Igual / diferente                           | `var.environment != "prd"`                               |
| `>` / `>=`  | Maior / maior ou igual                      | `var.replicas >= 1`                                      |
| `<` / `<=`  | Menor / menor ou igual                      | `var.replicas <= 5`                                      |
| `&&`        | As duas condições devem ser verdadeiras     | `var.replicas >= 1 && var.replicas <= 5`                 |
| `\|\|`      | Pelo menos uma condição deve ser verdadeira | `var.environment == "dev" \|\| var.environment == "hml"` |
| `!`         | Nega uma condição                           | `!contains(["prd"], var.environment)`                    |

#### Praticando com a variável deste dia

Em [variables.tf](variables.tf), `content_number` exige um valor maior que zero, mas seu `default` atual é `0`. Portanto, o padrão viola a própria regra: informe um valor positivo ou ajuste o padrão para um valor permitido.

No diretório `src/d1`, com as dependências inicializadas, compare:

```bash
terraform plan -var="content_number=1"
terraform plan -var="content_number=0"
```

O primeiro valor atende à regra de `content_number`; o segundo deve apresentar a mensagem `O valor da variável content_number deve ser um número maior que zero.` Isso não garante que o restante da configuração esteja livre de outros erros. Os exemplos de `environment`, `replicas`, `nome` e `permissao` acima são didáticos e não estão declarados nos arquivos `.tf` deste dia.

`terraform validate` verifica a consistência da configuração, mas não substitui `terraform plan` com os valores que serão usados. As regras são avaliadas assim que seus valores estão disponíveis; se uma entrada depender de um resultado ainda desconhecido, sua verificação pode ser adiada. Consulte os [momentos de avaliação das validações](https://developer.hashicorp.com/terraform/language/validate).
