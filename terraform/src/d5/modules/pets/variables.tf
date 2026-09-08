variable "dir_files" {
  description = "Diretório onde será criado os arquivos de pets"
  type        = string
  validation {
    condition     = length(var.dir_files) > 0 
    error_message = "O valor não pode ser vazio."
  }
  nullable = false
}


variable "suffix" {
  description = "Sufixo para os nomes dos arquivos de pets"
  type        = string
  validation {
    condition     = length(var.suffix) > 0
    error_message = "O sufixo não pode ser vazio."
  }
  nullable = false
}

variable "directory_permissions" {
  description = "Permissões do diretório onde serão criados os arquivos de pets"
  type        = string
  default     = "0755"
  validation {
    condition     = length(var.directory_permissions) > 0 && can(regex("^0[0-7]{3}$", var.directory_permissions))
    error_message = "As permissões do diretório não podem ser vazias, e devem estar no formato octal (ex: 0755)."
  }

  nullable = false
}

variable "file_permissions" {
  description = "Permissões dos arquivos de pets"
  type        = string
  default     = "0644"
  validation {
    condition     = length(var.file_permissions) > 0 && can(regex("^0[0-7]{3}$", var.file_permissions))
    error_message = "As permissões dos arquivos não podem ser vazias, e devem estar no formato octal (ex: 0644)."
  }

  nullable = false
}