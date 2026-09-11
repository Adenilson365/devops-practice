
resource "random_pet" "pet" {
  length    = 2
  separator = "-"
}


resource "local_file" "mod_pet" {
  content              = random_pet.pet.id
  filename             = "${var.dir_files}/files/pet-${var.suffix}.txt"
  directory_permission = var.directory_permissions
  file_permission      = var.file_permissions
}


