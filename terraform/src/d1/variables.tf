variable "name_string" {
  description = "Aceita apenas strings, se passar numeros ou booleanos, será convertido para string"
  type        = string
  default     = "default_name"
}

variable "content_number" {
  description = "Aceita apenas numeros, inteiros ou decimais"
  type        = number
  default     = 0
  validation {
    condition =  var.content_number > 0
    error_message = "O valor da variável content_number deve ser um número maior que zero."
  }

}

variable "content_bool" {
  description = "Aceita apenas valores booleanos, true ou false"
  type        = bool
  default     = true
}

variable "content_list" {
  description = "Content to be written to the file"
  type        = list(string)
  default     = ["vm1", "vm2", "vm3"]
}

variable "content_object" {
  description = "Objeto é indexado, tem ordem e aceita tipos diferentes de valores, e determino elmentos na declaração da variável "
  type = object({
    vm1 = string
    cpu = number
    bkp = bool
  })
  default = {
    vm1 = "vm1"
    cpu = 2
    bkp = true
  }
}

variable "content_map" {
  description = "Mapa similar a object, mas não é indexado e não tem ordem"
  type        = map(string)
  default = {
    vm1 = "vm1"
    cpu = "2"
    bkp = "true"
  }
}

variable "content_set" {
  description = "Não aceita valores duplicados, não tem ordem e não é indexado"
  type        = set(string)
  default     = ["vm1", "vm2", "vm3"]
}

variable "content_tuple" {
  description = "Aceita tipos diferentes de valores, é indexado e tem ordem"
  type        = tuple([string, number, bool])
  default     = ["vm1", 2, true]
}

variable "content_sensitive" {
  description = "Aceita qualquer tipo de valor, mas é sensível a dados confidenciais"
  type        = string
  default     = "Password_default"
  sensitive   = true

}

