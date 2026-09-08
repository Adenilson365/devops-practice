# Dia 5 — Revisão de módulos no Terraform

Neste dia, revisamos como organizar recursos em módulos, definir entradas e saídas e reutilizar a mesma configuração. A prática utiliza o módulo local `pets`, que gera um nome aleatório e o grava em um arquivo de texto por instância.

## Visão geral

Um módulo é um conjunto de arquivos de configuração Terraform em um diretório. Ele permite encapsular recursos relacionados, padronizar sua criação e reutilizar a configuração passando valores diferentes. O Terraform considera os arquivos `.tf` desse diretório em conjunto; separá-los por responsabilidade facilita a manutenção.

O **módulo raiz** é a configuração do diretório em que executamos o Terraform. Um **módulo filho** é chamado por um bloco `module`. Subdiretórios não são incluídos automaticamente: precisam ser referenciados por uma chamada. Os recursos dos módulos filhos fazem parte da configuração e do estado gerenciados pelo módulo raiz. Consulte a [visão geral oficial de módulos](https://developer.hashicorp.com/terraform/language/modules).

Neste laboratório, `src/d5` é o módulo raiz e `src/d5/modules/pets` é o módulo filho.

## Organização do laboratório

```text
src/d5/
├── README.md
├── main.tf
└── modules/
    └── pets/
        ├── README.md
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── terraform.tf
```

| Arquivo | Responsabilidade neste laboratório |
| --- | --- |
| `main.tf` da raiz | Chama o módulo `pets` duas vezes com `count` e expõe os resultados. |
| `modules/pets/main.tf` | Define os recursos `random_pet.pet` e `local_file.mod_pet`. |
| `modules/pets/variables.tf` | Define entradas, valores padrão e validações. |
| `modules/pets/outputs.tf` | Expõe o nome gerado por meio de `pet_id`. |
| `modules/pets/terraform.tf` | Declara as dependências dos providers. |

A referência completa das entradas, saídas e recursos está no [README do módulo pets](modules/pets/README.md).

## Entradas, recursos e saídas

As variáveis formam a interface de entrada do módulo. O chamador informa argumentos como `dir_files` e `suffix`, e o módulo os acessa com `var.dir_files` e `var.suffix`.

Os recursos executam a configuração desejada. Aqui, `random_pet.pet` gera um nome com duas palavras separadas por hífen. `local_file.mod_pet` usa esse nome como conteúdo e grava o arquivo em `${var.dir_files}/files/pet-${var.suffix}.txt`. A referência `random_pet.pet.id` estabelece a dependência do arquivo em relação ao nome gerado.

Os outputs expõem os resultados que o chamador pode consumir. O módulo declara:

```hcl
output "pet_id" {
  description = "Retorna o ID do pet gerado"
  value       = random_pet.pet.id
}
```

Para uma chamada sem repetição, o resultado seria acessado por `module.pets.pet_id`. Com `count`, cada instância recebe um índice, como `module.pets[0].pet_id`. Veja como [usar módulos e seus outputs](https://developer.hashicorp.com/terraform/language/modules/configuration).

## Reutilização com `count`

O exemplo abaixo equivale à chamada atual do laboratório, com a conversão do sufixo explícita e as permissões já sem espaços:

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

| Expressão | Papel no exemplo |
| --- | --- |
| `source = "./modules/pets"` | Localiza o módulo em relação ao diretório do módulo chamador. |
| `count = 2` | Cria duas instâncias da mesma configuração. |
| `count.index` | Identifica cada instância pelos índices `0` e `1`. |
| `tostring(count.index + 1)` | Produz os sufixos `"1"` e `"2"`. |
| `path.module` | Aqui, aponta para o diretório do módulo raiz que contém a chamada. |
| `module.pets[*].pet_id` | Reúne o resultado de todas as instâncias em uma sequência. |

No `main.tf` atual, o sufixo numérico é convertido automaticamente para a variável `string`. A expressão `trimspace("0644 ")` remove o espaço final antes de enviar a permissão ao módulo.

O resultado esperado é:

```text
files/
├── pet-1.txt
└── pet-2.txt
```

Cada arquivo contém o nome gerado pela instância correspondente. Sufixos distintos evitam que as duas instâncias gerenciem o mesmo caminho.

`count` é adequado aqui porque as instâncias seguem uma numeração simples. Para conjuntos identificados por nomes estáveis, `for_each` pode expressar melhor essa identidade. Os dois mecanismos são alternativas de repetição e não podem ser usados juntos na mesma chamada. Consulte a [documentação de chamadas de módulos](https://developer.hashicorp.com/terraform/language/modules/configuration).

## Providers e versões

O módulo `pets` declara `hashicorp/local >= 2.9.0` e `hashicorp/random >= 3.9.0` em `required_providers`. Esse bloco informa quais plugins e versões são necessários. Blocos `provider`, por sua vez, configuram esses plugins e devem ficar no módulo raiz quando necessários.

Neste laboratório, `local` e `random` utilizam as configurações padrão, sem necessidade de blocos `provider` explícitos. O arquivo `provider.tf`, que continha apenas um exemplo comentado de AWS, foi removido. As dependências continuam declaradas em `modules/pets/terraform.tf`.

Cada módulo deve declarar suas próprias dependências. As configurações padrão de providers podem ser herdadas da raiz, mas seus requisitos de origem e versão não são herdados. Para módulos compartilhados, a HashiCorp recomenda declarar versões mínimas compatíveis usando `>=`. Veja [providers dentro de módulos](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

O `pets` não declara `required_version` para o Terraform. Esse é um ponto a completar após definir a versão mínima suportada e testada.

Módulos também podem vir de um registry ou de repositórios Git. O argumento `version` de uma chamada aplica-se a módulos de registry; uma origem local como `./modules/pets` acompanha os arquivos do projeto. Consulte as [orientações para uso de módulos](https://developer.hashicorp.com/terraform/language/modules/configuration).

## Boas práticas revisadas

Durante a revisão, o exemplo foi simplificado para um pet por instância, deixando a repetição sob responsabilidade do chamador. Também foram adicionados requisitos explícitos de providers, descrição do output e configuração das permissões.

As entradas possuem tipo, descrição e `nullable = false`. As permissões usam os padrões `"0644"` para arquivos e `"0755"` para diretórios criados, com validação do formato octal. As validações de diretório e sufixo rejeitam strings vazias; ainda permitem strings compostas apenas por espaços e separadores de caminho no sufixo.

Os pontos de manutenção observados foram manter o README alinhado à interface, verificar a formatação com `terraform fmt` e validar a configuração com `terraform validate`. A validação estática não substitui a revisão do plano nem verifica todos os valores possíveis das entradas.

## Executando a prática

A partir da pasta `terraform` do repositório:

```bash
cd src/d5
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
terraform output pets
```

`init` prepara os módulos e providers necessários. `fmt -check` verifica a formatação sem modificar os arquivos. `validate` verifica a configuração, e `plan` mostra as alterações propostas. Revise o plano antes de confirmar `apply`.

Os arquivos são criados no ambiente em que o Terraform roda. Para consultar os recursos gerenciados, execute `terraform state list` em `src/d5`. Para remover os recursos desta configuração, incluindo os arquivos gerados, execute `terraform destroy` no mesmo diretório e revise a confirmação.
