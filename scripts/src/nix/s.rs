use scripts::*;
use serde::{Deserialize, Serialize};
use std::fs::{self};
use std::path::Path;

#[derive(Clone, Debug, Serialize, Deserialize)]
struct Generation {
    generation: u32,
    current: bool,
    #[serde(rename = "nixosVersion")]
    nixos_version: String,
}

fn list_generations() -> Result<Vec<Generation>> {
    let raw = Exec::cmd("nixos-rebuild")
        .args(&["list-generations", "--json"])
        .success_output()?
        .stdout_str();
    Ok(serde_json::from_str(&raw)?)
}

fn format_column(header_columns: &[&str], data_rows: Vec<Vec<String>>) -> (String, Vec<String>) {
    let mut header = "".to_string();
    let mut rows = vec!["".to_string(); data_rows.len()];

    for col_idx in 0..header_columns.len() {
        if col_idx != 0 {
            header.push_str(" ");
            rows.iter_mut().for_each(|v| v.push_str(" "));
        }

        let w = data_rows
            .iter()
            .map(|v| v[col_idx].len())
            .reduce(|l, r| l.max(r))
            .unwrap_or_default()
            .max(header_columns[col_idx].len());
        header.push_str(&format!("{: <w$}", header_columns[col_idx]));
        rows.iter_mut()
            .enumerate()
            .for_each(|(row_idx, v)| v.push_str(&format!("{: <w$}", data_rows[row_idx][col_idx])));
    }

    (header, rows)
}

fn select_generations() -> Result<Vec<Generation>> {
    let generations = list_generations()?;

    let (header, rows) = format_column(
        &["", "generation", "name"],
        generations
            .iter()
            .enumerate()
            .map(|(idx, v)| {
                vec![
                    idx.to_string(),
                    v.generation.to_string(),
                    v.nixos_version.to_string(),
                ]
            })
            .collect(),
    );

    let ret = Exec::cmd("fzf")
        .args(&["-m"])
        .args(&["--header", &header.trim_start()])
        .args(&["--bind", "enter:accept-non-empty"])
        .args(&["--with-nth", "2.."])
        .args(&[
            "--bind",
            "ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all",
        ])
        .stdin(rows.join("\n").as_ref())
        .success_output()?
        .stdout_str();

    let selected = ret
        .split("\n")
        .filter(|line| !line.is_empty())
        .map(|line| line.split_once(" ").unwrap().0.parse::<u32>().unwrap())
        .map(|idx| &generations[idx as usize])
        .cloned()
        .collect::<Vec<_>>();

    if selected.is_empty() {
        Err(anyhow!("no generation selected"))?;
    }

    Ok(selected)
}

fn select_generation() -> Result<Generation> {
    Ok(select_generations()?.into_iter().next().unwrap())
}

fn main() -> Result<()> {
    use clap::Command;
    let cmd = clap::command!()
        .subcommand_required(true)
        .subcommand(Command::new("list").about("lists all generations"))
        .subcommand(
            Command::new("new").about("builds a new generations"),
            // .arg(arg!(-l --list "lists test values").action(ArgAction::SetTrue)),
        )
        .subcommand(Command::new("test").about("select a generation and use it"))
        .subcommand(
            Command::new("use")
                .about("select a generation, use it, and set it as the boot default"),
        )
        .subcommand(
            Command::new("default").about("select a generation and set it as the boot default"),
        )
        .subcommand(
            Command::new("run")
                .about("spinns up a temporary shell with requested applications provided")
                .arg(clap::arg!(...<application> "applications to provide")),
        )
        .subcommand(
            Command::new("pin").about(
                "pins the dependencies of a shell.nix file, preventing them from being GCed",
            ),
        )
        .subcommand(
            Command::new("pins")
                .about("lists all pinned shell.nix files, whose dependencies will not get GCed"),
        )
        .subcommand(Command::new("delete").about("delete generations"))
        .subcommand(Command::new("gc").about("garbage collect"));
    let matches = &cmd.get_matches();

    match matches.subcommand() {
        Some(("list", _)) => {
            let generations = list_generations()?;

            let (header, rows) = format_column(
                &["generation", "current", "created at", "name"],
                generations
                    .iter()
                    .map(|v| {
                        let current = if v.current { "yes" } else { " " };
                        let (date, name) = v
                            .nixos_version
                            .split_once("_")
                            .unwrap_or(("unknown", &v.nixos_version));
                        vec![
                            v.generation.to_string(),
                            current.to_string(),
                            date.to_string(),
                            name.to_string(),
                        ]
                    })
                    .collect(),
            );

            println!("{}\n{}", header, rows.join("\n"));
        }
        Some(("new", _)) => {
            let tmp = "/tmp/nixos-label";
            run_cmd_interactive(&format!("vim {tmp}"))?;
            let now = Utc::now().format("%Y.%m.%d-%H:%M");
            let msg = fs::read_to_string(tmp)?.trim().to_string();
            if msg.is_empty() {
                Err(anyhow!("message is required"))?;
            }
            std::env::set_var("NIXOS_LABEL", format!("{now} {msg}").replace(" ", "_"));
            run_cmd_interactive("sudo -E nixos-rebuild switch --flake path:.#default --impure")?;
            let _ = fs::remove_file(tmp);
        }
        Some(("test", _)) => {
            let generation = select_generation()?.generation;
            Exec::cmd("sudo")
                .args(&[
                    "-E",
                    &format!("/nix/var/nix/profiles/system-{generation}-link/bin/switch-to-configuration"),
                    "test",
                ])
                .success_output()?;
        }
        Some(("use", _)) => {
            let generation = select_generation()?.generation;
            Exec::cmd("sudo")
                .args(&[
                    "-E",
                    &format!("/nix/var/nix/profiles/system-{generation}-link/bin/switch-to-configuration"),
                    "switch",
                ])
                .success_output()?;
        }
        Some(("default", _)) => {
            let generation = select_generation()?.generation;
            Exec::cmd("sudo")
                .args(&[
                    "-E",
                    &format!("/nix/var/nix/profiles/system-{generation}-link/bin/switch-to-configuration"),
                    "boot",
                ])
                .success_output()?;
        }
        Some(("delete", _)) => {
            let generations = select_generations()?;
            Exec::cmd("sudo")
                .args(&["-E", "rm"])
                .args(
                    &generations
                        .into_iter()
                        .map(|generation| {
                            format!(
                                "/nix/var/nix/profiles/system-{}-link",
                                generation.generation
                            )
                        })
                        .collect::<Vec<_>>(),
                )
                .success_output()?;
            Exec::cmd("sudo")
                .args(&["-E", "nix-collect-garbage"])
                .success_output()?;
        }
        Some(("pin", _)) => {
            if Path::new("shell.nix").exists() {
                Exec::cmd("nix-build")
                    .args(&[
                        "shell.nix",
                        "-A",
                        "inputDerivation",
                        "-o",
                        ".nix-shell-inputs",
                    ])
                    .success_output()?;
                return Ok(());
            }
            if Path::new("flake.nix").exists() {
                Exec::cmd("nix")
                    .args(&[
                        "build",
                        "path:.#devShells.x86_64-linux.default.inputDerivation",
                        "-o",
                        ".nix-shell-inputs",
                    ])
                    .success_output()?;
                return Ok(());
            }
            Err(anyhow!(
                "couldn't find 'shell.nix' or 'flake.nix' in current directory"
            ))?;
        }
        Some(("pins", _)) => {
            let mut paths = fs::read_dir("/nix/var/nix/gcroots/auto")
                .unwrap()
                .into_iter()
                .map(|path| path.unwrap().path())
                .filter(|path| path.is_symlink())
                .map(|path| fs::read_link(path).unwrap())
                .filter(|path| path.ends_with(".nix-shell-inputs"))
                .map(|path| path.parent().unwrap().to_path_buf())
                .collect::<Vec<_>>();

            paths.sort();

            for path in paths {
                println!("{}", path.display());
            }
        }
        Some(("run", m)) => {
            let applications = m
                .get_many::<String>("application")
                .unwrap()
                .cloned()
                .collect::<Vec<_>>();

            run_cmd_interactive(&format!(
                "nix-shell --command zsh -p {}",
                applications.join(" ")
            ))?;
        }
        Some(("gc", _)) => {
            Exec::cmd("sudo")
                .args(&["-E", "nix-collect-garbage"])
                .success_output()?;
        }
        _ => unreachable!(),
    };

    Ok(())
}
