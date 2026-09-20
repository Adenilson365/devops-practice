variable "project" {

  type = string

  validation {

    condition = length(var.project) >= 3

    error_message = "Project must contain at least 3 characters."

  }

}

variable "environment" {

  type = string

  validation {

    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )

    error_message = "Environment must be dev, staging or prod."

  }

}