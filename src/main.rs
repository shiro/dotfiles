use anyhow::*;
use std::fs::create_dir_all;
use std::os::unix::fs::symlink;
use std::path::Path;

mod folder_structure;
use scripts::*;

fn main() -> Result<()> {
    let home = std::env::var("HOME")?;

    println!("Installing dotfiles.");
    println!("Initializing submodule(s)");

    create_dir_all(format!("{}/bin", home))?;
    create_dir_all(format!("{}/.local", home))?;
    create_dir_all(format!("{}/.local/share", home))?;
    create_dir_all(format!("{}/.local/share/dotfiles", home))?;
    create_dir_all(format!("{}/.local/share/misc", home))?;

    folder_structure::main()?;

    // link scripts
    let cwd = std::env::current_dir()?;

    std::env::set_current_dir(cwd.join("scripts"))?;

    // use Zfmt-debug=shallow for minimal gains
    std::env::set_var("RUSTFLAGS", "-Zlocation-detail=none");
    Exec::cmd("cargo")
        .args(&[
            // "build", "--release"
            // "+nightly",
            "build",
            "-Z",
            "build-std=std,panic_abort",
            "-Z",
            "build-std-features=optimize_for_size",
            "--target",
            current_platform::CURRENT_PLATFORM,
            "--release",
        ])
        .success_output()?;

    use walkdir::WalkDir;
    let dst_root = cwd
        .join("scripts/target/")
        .join(current_platform::CURRENT_PLATFORM)
        .join("release");

    for f in WalkDir::new(cwd.join("scripts/src"))
        .into_iter()
        .filter_map(|p| p.ok())
    {
        let p = f.into_path();

        if p.extension()
            .is_some_and(|ext| ext.to_string_lossy().ends_with("sh"))
        {
            let target = Path::new(&home).join("bin").join(p.file_stem().unwrap());
            if target.exists() || target.is_symlink() {
                std::fs::remove_file(&target)?;
            }

            let _ = symlink(&p, &target);

            let relpath = p.strip_prefix(&cwd.join("scripts/src"))?;
            println!("[link]  {}", relpath.to_string_lossy());
            continue;
        }

        if p.is_dir() {
            continue;
        }
        let p = p.strip_prefix(&cwd.join("scripts/src"))?;
        if p.starts_with("shared/") || p.file_name().unwrap() == "lib.rs" {
            continue;
        }
        let name = p.file_stem().unwrap();

        let binary_path = cwd.join(&dst_root).join(name);
        let target_path = Path::new(&home).join("bin").join(name);

        // reduce size further
        let _ = Exec::cmd("upx")
            .args(&["--best", "--lzma", &binary_path.to_string_lossy()])
            .success_output();

        println!("[build] {}", p.to_string_lossy());
        std::fs::copy(&binary_path, &target_path)?;
    }

    println!("Done. Reload your terminal.");
    Ok(())
}

// use: upx --best --lzma s2 for another 50% reduction
