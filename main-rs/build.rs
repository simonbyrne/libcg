fn main() {
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    println!(r"cargo:rustc-link-search={}/../target/lib", &manifest_dir);
    println!("cargo:rustc-link-lib=cg");
    println!("cargo:rustc-link-lib=dylib=julia");
    println!("cargo:rerun-if-changed=build.rs");
}

