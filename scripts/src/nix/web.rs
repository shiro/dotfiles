use std::{fmt::Display, path::Path};

use clap::arg;
use scripts::*;

#[derive(Debug)]
enum PackageManager {
    Yarn,
    Pnpm,
}

impl Display for PackageManager {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(match self {
            PackageManager::Yarn => "yarn",
            PackageManager::Pnpm => "pnpm",
        })
    }
}

fn get_package_manager() -> Option<PackageManager> {
    if Path::new("pnpm-lock.yaml").is_file() {
        return Some(PackageManager::Pnpm);
    }
    if Path::new("yarn.lock").is_file() {
        return Some(PackageManager::Yarn);
    }
    None
}

fn main() -> Result<()> {
    use clap::Command;
    let cmd = clap::command!()
        .subcommand_required(true)
        .allow_external_subcommands(true)
        .subcommand(
            Command::new("add")
                .about("add a dependency")
                .arg(arg!(-d --dev "add as dev dependency"))
                .arg(arg!(-o --optional "add as optional dependency"))
                .arg(arg!(<dependency> ... "list of dependencies")),
        )
        .subcommand(
            Command::new("remove")
                .about("remove a dependency")
                .arg(arg!(<dependency> ... "list of dependencies")),
        )
        .subcommand(Command::new("upgrade").about("upgrade dependencies"));
    let matches = &cmd.get_matches();

    let package_manager = match get_package_manager() {
        Some(v) => v,
        None => return Err(anyhow!("no package manager lockfile found")),
    };

    match matches.subcommand() {
        Some(("add", args)) => {
            let dependencies: Vec<String> = args
                .get_many("dependency")
                .unwrap()
                .into_iter()
                .cloned()
                .collect();
            let dev = args.get_one("dev").cloned().unwrap_or(false);
            let optional = args.get_one("optional").cloned().unwrap_or(false);
            match package_manager {
                PackageManager::Yarn => run_cmd_interactive(&format!(
                    "{package_manager} add {} {} {}",
                    if dev { "--dev" } else { "" },
                    if optional { "--optional" } else { "" },
                    dependencies.join(" ")
                ))?,
                PackageManager::Pnpm => run_cmd_interactive(&format!(
                    "{package_manager} add {} {} {}",
                    if dev { "--save-dev" } else { "" },
                    if optional { "--save-optional" } else { "" },
                    dependencies.join(" ")
                ))?,
            };
        }
        Some(("remove", args)) => {
            let dependencies: Vec<String> = args
                .get_many("dependency")
                .unwrap()
                .into_iter()
                .cloned()
                .collect();
            match package_manager {
                PackageManager::Yarn | PackageManager::Pnpm => run_cmd_interactive(&format!(
                    "{package_manager} remove {}",
                    dependencies.join(" ")
                ))?,
            };
        }
        Some(("upgrade", _args)) => {
            run_cmd_interactive("npx --yes npm-check-updates -i --format group --install always")?;
        }
        Some((cmd, args)) => {
            let args: Vec<String> = args
                .get_many("")
                .unwrap()
                .map(|v: &std::ffi::OsString| v.to_str().unwrap().to_string())
                .collect();
            let args_str = if !args.is_empty() {
                &format!(" {}", args.join(" "))
            } else {
                ""
            };
            run_cmd_interactive(&format!("{package_manager} {cmd}{args_str}"))?;
        }
        _ => unreachable!(),
    };

    Ok(())
}
