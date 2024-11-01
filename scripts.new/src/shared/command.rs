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
