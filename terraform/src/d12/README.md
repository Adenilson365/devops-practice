### Workspace

[Documentação oficial](https://developer.hashicorp.com/terraform/language/state/workspaces)

Terraform Workspaces permitem utilizar a mesma configuração Terraform com diferentes arquivos de estado.

Cada workspace possui seu próprio `state`, enquanto os arquivos `.tf` continuam sendo compartilhados.

Isso pode ser útil para reutilizar a mesma infraestrutura lógica em ambientes diferentes, como `dev`, `hml` e `prd`.

Exemplo:

```text
Mesmo código Terraform
        │
        ├── workspace dev
        │      └── state DEV
        │
        └── workspace prd
               └── state PRD
```

> Um workspace separa principalmente o **state**, não o código.

---

### Workspace e Git Branch

Um Terraform Workspace pode lembrar superficialmente uma branch Git, mas eles possuem propósitos diferentes.

Uma branch Git separa versões do código:

```text
Git Branch
    ↓
Código diferente
```

Já um Terraform Workspace utiliza a mesma configuração, mas mantém states separados:

```text
Terraform Workspace
        ↓
State diferente
```

Por isso, mudar de workspace não altera os arquivos `.tf`.

---

### Workspace padrão

Todo diretório Terraform começa no workspace:

```text
default
```

O workspace `default`:

- é criado automaticamente;
- sempre existe;
- não pode ser excluído.

Para visualizar o workspace atual:

```bash
terraform workspace show
```

---

### Comandos

| Comando                                        | Objetivo                                             |
| ---------------------------------------------- | ---------------------------------------------------- |
| `terraform workspace list`                     | Lista os workspaces. O `*` indica o workspace atual. |
| `terraform workspace show`                     | Mostra o workspace atual.                            |
| `terraform workspace new <nome>`               | Cria um workspace e o seleciona.                     |
| `terraform workspace select <nome>`            | Seleciona um workspace existente.                    |
| `terraform workspace select -or-create <nome>` | Seleciona o workspace ou cria caso ele não exista.   |
| `terraform workspace delete <nome>`            | Exclui um workspace.                                 |

Exemplo:

```bash
terraform workspace new dev
```

Depois:

```bash
terraform workspace list
```

Saída:

```text
  default
* dev
```

O `*` indica o workspace atualmente selecionado.

---

### `terraform.workspace`

O Terraform disponibiliza a expressão:

```hcl
terraform.workspace
```

Ela retorna o nome do workspace atual.

Exemplo:

```hcl
resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name        = "web-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
```

No workspace:

```text
dev
```

o recurso terá:

```text
Name = web-dev
Environment = dev
```

Já no workspace:

```text
prd
```

terá:

```text
Name = web-prd
Environment = prd
```

---

### Configuração baseada no workspace

Também é possível utilizar `terraform.workspace` para alterar configurações.

Exemplo:

```hcl
locals {
  instance_types = {
    dev = "t3.micro"
    prd = "t3.large"
  }
}

resource "aws_instance" "example" {
  ami = var.ami

  instance_type = local.instance_types[terraform.workspace]

  tags = {
    Environment = terraform.workspace
  }
}
```

No workspace:

```bash
terraform workspace select dev
```

será utilizado:

```text
t3.micro
```

No workspace:

```bash
terraform workspace select prd
```

será utilizado:

```text
t3.large
```

Fluxo:

```text
terraform.workspace
        ↓
       dev
        ↓
instance_types["dev"]
        ↓
    t3.micro
```

---

### Variáveis por workspace

Workspaces separam os states, mas não possuem associação automática com arquivos `.tfvars`.

Por exemplo:

```text
dev.tfvars
prd.tfvars
```

Selecionar o workspace:

```bash
terraform workspace select dev
```

não faz o Terraform carregar automaticamente:

```text
dev.tfvars
```

O arquivo precisa ser informado explicitamente:

```bash
terraform plan -var-file=dev.tfvars
```

Ou:

```bash
terraform apply -var-file=dev.tfvars
```

Exemplo para produção:

```bash
terraform workspace select prd

terraform plan -var-file=prd.tfvars
```

É importante entender que nada impede executar:

```bash
terraform workspace select dev

terraform plan -var-file=prd.tfvars
```

Por isso, o operador ou pipeline deve garantir que o arquivo de variáveis correto seja utilizado.

---

### State local com Workspaces

Quando o backend local é utilizado, o workspace `default` utiliza normalmente:

```text
terraform.tfstate
```

Os outros workspaces armazenam seus states dentro de:

```text
terraform.tfstate.d/
```

Exemplo:

```text
.
├── dev.tfvars
├── main.tf
├── prd.tfvars
├── provider.tf
├── terraform.tfstate
│
└── terraform.tfstate.d
    ├── dev
    │   └── terraform.tfstate
    │
    └── prd
        └── terraform.tfstate
```

Nesse caso:

```text
terraform.tfstate
```

pertence ao workspace:

```text
default
```

Enquanto:

```text
terraform.tfstate.d/dev/terraform.tfstate
```

pertence ao workspace:

```text
dev
```

E:

```text
terraform.tfstate.d/prd/terraform.tfstate
```

pertence ao workspace:

```text
prd
```

---

### Workspaces com backend S3

Workspaces também funcionam com remote state.

Exemplo:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "app/terraform.tfstate"
    region = "us-east-1"
  }
}
```

No workspace:

```text
default
```

o state utiliza o `key` configurado:

```text
app/terraform.tfstate
```

Para outros workspaces, o backend S3 cria caminhos separados.

Por padrão:

```text
env:/<workspace>/<key>
```

Exemplo para `dev`:

```text
env:/dev/app/terraform.tfstate
```

Exemplo para `prd`:

```text
env:/prd/app/terraform.tfstate
```

Portanto:

```text
              mesmo código

                   │
             backend S3
                   │
        ┌──────────┴──────────┐
        │                     │
   workspace dev         workspace prd
        │                     │
    state DEV               state PRD
        │                     │
   recursos DEV           recursos PRD
```

---

### Exclusão de Workspaces

Um workspace não pode ser excluído enquanto estiver selecionado.

Por exemplo, se o workspace atual for:

```text
dev
```

primeiro selecione outro:

```bash
terraform workspace select default
```

Depois:

```bash
terraform workspace delete dev
```

Por padrão, o Terraform não permite excluir um workspace que ainda possui recursos registrados no state.

É possível utilizar:

```bash
terraform workspace delete -force dev
```

Porém isso deve ser feito com cuidado.

Excluir o workspace não significa necessariamente destruir a infraestrutura.

Diferença:

```text
terraform destroy
        ↓
destrói os recursos

terraform workspace delete
        ↓
remove o workspace/state
```

Com `-force`, recursos podem continuar existindo na infraestrutura sem serem mais gerenciados pelo state daquele workspace.

---

### Workspaces e isolamento de ambientes

Workspaces podem ser utilizados para representar ambientes como:

```text
dev
hml
prd
```

Porém eles não fornecem isolamento completo entre ambientes.

Todos continuam utilizando:

```text
mesma configuração
mesmo diretório Terraform
mesmo backend
```

A principal separação é:

```text
state
```

Por isso, ambientes que exigem forte isolamento, credenciais diferentes, permissões separadas ou backends distintos podem utilizar outras estratégias, como:

```text
infra/
├── dev/
│   └── terraform.tf
│
├── hml/
│   └── terraform.tf
│
└── prd/
    └── terraform.tf
```

ou módulos reutilizáveis com root modules separados.

---

### Terraform CLI Workspace vs HCP Terraform Workspace

Terraform CLI Workspace e HCP Terraform Workspace não são exatamente o mesmo conceito.

Um **Terraform CLI Workspace** representa principalmente states diferentes dentro da mesma configuração:

```text
mesmo código
   │
   ├── state dev
   └── state prd
```

Já um **HCP Terraform Workspace** é uma unidade mais completa de execução, podendo possuir suas próprias configurações, variáveis, state e configurações de execução.

Para a certificação, é importante não confundir os dois conceitos.

---

### Resumo

O ponto principal sobre Terraform Workspaces é:

```text
Workspace não cria uma cópia do código.

Workspace cria uma separação de state.
```

Exemplo:

```text
main.tf
variables.tf
provider.tf

        │
        │ mesmo código
        │
        ├── workspace dev
        │      └── state DEV
        │
        ├── workspace hml
        │      └── state HML
        │
        └── workspace prd
               └── state PRD
```

Pontos importantes:

- `default` sempre existe.
- Cada workspace possui seu próprio state.
- `terraform.workspace` retorna o workspace atual.
- Workspaces compartilham os mesmos arquivos `.tf`.
- `.tfvars` não são selecionados automaticamente pelo workspace.
- Workspaces não equivalem a branches Git.
- Workspaces não fornecem isolamento completo entre ambientes.
- CLI Workspaces e HCP Terraform Workspaces são conceitos diferentes.
