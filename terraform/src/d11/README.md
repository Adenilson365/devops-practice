# Terraform Lifecycle

## O que é lifecycle?

`lifecycle` é um meta-argumento do Terraform: um bloco de regras da própria linguagem que controla o ciclo de vida dos recursos.

Ao aplicar uma configuração, o Terraform pode:

1. Criar recursos ainda não associados a objetos reais no state (registro dos recursos gerenciados).
2. Destruir recursos registrados no state cuja configuração foi removida.
3. Atualizar atributos sem recriar o recurso.
4. Substituir recursos quando a alteração não permite atualização direta; por padrão, destrói o antigo antes de criar o novo.
5. Invocar ações configuradas, quando a versão do Terraform e o provider oferecem esse suporte.

O bloco `lifecycle` ajusta esses comportamentos e permite definir condições de validação. Este laboratório demonstra seu uso em três instâncias EC2.

## Configuração do laboratório

| Arquivo/recurso                    | Função                                                                               |
| ---------------------------------- | ------------------------------------------------------------------------------------ |
| `provider.tf`                      | Exige Terraform `>= 1.5.0`, fixa o provider AWS em `6.63.0` e configura `us-east-1`. |
| `data.aws_security_group.selected` | Consulta um security group existente pelo ID.                                        |
| `aws_instance.ec2`                 | Instância `t2.nano` em `us-east-1`, com `ignore_changes = [tags]`.                   |
| `aws_instance.ec3`                 | Instância `t2.micro`, com precondição que exige `var.region == "us-east-1"`.         |
| `aws_instance.ec4`                 | Instância `t2.micro`, com substituição acionada pelos IDs de `ec2` e `ec3`.          |
| `security_group_id`                | Output com o ID do security group consultado.                                        |

**Atenção à região:** `var.region` tem valor padrão `us-east-2`, usado em `ec3` e `ec4`. Isso contraria a precondição de `ec3`. Para executar o cenário válido, informe `-var='region=us-east-1'`.

## Regras de lifecycle

Salvo indicação contrária, os trechos abaixo ficam dentro de um bloco `resource`. `ignore_changes`, `replace_triggered_by` e `precondition` já estão em `main.tf`; as demais regras são exemplos complementares.

### `create_before_destroy`

Cria o substituto antes de destruir o recurso antigo. Exige que ambos possam coexistir, inclusive quanto a nomes únicos e capacidade disponível.

```hcl
lifecycle {
  create_before_destroy = true
}
```

### `prevent_destroy`

Rejeita planos que destruam ou substituam o recurso, incluindo `terraform destroy`. Remover o bloco `resource` da configuração também remove essa proteção.

```hcl
lifecycle {
  prevent_destroy = true
}
```

Erro esperado quando o plano tenta destruir um recurso protegido:

```text
Error: Instance cannot be destroyed
```

A falha no planejamento impede a aplicação do plano inteiro.

### `ignore_changes`

Usa os atributos na criação, mas ignora suas diferenças nas atualizações, inclusive alterações no código ou externas. Não impede destruição.

```hcl
lifecycle {
  ignore_changes = [tags]
}
```

Para limitar a regra a uma tag, use `ignore_changes = [tags["Name"]]`.

### `replace_triggered_by`

Substitui o recurso quando a referência muda. Referenciar um recurso acompanha atualizações/substituições; referenciar `.id` acompanha mudanças nesse atributo. Não é uma regra genérica de destruição em cascata.

```hcl
lifecycle {
  replace_triggered_by = [aws_instance.ec2.id, aws_instance.ec3.id]
}
```

No laboratório, a troca do ID de `ec2` ou `ec3` aciona a substituição de `ec4`.

### Condições personalizadas: `precondition`

Exige uma condição verdadeira para prosseguir; se falsa, retorna erro. Não serve para omitir opcionalmente a criação do recurso.

```hcl
lifecycle {
  precondition {
    condition     = var.region == "us-east-1"
    error_message = "A região deve ser us-east-1 para criar a instância ec3"
  }
}
```

O exemplo ajusta a mensagem para `ec3`; no código atual, ela menciona `ec2`, embora a condição esteja em `aws_instance.ec3`.

Com o valor padrão da variável, o erro esperado é:

```text
Error: Resource precondition failed
var.region is "us-east-2"
```

### Condições personalizadas: `postcondition`

Valida o resultado do recurso, usando `self` para acessar seus atributos. Uma falha bloqueia operações dependentes; não desfaz alterações já realizadas.

Exemplo dentro de uma instância EC2 que deve ter IP privado:

```hcl
lifecycle {
  postcondition {
    condition     = self.private_ip != ""
    error_message = "A instância deve possuir um IP privado."
  }
}
```

Referência para as regras acima: [lifecycle](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle).

### `destroy` em um bloco `removed`

Com `destroy = false`, retira o recurso do state e encerra seu gerenciamento pelo Terraform, preservando o objeto real. O padrão é `true`, que também destrói o objeto. Essa regra pertence ao bloco `removed` e requer Terraform `>= 1.7`.

Exemplo independente do laboratório: substitua a declaração de um recurso anteriormente gerenciado por:

```hcl
removed {
  from = aws_instance.legada

  lifecycle {
    destroy = false
  }
}
```

- Warning quando usa removed.

```log
╷
│ Warning: Some objects will no longer be managed by Terraform
│
│ If you apply this plan, Terraform will discard its tracking information for the following objects, but it will not delete them:
│  - aws_instance.ec5
│
│ After applying this plan, Terraform will no longer manage these objects. You will need to import them into Terraform to manage them again.
╵

```

O endereço deve corresponder ao recurso retirado da configuração. Referência: [bloco removed](https://developer.hashicorp.com/terraform/language/block/removed).

### `action_trigger`

Invoca ações do provider em eventos do recurso. Requer Terraform `>= 1.14` e suporte à ação no provider; o requisito mínimo `>= 1.5.0` do laboratório, sozinho, não garante compatibilidade.

Exemplo: declarar uma ação para invocar uma função Lambda existente:

```hcl
action "aws_lambda_invoke" "notificar" {
  config {
    function_name = "notificar-infra"
    payload       = jsonencode({ origem = "terraform" })
  }
}
```

Dentro do recurso que deve disparar a ação após sua criação ou atualização:

```hcl
lifecycle {
  action_trigger {
    events  = [after_create, after_update]
    actions = [action.aws_lambda_invoke.notificar]
  }
}
```

A função `notificar-infra` e as permissões para invocá-la precisam existir. Referência: [invocação de ações](https://developer.hashicorp.com/terraform/language/invoke-actions).
