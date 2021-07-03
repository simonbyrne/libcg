This is a template that was used to generate the scaffolding under `CG/`.

It's unlikely that you'll want to rerun this as-is, as it will overwrite files
in that directory that have been modified.

If you wish to run it, update the template name in `template.jl`, and run

```bash
julia --project=. -e 'import Pkg; Pkg.add(url="https://github.com/kmsquire/PkgTemplates.jl.git", rev="feature/package_compiler_library_creation")'
julia --project=. -e "import Pkg; Pkg.instantiate()"
julia --project=. template.jl
```
