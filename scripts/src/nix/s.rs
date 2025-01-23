use scripts::*;
use serde::{Deserialize, Serialize};
use std::fs::{self};

fn run_cmd_interactive(cmd: &str) -> Result<()> {
    use subprocess::*;
    let mut args = cmd
        .split_whitespace()
        .map(str::to_string)
        .collect::<Vec<String>>();
    let cmd = args.remove(0);
    let ret = Exec::cmd(&cmd)
        .args(&args)
        .stdout(Redirection::Merge)
        .capture()?;
    if !ret.exit_status.success() {
        let args = args.join(" ");
        Err(anyhow!(
            "process '{cmd} {args}' exited a non-zero exit status"
        ))?;
    };
    Ok(())
}

#[derive(Debug, Serialize, Deserialize)]
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
    let deserialized = serde_json::from_str(&raw).unwrap();
    Ok(deserialized)
}

fn select_generation() -> Result<u32> {
    let ret = Exec::cmd("nixos-rebuild")
        .arg("list-generations")
        .success_output()?
        .stdout_str();

    let (header, ret) = ret.split_once("\n").unwrap_or_else(|| unreachable!());

    let ret = Exec::cmd("fzf")
        .args(&["--header", &header])
        .args(&["--bind", "enter:accept-non-empty"])
        .stdin(ret)
        .success_output()?
        .stdout_str();

    if ret.is_empty() {
        Err(anyhow!("no revision selected"))?;
    }

    let generation = ret.split_once(" ").unwrap().0.parse::<u32>().unwrap();
    Ok(generation)
}

fn select_generations() -> Result<Vec<u32>> {
    let ret = Exec::cmd("nixos-rebuild")
        .arg("list-generations")
        .success_output()?
        .stdout_str();

    let (header, ret) = ret.split_once("\n").unwrap_or_else(|| unreachable!());

    let ret = Exec::cmd("fzf")
        .args(&["-m"])
        .args(&["--header", &header])
        .args(&["--bind", "enter:accept-non-empty"])
        .args(&[
            "--bind",
            "ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all",
        ])
        .stdin(ret)
        .success_output()?
        .stdout_str();

    if ret.is_empty() {
        Err(anyhow!("no revision selected"))?;
    }

    let generations = ret
        .split("\n")
        .filter(|line| !line.is_empty())
        .map(|line| line.split_once(" ").unwrap().0.parse::<u32>().unwrap())
        .collect();

    Ok(generations)
}

fn main() -> Result<()> {
    // Err(anyhow!("no revision selected"))?;

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
        .subcommand(Command::new("delete").about("delete generations"))
        .subcommand(Command::new("gc").about("garbage collect"));
    let matches = &cmd.get_matches();

    match matches.subcommand() {
        Some(("list", _)) => {
            let generations = list_generations().unwrap();

            let w1 = generations
                .iter()
                .map(|g| g.generation.to_string().len())
                .reduce(|l, r| l.max(r))
                .unwrap_or_default()
                .max("generation".len());

            let w2 = "current".len();

            println!("{: <w1$} current name", "generation");
            for generation in generations {
                let current = if generation.current { "*" } else { " " };
                println!(
                    "{: <w1$} {: <w2$} {}",
                    generation.generation, current, generation.nixos_version
                )
            }
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
            let generation = select_generation()?;
            Exec::cmd("sudo")
                .args(&[
                    "-E",
                    &format!("/nix/var/nix/profiles/system-{generation}-link/bin/switch-to-configuration"),
                    "test",
                ])
                .success_output()?;
        }
        Some(("use", _)) => {
            let generation = select_generation()?;
            Exec::cmd("sudo")
                .args(&[
                    "-E",
                    &format!("/nix/var/nix/profiles/system-{generation}-link/bin/switch-to-configuration"),
                    "switch",
                ])
                .success_output()?;
        }
        Some(("default", _)) => {
            let generation = select_generation()?;
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
                            format!("/nix/var/nix/profiles/system-{}-link", generation)
                        })
                        .collect::<Vec<_>>(),
                )
                .success_output()?;
            Exec::cmd("sudo")
                .args(&["-E", "nix-collect-garbage"])
                .success_output()?;
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
