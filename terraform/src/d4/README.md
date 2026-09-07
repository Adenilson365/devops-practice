# Expressões e funções no Terraform

Expressões representam ou calculam valores usados na configuração. Uma chamada de função também é uma expressão: recebe argumentos e retorna um resultado. Veja a [introdução oficial sobre expressões](https://developer.hashicorp.com/terraform/language/expressions).

## Expressões básicas

| Tipo         | Exemplo                          | Uso                                |
| ------------ | -------------------------------- | ---------------------------------- |
| Literal      | `"dev"`, `3`, `true`             | Definir valores diretamente        |
| Referência   | `var.ambiente`, `local.nome`     | Acessar variáveis e valores locais |
| Aritmética   | `2 + 3`                          | Calcular valores numéricos         |
| Comparação   | `var.ambiente == "prod"`         | Retornar verdadeiro ou falso       |
| Lógica       | `true && false`                  | Combinar condições                 |
| Interpolação | `"app-${var.ambiente}"`          | Inserir um valor em um texto       |
| Condicional  | `var.ambiente == "prod" ? 3 : 1` | Escolher entre dois valores        |

Na expressão condicional, a sintaxe é `condicao ? valor_se_verdadeiro : valor_se_falso`. Os dois resultados precisam ter tipos compatíveis.

Exemplo com variável e valores locais:

```hcl
variable "ambiente" {
  type    = string
  default = "dev"
}

locals {
  nome     = "app-${var.ambiente}"
  replicas = var.ambiente == "prod" ? 3 : 1
}
```

Com o valor padrão, `local.nome` será `"app-dev"` e `local.replicas` será `1`.

### Coleções, acesso e operadores

Use colchetes para sequências e chaves para objetos. Os índices começam em zero:

```hcl
locals {
  servicos = ["web", "api", "db"]
  portas   = { web = 80, api = 8080 }

  primeiro_servico = local.servicos[0] # "web"
  porta_web       = local.portas.web  # 80
  porta_api       = local.portas["api"] # 8080
}
```

Operadores disponíveis:

- Aritméticos: `+`, `-`, `*`, `/` e `%` (resto da divisão).
- Comparação: `==`, `!=`, `<`, `<=`, `>` e `>=`.
- Lógicos: `&&` (e), `||` (ou) e `!` (negação).

Parênteses ajudam a deixar a ordem de avaliação explícita: `(2 + 3) * 4` resulta em `20`.

## Expressões `for`

Uma expressão `for` percorre uma coleção e constrói um novo valor. A entrada pode ser uma lista, tupla, conjunto, mapa ou objeto. Consulte a [documentação oficial de `for`](https://developer.hashicorp.com/terraform/language/expressions/for).

### Estrutura e formato do resultado

```hcl
# Sequência de resultados
[for item in colecao : resultado]

# Resultado com chaves e valores
{ for item in colecao : chave => valor }
```

Esses modelos mostram a sintaxe; `colecao`, `resultado`, `chave` e `valor` devem ser substituídos pelas expressões desejadas.

`[]` produz uma tupla e `{}` produz um objeto. Conforme o contexto e a compatibilidade dos elementos, o Terraform pode convertê-los em listas ou mapas. Use `toset(...)` quando precisar de um conjunto.

### Transformar valores

```hcl
[for nome in ["web", "api"] : upper(nome)]
# Resultado: ["WEB", "API"]

[for numero in [1, 2, 3] : numero * 2]
# Resultado: [2, 4, 6]
```

### Acessar o índice

Com dois identificadores, o primeiro recebe o índice e o segundo recebe o valor:

```hcl
[for indice, nome in ["web", "api"] : "${indice}-${nome}"]
# Resultado: ["0-web", "1-api"]
```

### Percorrer mapas

Em mapas e objetos, os dois identificadores representam a chave e o valor. Usando apenas um identificador, ele recebe o valor.

```hcl
[for nome, porta in { web = 80, api = 8080 } : "${nome}:${porta}"]
# Resultado: ["api:8080", "web:80"]

{ for nome, porta in { web = 80, api = 8080 } : upper(nome) => porta }
# Resultado: { API = 8080, WEB = 80 }
```

Ao produzir uma sequência a partir de um mapa ou objeto, as chaves são percorridas em ordem lexicográfica. Conjuntos de strings também usam ordem lexicográfica; não dependa da ordem de conjuntos de outros tipos.

### Criar um objeto a partir de uma sequência

```hcl
{ for nome in ["web", "api"] : nome => upper(nome) }
# Resultado: { api = "API", web = "WEB" }
```

### Filtrar elementos com `if`

O `if` no final inclui apenas os elementos que atendem à condição:

```hcl
[for numero in [1, 2, 3, 4] : numero if numero > 2]
# Resultado: [3, 4]

{ for nome, porta in { web = 80, api = 8080 } : nome => porta if porta > 1000 }
# Resultado: { api = 8080 }
```

### Usar uma condicional no resultado

A condicional `? :` escolhe o valor de cada item, mantendo a quantidade de elementos:

```hcl
[for numero in [1, 2, 3, 4] : numero % 2 == 0 ? "par" : "impar"]
# Resultado: ["impar", "par", "impar", "par"]
```

### Trabalhar com objetos e agrupar resultados

Para chaves repetidas no resultado, use `...` depois do valor para agrupar os itens. Sem esse agrupamento, chaves duplicadas causam erro.

```hcl
locals {
  servicos = [
    { nome = "web", ambiente = "prod" },
    { nome = "api", ambiente = "prod" },
    { nome = "worker", ambiente = "dev" }
  ]

  nomes = [for servico in local.servicos : servico.nome]
  # Resultado: ["web", "api", "worker"]

  por_ambiente = {
    for servico in local.servicos : servico.ambiente => servico.nome...
  }
  # Resultado: { dev = ["worker"], prod = ["web", "api"] }
}
```

### Combinar `for` aninhados com `flatten`

```hcl
flatten([
  for ambiente in ["dev", "prod"] : [
    for servico in ["web", "api"] : "${ambiente}-${servico}"
  ]
])
# Resultado: ["dev-web", "dev-api", "prod-web", "prod-api"]
```

O `for` interno cria uma sequência para cada ambiente. `flatten` reúne essas sequências em uma única lista.

### Extrair atributos com splat

Para extrair um atributo de todos os objetos de uma sequência, a expressão splat oferece uma forma curta:

```hcl
# Considerando local.servicos do exemplo de agrupamento:
local.servicos[*].nome
# Equivalente a: [for servico in local.servicos : servico.nome]
```

### Diferença entre `for`, `for_each` e `dynamic`

| Recurso da linguagem | Finalidade |
| --- | --- |
| Expressão `for` | Construir e transformar valores de coleções |
| Meta-argumento `for_each` | Criar instâncias de recursos ou módulos a partir de um mapa ou conjunto de strings |
| Bloco `dynamic` | Gerar blocos aninhados repetidos dentro da configuração |

Uma expressão `for` pode preparar um mapa para `for_each`; sozinha, ela não cria recursos nem blocos. Os exemplos de `locals` desta seção são independentes: ao combiná-los no mesmo módulo, evite repetir nomes locais.

## Funções

A sintaxe de chamada é `nome_da_funcao(argumento1, argumento2)`. O Terraform oferece funções para trabalhar com textos, números, coleções e arquivos. Consulte o [catálogo oficial de funções](https://developer.hashicorp.com/terraform/language/functions).

### Funções usadas neste diretório

O arquivo [`main.tf`](./main.tf) usa funções para preparar o conteúdo de arquivos locais.

| Função      | O que faz                                 | Exemplo                                        | Resultado             |
| ----------- | ----------------------------------------- | ---------------------------------------------- | --------------------- |
| `join`      | Une textos com um separador               | `join(",", ["1", "2", "3"])`                   | `"1,2,3"`             |
| `upper`     | Converte para maiúsculas                  | `upper("hello world")`                         | `"HELLO WORLD"`       |
| `lower`     | Converte para minúsculas                  | `lower("HELLO WORLD")`                         | `"hello world"`       |
| `replace`   | Substitui um trecho do texto              | `replace("hello world", "world", "terraform")` | `"hello terraform"`   |
| `trimspace` | Remove espaços em branco das extremidades | `trimspace("   hello world   ")`               | `"hello world"`       |
| `chomp`     | Remove quebras de linha do final          | `chomp("hello world\n")`                       | `"hello world"`       |
| `file`      | Lê um arquivo de texto UTF-8 existente    | `file("${path.module}/README.md")`             | Conteúdo deste README |
| `flatten`   | Remove o aninhamento de listas            | `flatten([["1", "2"], ["3"]])`                 | `["1", "2", "3"]`     |

`path.module` representa o caminho do módulo em que a expressão está escrita. O arquivo lido por `file` deve existir antes do início da execução do Terraform.

### `flatten` e composição de funções

`flatten` transforma listas aninhadas em uma única lista, inclusive quando há vários níveis. Ela não transforma o resultado em texto. Veja a [documentação de `flatten`](https://developer.hashicorp.com/terraform/language/functions/flatten).

```hcl
flatten([["1", "2"], ["3", "4"], [["5", "6", "7"], ["8", "9"]]])
# Resultado: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
```

O argumento `content` de `local_file` espera uma string. No `main.tf` atual, o recurso `local_file.flatten` passa o resultado de `flatten` diretamente para esse argumento, causando incompatibilidade de tipo. Para gravar os elementos como texto separado por vírgulas, combine `flatten` com `join`:

```hcl
resource "local_file" "flatten" {
  content  = join(",", flatten([["1", "2"], ["3", "4"]]))
  filename = "${path.module}/file/flatten.txt"
}
```

Nesse exemplo, o conteúdo será `1,2,3,4`.

### `can`: verificar se uma expressão pode ser avaliada

Sintaxe: `can(expressao)`. Retorna `true` quando a expressão é avaliada sem erro e `false` quando ocorre um erro capturável. É útil principalmente em validações de variáveis. Veja a [documentação de `can`](https://developer.hashicorp.com/terraform/language/functions/can).

Exemplo do `main.tf`:

```hcl
resource "local_file" "exp_can" {
  content  = can(tolist(null)) ? "Operação realizada com sucesso" : "Erro na operação"
  filename = "${path.module}/file/exp_can.txt"
}
```

`tolist(null)` é válido: retorna um valor nulo tipado como lista. Portanto, `can` retorna `true` e o conteúdo será `"Operação realizada com sucesso"`. Isso verifica a ausência de erro, não se o resultado contém dados.

Compare no console:

```hcl
can(tolist(null))
# Resultado: true

can(tolist("texto"))
# Resultado: false
```

### `try`: retornar o primeiro resultado sem erro

Sintaxe: `try(expressao1, expressao2, ...)`. Avalia as alternativas em ordem e retorna o primeiro resultado que não produz erro. Se todas falharem, a função retorna um erro. É útil para fornecer valores alternativos ao acessar atributos opcionais ou converter dados. Veja a [documentação de `try`](https://developer.hashicorp.com/terraform/language/functions/try).

Exemplo do `main.tf`:

```hcl
resource "local_file" "exp_try" {
  content  = try(1 / 0, "Erro na operação")
  filename = "${path.module}/file/exp_try.txt"
}
```

No Terraform, `1 / 0` resulta em `+Inf` (infinito positivo). Assim, esse exemplo não seleciona `"Erro na operação"`. Para observar o uso do valor alternativo, experimente uma conversão inválida:

```hcl
try(tonumber("abc"), "Erro na operação")
# Resultado: "Erro na operação"

try(tonumber("42"), 0)
# Resultado: 42

try(null, "valor padrão")
# Resultado: null
```

`null` é um resultado válido e não faz `try` avançar para a próxima alternativa. Tanto `try` quanto `can` capturam erros de avaliação; não corrigem sintaxe inválida nem referências a variáveis ou valores locais não declarados.

### `lookup`: buscar uma chave com valor padrão

Sintaxe: `lookup(mapa, chave, valor_padrao)`. Retorna o valor da chave quando ela existe; caso contrário, retorna o padrão informado. Veja a [documentação de `lookup`](https://developer.hashicorp.com/terraform/language/functions/lookup).

Exemplo do `main.tf`:

```hcl
resource "local_file" "exp_lookup" {
  content  = lookup({ A = 1, B = 2, C = 3, D = 4, E = 5 }, "G", "Chave não encontrada")
  filename = "${path.module}/file/exp_lookup.txt"
}
```

Como a chave `G` não existe, o conteúdo será `"Chave não encontrada"`.

```hcl
lookup({ A = 1, B = 2 }, "A", 0)
# Resultado: 1

lookup({ A = 1, B = 2 }, "G", 0)
# Resultado: 0

lookup({ A = null }, "A", "valor padrão")
# Resultado: null
```

O padrão é usado somente quando a chave está ausente. Para mapas tipados, como `map(number)`, o padrão deve ser compatível com o tipo dos elementos: use, por exemplo, `0`. O literal `{ A = 1, ... }` do laboratório é um objeto, no qual a busca pela chave ausente permite o padrão textual mostrado.

### Quando usar cada função

| Função | Objetivo | Retorno |
| --- | --- | --- |
| `can` | Verificar se uma expressão é avaliada sem erro | Booleano |
| `try` | Escolher a primeira alternativa avaliada sem erro | Valor da alternativa |
| `lookup` | Buscar uma chave e fornecer um padrão se ela não existir | Valor encontrado ou padrão |

## Praticando no console

Com o Terraform instalado, abra `terraform console` em um diretório vazio para experimentar as expressões sem depender da configuração deste laboratório:

```bash
mkdir -p /tmp/terraform-expressoes
cd /tmp/terraform-expressoes
terraform console
```

Digite uma expressão por vez:

```text
> upper("terraform")
"TERRAFORM"

> join("-", ["app", "dev"])
"app-dev"

> 5 > 3 ? "maior" : "menor ou igual"
"maior"

> length(["web", "api", "db"])
3
```

Use `exit` para sair. Os exemplos com `var.ambiente` e `local.nome` exigem as declarações correspondentes em arquivos `.tf` no diretório do console.
