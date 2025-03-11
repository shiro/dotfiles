use crate::*;
pub use subprocess::Exec;

pub trait CaptureExt {
    fn success_output(self) -> Result<subprocess::CaptureData>;
}

impl CaptureExt for subprocess::Exec {
    fn success_output(self) -> Result<subprocess::CaptureData> {
        let ret = self.capture()?;
        if !ret.exit_status.success() {
            Err(anyhow!("process exited a non-zero exit status"))?;
        }
        Ok(ret)
    }
}
impl CaptureExt for subprocess::Pipeline {
    fn success_output(self) -> Result<subprocess::CaptureData> {
        let ret = self.capture()?;
        if !ret.exit_status.success() {
            Err(anyhow!("process exited a non-zero exit status"))?;
        }
        Ok(ret)
    }
}

pub fn run_cmd_interactive(cmd: &str) -> Result<()> {
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
