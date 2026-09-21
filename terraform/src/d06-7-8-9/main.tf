module "pets" {
  source                = "./modules/pets"
  dir_files             = "${path.module}"
  count                 = 2
  suffix                = count.index + 1
  file_permissions      = trimspace("0644 ")
  directory_permissions = trimspace("0755")
}

output "pets" {
  description = "Retorna os IDs dos pets gerados"
  value       = module.pets[*].pet_id
}

