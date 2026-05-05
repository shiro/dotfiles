use crate::*;
use std::fs::copy;
use walkdir::WalkDir;

fn process_template_dir() -> Result<()> {
    let home = std::env::var("HOME")?;
    let cwd = std::env::current_dir()?;
    let template_dir_path = Path::new(&cwd).join("template");

    if !template_dir_path.exists() {
        return Ok(());
    }

    for entry in WalkDir::new(&template_dir_path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.path() != template_dir_path)
    {
        let dst_path = Path::new(&home).join(entry.path().strip_prefix(&template_dir_path)?);
        if !dst_path.exists() {
            if entry.path().is_dir() {
                create_dir_all(&dst_path)?;
            } else if entry.path().is_file() {
                if let Some(parent) = dst_path.parent() {
                    create_dir_all(parent)?;
                }
                copy(entry.path(), &dst_path)?;
            }
        }
    }

    Ok(())
}

pub fn main() -> Result<()> {
    let home = std::env::var("HOME")?;

    println!("setting up folder structure");

    create_dir_all(format!("{}/project", home))?;

    create_dir_all(format!("{}/wallpapers", home))?;
    for entry in std::fs::read_dir("wallpapers")? {
        let entry = entry?;
        let path = std::fs::canonicalize(entry.path())?;
        if let Some(file_name) = path.file_name() {
            println!("{:?}", (&path, file_name));
            let _ = symlink(
                &path,
                format!("{home}/wallpapers/{}", file_name.to_string_lossy()),
            );
        }
    }

    process_template_dir()?;

    Ok(())
}
