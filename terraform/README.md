### Studies about Terraform and preparation to hashicorp certification

### Topics:

- [Variables and Version Constraints (d1)](./src/d01/README.md) — Input variables, validation, precedence, and Terraform/provider version constraints.
- [Meta Arguments (d2)](./src/d02/README.md) — Resource dependencies and repetition with `depends_on`, `count`, and `for_each`.
- [Provisioners (d3)](./src/d03/README.md) — Using `local-exec`, `remote-exec`, and `file`, including execution timing and failure handling.
- [Expressions and Functions (d4)](./src/d04/README.md) — Transforming collections with `for`, splat expressions, and built-in functions.
- [Modules (d5)](./src/d05/README.md) — Organizing reusable modules with inputs, outputs, providers, and `count`.
- [Pets Module (d5)](./src/d05/modules/pets/README.md) — Module inputs, permissions, and outputs for generating pet names and saving them to local files.
- [State Management (d6–d9)](./src/d06-7-8-9/README.md) — Local and remote state, inspection commands, dependency graphs, refactoring, and resource replacement.
- [Pets Module (d6–d9)](./src/d06-7-8-9/modules/pets/README.md) — Reference for the pet-name and local-file module used in the state management lab.
- [Import (d10)](./src/d10/README.md) — Importing an existing AWS EC2 instance and checking its configuration against Terraform state.
- [Lifecycle (d11)](./src/d11/README.md) — Resource lifecycle rules, replacement behavior, and custom preconditions and postconditions.
- [Workspaces (d12)](./src/d12/README.md) — Workspace commands, separate states, environment configuration, and CLI versus HCP Terraform workspaces.
- [Terraform Tests (d13)](./src/d13/README.md) — S3 module test configuration and notes on Terraform state.
- [Dependency Graph and Planning (d14)](./src/d14/README.md) — Dependency graphs, `-refresh-only`, in-place updates, and saved plans with `-out`.
