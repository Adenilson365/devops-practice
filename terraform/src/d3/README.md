### Provisioner

# Provisioners no Terraform

Provisioners permitem executar ações auxiliares durante a criação ou a destruição de um recurso. Eles podem executar comandos na máquina em que o Terraform está sendo executado, copiar arquivos ou executar comandos em uma máquina remota.

> A HashiCorp recomenda usar provisioners apenas como último recurso. O Terraform não consegue representar o resultado desses comandos no plano nem gerenciar seus efeitos como parte do estado. Sempre que possível, prefira `user_data`/cloud-init, imagens previamente configuradas, recursos do provider ou ferramentas de gerenciamento de configuração.

Documentação oficial: [Perform post-apply operations using provisioners](https://developer.hashicorp.com/terraform/language/provisioners).

### Provisioner

## Tipos de provisioner

| Tipo          | Onde executa                        | Uso comum                                                                |
| ------------- | ----------------------------------- | ------------------------------------------------------------------------ |
| `local-exec`  | Na máquina que executa o Terraform  | Gerar arquivos locais, chamar uma CLI ou integrar com um sistema externo |
| `remote-exec` | No recurso remoto, por SSH ou WinRM | Executar comandos de configuração após a criação do recurso              |
| `file`        | Origem local e destino remoto       | Copiar arquivos ou diretórios para o recurso                             |

Por padrão, os provisioners de criação são executados depois que o recurso é criado. Se houver mais de um bloco, eles são executados na ordem em que aparecem na configuração.

## Exemplo deste diretório

O arquivo [`main.tf`](./main.tf) cria uma instância EC2 e usa dois provisioners:

```hcl
provisioner "local-exec" {
  command = "echo ${self.private_ip} > private_ip.txt"
}

provisioner "remote-exec" {
  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("../kp-linux-dev.pem")
  }

  inline = [
    "sudo yum update -y",
    "sudo yum install -y httpd",
    "sudo systemctl start httpd",
    "sudo systemctl enable httpd",
    "echo '<h1>Welcome to Terraform EC2 Instance</h1>' | sudo tee /var/www/html/index.html"
  ]
}
```

O fluxo é o seguinte:

1. O Terraform solicita a criação da instância EC2.
2. O `local-exec` grava o IP privado no arquivo local `private_ip.txt`.
3. O `remote-exec` acessa a instância por SSH.
4. Os comandos em `inline` atualizam os pacotes, instalam e iniciam o Apache e criam a página inicial.

Dentro de um provisioner, `self` representa o recurso ao qual o bloco pertence. Neste exemplo, `self.private_ip` e `self.public_ip` referenciam os endereços da própria instância.

## `local-exec`

O `local-exec` executa um comando no ambiente local: notebook, servidor de CI/CD ou agente do Terraform. Ele **não** executa o comando dentro da EC2.

Principais argumentos:

- `command`: comando obrigatório;
- `working_dir`: diretório em que o comando será executado;
- `interpreter`: interpretador e seus argumentos, como `["/bin/bash", "-c"]`;
- `environment`: variáveis de ambiente entregues ao processo;
- `quiet`: oculta o comando impresso pelo Terraform, mas não a saída gerada por ele.

Para valores dinâmicos, prefira variáveis de ambiente em vez de interpolá-los diretamente no comando. Isso reduz o risco de injeção de comandos:

```hcl
provisioner "local-exec" {
  command = "printf '%s\n' \"$INSTANCE_IP\" > private_ip.txt"

  environment = {
    INSTANCE_IP = self.private_ip
  }
}
```

## `remote-exec`

O `remote-exec` executa comandos no recurso remoto. É necessário fornecer um bloco `connection`, dentro do recurso ou do próprio provisioner.

As formas de definir os comandos são mutuamente exclusivas:

- `inline`: lista de comandos;
- `script`: caminho local de um único script que será enviado e executado;
- `scripts`: lista de scripts locais enviados e executados em sequência.

Exemplo com script:

```hcl
provisioner "remote-exec" {
  script = "scripts/configure-web.sh"

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    timeout     = "5m"
  }
}
```

Para o SSH funcionar, a instância deve estar acessível a partir da máquina que executa o Terraform, a chave deve corresponder ao `key_name`, o usuário deve estar correto e o security group deve liberar a porta 22 para uma origem segura.

## `file`

O provisioner `file` copia um arquivo, diretório ou conteúdo para a máquina remota usando a conexão configurada:

```hcl
connection {
  type        = "ssh"
  host        = self.public_ip
  user        = "ec2-user"
  private_key = file(var.private_key_path)
}

provisioner "file" {
  source      = "files/index.html"
  destination = "/tmp/index.html"
}

provisioner "remote-exec" {
  inline = [
    "sudo mv /tmp/index.html /var/www/html/index.html"
  ]
}
```

Também é possível substituir `source` por `content` para criar o conteúdo diretamente. `source` e `content` não podem ser usados juntos no mesmo bloco.

## Execução na destruição

Um provisioner pode executar antes da destruição do recurso com `when = destroy`:

```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo 'A instância ${self.id} será removida'"
}
```

Provisioners de destruição só podem referenciar atributos por meio de `self`, `count.index` ou `each.key`. Eles não são executados se o recurso já estiver marcado como corrompido (`tainted`) e podem não ser executados quando o bloco do recurso é removido diretamente da configuração. Para garantir sua execução, aplique primeiro uma configuração com `count = 0` e só depois remova o bloco.

## Tratamento de falhas

O argumento `on_failure` controla o comportamento quando um comando falha:

```hcl
provisioner "local-exec" {
  command    = "./register-instance.sh"
  on_failure = continue
}
```

- `fail` é o padrão: interrompe o `apply`; em um provisioner de criação, o recurso fica marcado para substituição porque pode ter sido parcialmente configurado;
- `continue` registra o erro e continua a operação.

Use `continue` somente quando a falha for realmente aceitável, pois o Terraform poderá concluir o `apply` sem que a ação tenha sido realizada.

## Quando o provisioner executa novamente

Um provisioner de criação é executado na criação do recurso, não em todo `terraform apply`. Alterar apenas o conteúdo do bloco pode não provocar uma nova execução. Para uma ação que precise ser repetida quando uma entrada mudar, use o recurso nativo `terraform_data` com `triggers_replace`:

```hcl
resource "terraform_data" "configure" {
  triggers_replace = [
    aws_instance.example.id,
    filesha256("scripts/configure-web.sh")
  ]

  provisioner "remote-exec" {
    script = "scripts/configure-web.sh"

    connection {
      type        = "ssh"
      host        = aws_instance.example.public_ip
      user        = "ec2-user"
      private_key = file(var.private_key_path)
    }
  }
}
```

Ao mudar o ID da instância ou o conteúdo do script, o Terraform substitui `terraform_data.configure` e executa o provisioner novamente, sem precisar substituir a EC2 apenas para repetir a configuração.

## Pré-requisitos para executar o exemplo

- Terraform compatível com `required_version`;
- credenciais AWS configuradas no ambiente;
- AMI, subnet, security group e key pair existentes na região `us-east-1`;
- arquivo da chave privada no caminho esperado por `file("../kp-linux-dev.pem")`;
- acesso de rede por SSH à instância.

Execute dentro de `src/d3`:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Após a criação, confira `private_ip.txt` e acesse o IP público da instância por HTTP, desde que a porta 80 esteja liberada no security group.

Para remover os recursos:

```bash
terraform destroy
```

## Boas práticas

- Evite provisioners quando o provider possuir um recurso específico para a mesma operação.
- Para inicialização de instâncias, prefira `user_data` ou cloud-init.
- Escreva comandos idempotentes, para que uma repetição não cause efeitos indesejados.
- Não armazene chaves privadas no repositório nem grave segredos em comandos, logs ou no estado.
- Restrinja SSH a endereços confiáveis e considere mecanismos sem acesso direto, como AWS Systems Manager.
- Defina timeouts adequados e garanta que o host esteja pronto antes da conexão.
- Use `environment` no `local-exec` para passar dados dinâmicos com mais segurança.
- Lembre-se de que o Terraform não sanitiza comandos nem valores interpolados.

## Referências

- [Provisioners](https://developer.hashicorp.com/terraform/language/provisioners)
- [Blocos `provisioner` e `connection`](https://developer.hashicorp.com/terraform/language/block/resource)
- [Recurso `terraform_data`](https://developer.hashicorp.com/terraform/language/resources/terraform-data)
