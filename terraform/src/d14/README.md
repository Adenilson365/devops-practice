# Revisão Terraform

# 1. Grafo de dependências no Terraform

O Terraform constrói um grafo de dependências para planejar e executar as alterações. Esse grafo determina a ordem das operações: recursos independentes podem ser processados em paralelo, enquanto um recurso dependente aguarda os recursos dos quais precisa. A posição dos blocos nos arquivos `.tf` não define essa ordem.

## Dependência implícita

Uma referência a outro recurso cria uma dependência implícita. Neste exemplo, a subnet usa o ID da VPC; portanto, a VPC precisa existir antes da subnet:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```

## Dependência explícita

Use `depends_on` quando a operação depender de outro recurso, mas não houver uma referência aos atributos dele que expresse essa relação. No exemplo, o objeto usa o ID do bucket (dependência implícita) e também precisa aguardar a ativação do versionamento (dependência explícita):

```hcl
resource "aws_s3_bucket" "artifacts" {
  bucket = "exemplo-artifacts-unico"
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "app" {
  bucket  = aws_s3_bucket.artifacts.id
  key     = "app.txt"
  content = "exemplo"

  depends_on = [aws_s3_bucket_versioning.artifacts]
}
```

Declare dependências explícitas somente quando necessárias: elas podem reduzir o paralelismo e tornar o plano mais conservador.

## Ordem de criação e destruição

Se uma instância depende de uma subnet, e a subnet depende de uma VPC, a criação segue esta ordem:

```text
VPC → Subnet → Instância
```

Na destruição desses recursos, a ordem se inverte para remover os dependentes antes de suas dependências:

```text
Instância → Subnet → VPC
```

## Visualizar o grafo

Execute os comandos em um diretório que contenha uma configuração Terraform:

```bash
terraform graph

# Requer o comando dot do Graphviz:
terraform graph | dot -Tpng > graph.png
```

`terraform graph` emite o grafo no formato DOT. Por padrão, ele mostra uma visão simplificada da ordem de dependência entre recursos e fontes de dados. Consulte a [referência do comando `terraform graph`](https://developer.hashicorp.com/terraform/cli/commands/graph) e a [documentação de `depends_on`](https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on).

# 2. Atualização do state com `-refresh-only`

Uma alteração feita fora do Terraform pode deixar a infraestrutura real diferente do que está registrado no **state**. O modo `-refresh-only` consulta os recursos por meio dos providers e propõe atualizar o state e, se necessário, os outputs do módulo raiz para refletir o que existe. Ele não altera os recursos reais nem modifica os arquivos `.tf`.

- `terraform plan -refresh-only` mostra as mudanças propostas para o state, sem gravá-las.
- `terraform apply -refresh-only` mostra o plano e, após confirmação, grava essas mudanças no state sem criar, alterar ou destruir recursos reais.
- `terraform plan` comum também consulta os recursos antes de planejar, mas compara o resultado com a configuração `.tf`. Se houver divergência, pode propor uma alteração na infraestrutura para voltar ao valor configurado. Apenas executar esse plano não grava a atualização no state.

### Exemplo: tag alterada manualmente

Considere uma instância `aws_instance.app` cuja configuração e cujo state registram a tag `Name = "app"`. Alguém altera essa tag para `Name = "app-manual"` diretamente no console da AWS. A configuração `.tf` continua com `Name = "app"`.

```bash
terraform plan -refresh-only
# Mostra a mudança da tag de "app" para "app-manual" que seria registrada no state.

terraform apply -refresh-only
# Após revisar e confirmar, registra "app-manual" no state; não muda a instância.

terraform plan
# Como o .tf ainda pede "app", propõe devolver a tag real para "app".
```

Depois do `apply -refresh-only`, decida se a alteração manual deve permanecer. Se sim, atualize a configuração para `Name = "app-manual"`; se não, revise e aplique um plano comum para restaurar `Name = "app"`. Atualizar o state não resolve, por si só, a divergência entre a infraestrutura e a configuração.

Revise o plano antes de confirmar: se as credenciais ou a configuração do provider estiverem incorretas, o Terraform pode interpretar um recurso existente como ausente e propor removê-lo do state. Consulte a [documentação do modo `-refresh-only`](https://developer.hashicorp.com/terraform/cli/commands/plan#planning-modes) e o [tutorial sobre atualização do state](https://developer.hashicorp.com/terraform/tutorials/state/refresh).

# 3. in-place

No Terraform, uma alteração **in-place** acontece quando um recurso existente pode ser atualizado **sem precisar ser destruído e recriado**.

No `terraform plan`, esse tipo de alteração normalmente é identificado pelo símbolo:

```text
~
```

Exemplo:

```text
~ instance_type = "t3.micro" -> "t3.small"
```

Isso significa que o Terraform irá alterar o recurso existente, mantendo o mesmo objeto e normalmente o mesmo ID.

```text
Recurso atual
    ↓
Update
    ↓
Mesmo recurso
```

É diferente de um **replacement**, onde o Terraform precisa destruir e recriar o recurso.

```text
In-place:
~ update in-place

Replacement:
-/+ destroy and create replacement
```

Importante: uma alteração in-place não significa necessariamente **zero impacto**. O provider pode precisar reiniciar, parar ou reconfigurar o recurso durante a atualização.

# 4. Terraform Plan `-out`

A opção `-out` permite salvar o plano gerado pelo Terraform em um arquivo para revisão e aplicação posterior.

```bash
terraform plan -out=tfplan
```

Sem `-out`, um `terraform apply` gera um novo plano antes de executar. Isso significa que mudanças feitas entre o `plan` e o `apply` podem alterar o resultado.

Com `-out`, o fluxo fica:

```text
Config + State + Infraestrutura
          ↓
    terraform plan
          ↓
       tfplan
          ↓
       revisão
          ↓
 terraform apply tfplan
```

Assim, o Terraform aplica o plano que foi previamente gerado e revisado.

### Comandos principais

```bash
terraform plan -out=tfplan
```

Salva o plano.

```bash
terraform show tfplan
```

Exibe o plano em formato legível para humanos.

```bash
terraform show -json tfplan
```

Converte o plano para JSON, útil em automações, pipelines e validações.

```bash
terraform apply tfplan
```

Aplica o plano salvo.

### Pontos importantes

- O arquivo de plano usa um formato interno do Terraform.
- Um plano salvo pode se tornar **stale** caso o state seja alterado antes do `apply`.
- `-out` é muito utilizado em CI/CD para separar as etapas de **plan**, **review** e **apply**.
- O arquivo pode conter informações sensíveis e não deve ser versionado no Git.
- `terraform show -json` permite analisar ações como `create`, `update`, `delete` e `replace` via scripts ou policy engines.

### Resumo

```text
terraform plan
→ apenas visualiza mudanças

terraform plan -out=tfplan
→ salva o plano

terraform apply tfplan
→ aplica exatamente o plano salvo
```

O principal objetivo do `-out` é garantir que o plano revisado seja o mesmo utilizado no momento da aplicação.
