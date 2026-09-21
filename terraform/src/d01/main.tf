
resource "local_file" "bool_example" {
  content  = var.content_bool
  filename = "${path.module}/files/${var.name_string}_bool.txt"
}

resource "local_file" "number_example" {
  content  = var.content_number
  filename = "${path.module}/files/${var.name_string}_number.txt"
}

resource "local_file" "list_example" {
  content  = join("\n", var.content_list)
  filename = "${path.module}/files/${var.name_string}_list.txt"
}

resource "local_file" "map_example" {
  content  = join("\n", [var.content_map.vm1, var.content_map.cpu, var.content_map.bkp])
  filename = "${path.module}/files/${var.name_string}_map.txt"
}

resource "local_file" "object_example" {
  content  = join("\n", [var.content_object.vm1, var.content_object.cpu, var.content_object.bkp])
  filename = "${path.module}/files/${var.name_string}_object.txt"
}

resource "local_file" "set_example" {
  content  = join("\n", var.content_set)
  filename = "${path.module}/files/${var.name_string}_set.txt"
}

resource "local_file" "tuple_example" {
  content  = join("\n", [var.content_tuple[0], var.content_tuple[1], var.content_tuple[2]])
  filename = "${path.module}/files/${var.name_string}_tuple.txt"
}

resource "local_file" "sensitive_example" {
  content  = var.content_sensitive
  filename = "${path.module}/files/${var.name_string}_sensitive.txt"
}

