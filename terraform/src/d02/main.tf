resource "local_file" "arq1" {
  content  = "arq1"
  filename = "${path.module}/files/arq1.txt"
  depends_on = [local_file.arq2]
}

resource "local_file" "arq2" {
  content  = "arq2"
  filename = "${path.module}/files/arq2.txt"
}

resource "local_file" "arq_count" {
  content  = "arq-${count.index + 1}"
  filename = "${path.module}/files/count/arq${count.index + 1}.txt"
  count    = 3
}

resource "local_file" "arq_for_each" {
  content  = "arq-${each.key}"
  filename = "${path.module}/files/for_each/arq-${each.key}.txt"
  for_each = toset(["a", "b", "c"])
}

resource "local_file" "arq_for_each_map" {
  content  = "arq-${each.key}-${each.value}"
  filename = "${path.module}/files/for_each_map/arq-${each.key}-${each.value}.txt"
  for_each = {
    a = "1"
    b = "2"
    c = "3"
  }
}