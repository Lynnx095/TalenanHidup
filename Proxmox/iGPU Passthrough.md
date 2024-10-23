# VFIO Configuration Tutorial for Proxmox

Follow this step-by-step guide to configure VFIO for GPU passthrough in Proxmox.
You can also follow this [Youtube](https://www.youtube.com/watch?v=UoL8YJAc-vE&ab_channel=HomeTechAutomation) tutorial.

## Step 1: Edit GRUB

1. Open the GRUB configuration file:
   ```bash
   nano /etc/default/grub
   ```

2. Change the following line:
   ```plaintext
   GRUB_CMDLINE_LINUX_DEFAULT="quiet"
   ```
   to:
   ```plaintext
   GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on i915.enable_gvt=1 iommu=pt pcie_acs_override=downstream,multifunction video=efifb:off video=vesa:off vfio_iommu_type1.allow_unsafe_interrupts=1 kvm.ignore_msrs=1 modprobe.blacklist=radeon,nouveau,nvidia,nvidiafb,nvidia-gpu"
   ```

3. Save the file and exit the text editor.

## Step 2: Update GRUB

Execute the following command:
```bash
update-grub
```

## Step 3: Edit the Module Files

1. Open the modules file:
   ```bash
   nano /etc/modules
   ```

2. Add the following lines:
   ```plaintext
   vfio
   vfio_iommu_type1
   vfio_pci
   vfio_virqfd
   kvmgt
   ```

3. Save the file and exit the text editor.

## Step 4: IOMMU Remapping

### a) Edit `iommu_unsafe_interrupts.conf`

1. Open the configuration file:
   ```bash
   nano /etc/modprobe.d/iommu_unsafe_interrupts.conf
   ```

2. Add the following line:
   ```plaintext
   options vfio_iommu_type1 allow_unsafe_interrupts=1
   ```

3. Save the file and exit the text editor.

### b) Edit `kvm.conf`

1. Open the configuration file:
   ```bash
   nano /etc/modprobe.d/kvm.conf
   ```

2. Add the following line:
   ```plaintext
   options kvm ignore_msrs=1
   ```

3. Save the file and exit the text editor.

## Step 5: Blacklist the GPU Drivers

1. Open the blacklist file:
   ```bash
   nano /etc/modprobe.d/blacklist.conf
   ```

2. Add the following lines:
   ```plaintext
   blacklist radeon
   blacklist nouveau
   blacklist nvidia
   blacklist nvidiafb
   ```

3. Save the file and exit the text editor.

## Step 6: Adding GPU to VFIO

### a) Identify Your GPU

1. Execute the command:
   ```bash
   lspci -v
   ```
   Look for your GPU and take note of the first set of numbers.

### b) Get the GPU Vendor Number

1. Execute the command:
   ```bash
   lspci -n -s (PCI card address)
   ```

### c) Edit `vfio.conf`

1. Open the VFIO configuration file:
   ```bash
   nano /etc/modprobe.d/vfio.conf
   ```

2. Add the following line with your GPU and Audio numbers:
   ```plaintext
   options vfio-pci ids=(GPU number,Audio number) disable_vga=1
   ```

3. Save the file and exit the text editor.

## Step 7: Update Everything and Restart

1. Execute the following command to update the initramfs:
   ```bash
   update-initramfs -u
   ```

2. Restart your Proxmox Node:
   ```bash
   reboot
   ```

---

If there's error related to x-gpu, delete x-gpu line one the vm config using this command below
```

nano /etc/pve/qemu-server/<vm-id>.conf
