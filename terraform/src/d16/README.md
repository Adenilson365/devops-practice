# Terraform — Sensitive Data, Ephemeral Data e Secrets

## Sensitive Data

`sensitive = true` indica que um valor não deve ser exibido diretamente no terminal ou em outputs comuns do Terraform.

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

No `terraform plan`, o valor será ocultado:

```text
password = (sensitive value)
```

Importante:

> `sensitive` apenas reduz a exposição visual. O valor ainda pode ser armazenado no state e no plan.

---

## Ephemeral Data

`ephemeral = true` indica que o valor deve existir apenas durante a execução do Terraform.

```hcl
variable "api_token" {
  type      = string
  sensitive = true
  ephemeral = true
}
```

Um valor ephemeral:

- não é persistido no state;
- não é persistido no plan;
- existe apenas durante a execução;
- é útil para tokens e credenciais temporárias.

Resumo:

```text
sensitive → evita exposição
ephemeral → evita persistência
```

Para secrets temporários, normalmente usamos os dois:

```hcl
variable "token" {
  type      = string
  sensitive = true
  ephemeral = true
}
```

---

## Write-only arguments

Alguns providers possuem atributos write-only, normalmente identificados por `_wo`.

Exemplo:

```hcl
resource "aws_db_instance" "database" {
  username = "admin"

  password_wo         = var.db_password
  password_wo_version = 1
}
```

O Terraform envia o valor ao provider, mas não o mantém no state.

Fluxo:

```text
Secret
  ↓
Terraform
  ↓
write-only
  ↓
Provider
  ↓
Recurso

State
  ↓
Secret não persistido
```

---

## `nonsensitive()`

A função `nonsensitive()` remove a marcação de dado sensível.

```hcl
nonsensitive(var.secret)
```

Deve ser usada com cuidado, porque pode fazer um secret aparecer novamente em outputs ou logs.

---

## Boas práticas

### Não armazenar secrets no código

Evite:

```hcl
password = "MinhaSenha123"
```

Também evite secrets em:

```text
terraform.tfvars
*.tf
Git
README
pipeline scripts
```

---

### Usar Secret Managers

Prefira:

- AWS Secrets Manager;
- AWS Parameter Store;
- HashiCorp Vault;
- Azure Key Vault;
- GCP Secret Manager.

Idealmente o Terraform deve manipular referências ao secret, e não manter o secret permanentemente.

---

### Preferir credenciais temporárias

Evite access keys permanentes.

Prefira:

```text
CI/CD
  ↓
OIDC
  ↓
STS / credencial temporária
  ↓
Terraform
```

Isso reduz o impacto caso uma credencial seja comprometida.

---

### Proteger o Terraform State

O state deve ser tratado como informação sensível.

Use backend remoto com:

- encryption;
- IAM/RBAC;
- TLS;
- versionamento;
- locking;
- auditoria;
- least privilege.

---

### Proteger arquivos de Plan

Um arquivo criado com:

```bash
terraform plan -out=tfplan
```

também pode conter informações sensíveis.

Evite versionar:

```text
terraform.tfstate
terraform.tfstate.backup
tfplan
plan.json
```

---

## Modelo mental

```text
Sensitive
   ↓
Evita exposição

Ephemeral
   ↓
Evita persistência

Write-only
   ↓
Envia secret ao provider sem armazená-lo
```

Para secrets:

```text
Secret Manager / OIDC
        ↓
Credencial temporária
        ↓
sensitive + ephemeral
        ↓
Terraform
        ↓
write-only
        ↓
Provider
```

## Resumo

| Recurso                 | Oculta valor | Evita State | Evita Plan |
| ----------------------- | -----------: | ----------: | ---------: |
| `sensitive`             |           ✅ |          ❌ |         ❌ |
| `ephemeral`             |         ❌\* |          ✅ |         ✅ |
| `sensitive + ephemeral` |           ✅ |          ✅ |         ✅ |
| write-only              |            — |          ✅ |         ✅ |

\* `ephemeral` trata persistência, não necessariamente confidencialidade.

> Regra principal: não tente apenas esconder secrets dentro do Terraform. Sempre que possível, projete a solução para que o Terraform não precise armazená-los.
