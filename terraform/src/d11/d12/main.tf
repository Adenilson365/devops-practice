resource "local_file" "arquivo" {
  content  = var.conteudo
  filename = "${path.module}/${terraform.workspace}/${var.nome_arquivo}"
}

variable "conteudo" {
  type        = string
  description = "Conteúdo do arquivo"
}

variable "nome_arquivo" {
  type        = string
  description = "Nome do arquivo"
}

