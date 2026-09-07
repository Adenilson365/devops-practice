resource local_file "function" {
  content  = join(",", [1,2,3,4,5])
  filename = "${path.module}/file/join.txt"
}

resource local_file "practice" {
  content  = upper("hello world")
  filename = "${path.module}/file/upper.txt"
}

resource local_file "lower" {
  content  = lower("HELLO WORLD")
  filename = "${path.module}/file/lower.txt"
}

resource local_file "replace" {
  content  = replace("hello world", "world", "terraform")
  filename = "${path.module}/file/replace.txt"
}

resource local_file "trimspace" {
  content  = trimspace("   hello world   ")
  filename = "${path.module}/file/trimspace.txt"
}

resource local_file "chomp" {
  content  = chomp("hello world\n")
  filename = "${path.module}/file/chomp.txt"
}

resource local_file "file" {
  content  = fileexists("${path.module}/READMa.md") ? file("${path.module}/README.md") : "Arquivo Informado não existe"
  filename = "${path.module}/file/file.txt"
}

resource local_file "exp_for"{
  content  = join(",", [for i in range(1, 6) : i])
  filename = "${path.module}/file/exp_for.txt"
}

resource local_file "exp_for_if"{
  content  = join(",", [for i in range(1, 6) : i if i % 2 == 0])
  filename = "${path.module}/file/exp_for_if.txt"
}

resource local_file "exp_for_index"{
  content  = join(",", [for i, v in ["A","B","C","D","E"] : "${i} - ${v}"])
  filename = "${path.module}/file/exp_for_index.txt"
}

resource local_file "exp_for_map"{
  content  = join(",", [for k, v in {A=1,B=2,C=3,D=4,E=5} : "${k} - ${v}"])
  filename = "${path.module}/file/exp_for_map.txt"
}

resource local_file "exp_try" {
  content  = try(1/0, "Erro na operação")
  filename = "${path.module}/file/exp_try.txt"
}

resource local_file "exp_lookup" {
  content  = lookup({A=1,B=2,C=3,D=4,E=5}, "G", "Chave não encontrada")
  filename = "${path.module}/file/exp_lookup.txt"
}

resource local_file "exp_can" {
  content  = can(tolist(null)) ? "Operação realizada com sucesso" : "Erro na operação"
  filename = "${path.module}/file/exp_can.txt"
}


# resource local_file "flatten" {
#   content  = flatten([["1","2"],["3","4"],[["5","6","7"],["8","9"]]])
#   filename = "${path.module}/file/flatten.txt"
# }