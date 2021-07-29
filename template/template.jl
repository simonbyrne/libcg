using PkgTemplates

lib_template = Template(
    dir="..",
    plugins=[
        PackageCompilerLib(lib_name="cg")
    ]
)
lib_template("CG")
