variable "name_string" {
  description = "Aceita apenas strings, se passar numeros ou booleanos, será convertido para string"
  type        = string
  default     = "default_name"
}

variable "content_numer" {
  description = "Aceita apenas numeros, inteiros ou decimais"
  type        = number
  default     = 1

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