use-amdvlk-pro(){
  export AMDGVK_ICD_FILENAMES=/opt/amdgpu-pro/etc/vulkan/icd.d/amd_icd64.json:/opt/amdgpu-pro/etc/vulkan/icd.d/amd_icd32.json
}

use-amdvlk(){
  export VK_ICD_FILENAMES=/opt/amdvlk/etc/vulkan/icd.d/amd_icd64.json:/opt/amdvlk/etc/vulkan/icd.d/amd_icd32.json
}
