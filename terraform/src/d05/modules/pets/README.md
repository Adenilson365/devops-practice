# Módulo pets

Módulo Terraform que gera um nome aleatório de pet por instância e salva esse nome em um arquivo de texto local. O nome possui duas palavras separadas por hífen (`-`).

## Recursos criados

| Recurso | Finalidade |
| --- | --- |
| `random_pet.pet` | Gera o nome do pet. |
| `local_file.mod_pet` | Salva o nome em `${var.dir_files}/files/pet-${var.suffix}.txt`. |

Os arquivos são gravados no ambiente em que o Terraform é executado. O conteúdo de cada arquivo corresponde ao identificador (`id`) do respectivo recurso `random_pet`.

## Dependências

As dependências são declaradas em `terraform.tf`:

| Provider | Versão exigida |
| --- | --- |
| `hashicorp/local` | `>= 2.9.0` |
| `hashicorp/random` | `>= 3.9.0` |

O módulo não declara uma restrição de versão do Terraform (`required_version`).

## Variáveis de entrada

| Nome | Tipo | Obrigatória | Padrão | Descrição |
| --- | --- | --- | --- | --- |
| `dir_files` | `string` | Sim | Sem padrão | Diretório base. O módulo acrescenta o subdiretório `files` ao caminho informado. |
| `suffix` | `string` | Sim | Sem padrão | Sufixo inserido no nome do arquivo, antes da extensão `.txt`. |
| `directory_permissions` | `string` | Não | `"0755"` | Permissões dos diretórios criados pelo recurso. |
| `file_permissions` | `string` | Não | `"0644"` | Permissões do arquivo de texto. |

Todas as variáveis possuem `nullable = false`. As validações de `dir_files` e `suffix` rejeitam strings vazias, mas não rejeitam valores compostos apenas por espaços nem restringem separadores de caminho no sufixo. Informe um diretório válido e um sufixo adequado a um nome de arquivo.

As permissões devem ser strings com quatro dígitos, começando por `0`, seguidos de três dígitos entre `0` e `7` (expressão `^0[0-7]{3}$`).

Ao criar várias instâncias com o mesmo diretório base, utilize sufixos distintos para evitar que elas gerenciem o mesmo arquivo.

## Saídas

| Nome | Descrição |
| --- | --- |
| `pet_id` | Nome gerado, obtido de `random_pet.pet.id`. |

## Exemplo de uso

O exemplo abaixo deve ser usado no módulo raiz em `src/d5`, onde o caminho relativo `./modules/pets` aponta para este módulo. Assim como a configuração atual de `src/d5/main.tf`, cria duas instâncias com sufixos `1` e `2`:

```hcl
module "pets" {
  source = "./modules/pets"
  count  = 2

  dir_files             = path.module
  suffix                = tostring(count.index + 1)
  file_permissions      = "0644"
  directory_permissions = "0755"
}

output "pets" {
  description = "Retorna os IDs dos pets gerados"
  value       = module.pets[*].pet_id
}
```

As permissões foram explicitadas para demonstrar seu uso; podem ser omitidas para utilizar os mesmos valores padrão. Nesse exemplo, são gerados dois nomes e dois arquivos:

```text
src/d5/files/
├── pet-1.txt
└── pet-2.txt
```

A saída `pets` é uma lista com o nome gerado por cada instância do módulo.

## Execução

No diretório `src/d5`, execute:

```bash
terraform init
terraform plan
terraform apply
terraform output
```

Revise o plano antes de confirmar a aplicação. Para remover os recursos gerenciados pela configuração raiz de `src/d5`, incluindo os arquivos criados por este módulo, execute `terraform destroy` nesse mesmo diretório.
