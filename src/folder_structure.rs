use crate::*;

pub fn main() -> Result<()> {
    let home = std::env::var("HOME")?;

    println!("setting up folder structure");

    println!(
        indoc::indoc! {"
            relevant folders:
            |--- {}/
            | |--- bin/             local script files
            |
            |--- .local/            local files
            | |---> share/          temporary files
            | |---> config/         local configuration files
            |   |---> backup/       backup config
            |   |---> zsh/          zsh config
            |
            |--- project/           development projects
            |--- wallpapers/        wallpapers
        "},
        home
    );

    create_dir_all(format!("{}/wallpapers", home))?;
    let _ = symlink(
        format!("{home}/.dotfiles/wallpapers/sample-wallpaper.jpg"),
        format!("{home}/wallpapers/sample-wallpaper.jpg"),
    );

    Ok(())
}
