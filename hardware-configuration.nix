# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "rtsx_usb_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/01d67437-1a65-44b6-b1e5-d3748ea6251b";
      fsType = "ext4";
    };

  fileSystems."/nix/store" =
    { device = "/nix/store";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/mnt/media/Acer" =
    { device = "/dev/sda4";
      fsType = "ntfs";
      options = [ "rw" "uid=1000" "gid=100" "dmask=000" "fmask=000" ];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/4827-4C9C";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/sda7"; }
    ];
  
  # Set up deep sleep + hibernation
  # Partition swapfile is on (after LUKS decryption)
  boot.resumeDevice = "/dev/sda7";
  # Resume Offset is offset of swapfile
  # https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation_into_swap_file
  #boot.kernelParams = [ "mem_sleep_default=deep" "resume_offset=12130304" ];
  boot.kernelParams = [ "mem_sleep_default=deep" ];



  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

