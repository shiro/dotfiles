#!/bin/zsh

sudo qemu-system-x86_64 \
--enable-kvm -m 6144 \
-drive file=/usr/share/ovmf/x64/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on \
-drive file=$HOME/.config/qemu-windows/qemu-windows.nvram,if=pflash,format=raw,unit=1 \
-drive file=/dev/disk/by-id/ata-ST1000LM035-1RK172_WDEWXNX5,index=0,media=disk,driver=raw,if=virtio,cache=none \
-drive file=/dev/disk/by-id/ata-SanDisk_SD9SN8W256G1002_184243802494,index=1,media=disk,driver=raw,if=virtio,cache=none \
-device virtio-tablet \
-display spice-app \
-vga virtio \
-net user,hostfwd=tcp::22222-:22,smb=/mnt/vm/win10 \
-net nic,model=virtio \
-device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent \
-smp cores=4,threads=1,sockets=1


# -display gtk,gl=on,zoom-to-fit=on \
# -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
# -cpu host
# -net user,hostfwd=tcp::20022-:22 \
#--enable-kvm -m 8138 6144 4096 \




# sudo qemu-system-x86_64 \
# --enable-kvm -m 6144 \
# -drive file=/usr/share/ovmf/x64/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on \
# -drive file=$HOME/.config/qemu-windows/qemu-windows.nvram,if=pflash,format=raw,unit=1 \
# -drive file=/dev/sdb,index=0,media=disk,driver=raw,if=virtio,cache=none \
# -drive file=/dev/sda,index=1,media=disk,driver=raw,if=virtio,cache=none \
# -device virtio-tablet \
# -display spice-app \
# -vga virtio \
# -net user,hostfwd=tcp::22222-:22,smb=/mnt/vm/win10 \
# -net nic,model=virtio \
# -device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent \
# -smp cores=4,threads=1,sockets=1

