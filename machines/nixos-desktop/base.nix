{ config, pkgs, lib, ... }:

let 
  kernelver = "5.12";
in

{
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  ## Tired of this.
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=5s
  '';

  #zramSwap.enable = true;
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 5;
  };

  ### Audit Lines ###
  security.audit.enable = true;

  ### Flicker-Free ###
  boot.kernelParams = [ "pcie_acs_override=multifunction,downstream" "video=DP-2:1920x1080@144"  "video=HDMI-A-1:1600x900" "video=HDMI-A-2:1920x1080@75" "zfs.zfs_arc_max=8589934592" "threadirqs" ];
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];
  boot.initrd.availableKernelModules = [ "amdgpu" ];
  boot.initrd.verbose = false;
  boot.loader.timeout = lib.mkForce 0;
  boot.kernelModules = [ "vfio_pci" "vfio_virqfd" "vfio_iommu_type1" "vfio" "winesync" "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1c82,10de:0fb9
  '';

  systemd.services.libvirtd-import = {
    wants = [ "libvirtd.service" ];
    after = [ "libvirtd.service" ];
    wantedBy = [ "libvirtd.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.libvirt}/bin/virsh define ${../cfg/libvirt/win10.xml}
      '';
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemuVerbatimConfig = ''
      user = "cidkid"
    '';
  };

  boot.kernel.sysctl = {
    "abi.vsyscall32" = 0;
  };

  boot.zfs.enableUnstable = true;
  boot.zfs.extraPools = [ "tank" ];

  # Erase your darlings
  networking.hostId = "423a4c84";
  boot.initrd.postDeviceCommands = lib.mkAfter ''
	  zfs rollback -r nixpool/local/root@blank
  '';

  environment.etc."NetworkManager/system-connections" = {
	  source = "/persist/etc/NetworkManager/system-connections";
  };

  environment.etc."nixos" = {
	  source = "/persist/etc/nixos";
  };

  ## Not really needed, but is a failsafe
  environment.etc."shells".text = lib.mkForce ''
    /run/current-system/sw/bin/bash
    /run/current-system/sw/bin/sh
    /run/current-system/sw/bin/zsh
    ${pkgs.bashInteractive}/bin/bash
    ${pkgs.bashInteractive}/bin/sh
    ${pkgs.zsh}/bin/zsh
    /bin/sh
  '';

  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    "L /var/lib/anbox - - - - /tank/anbox"
  ];

  hardware.opentabletdriver.enable = true;
  systemd.user.services.opentabletdriver.wantedBy = lib.mkForce [ "default.target" ];
  systemd.user.services.opentabletdriver.partOf = lib.mkForce [ "default.target" ];
  systemd.user.services.opentabletdriver.environment = {
    WAYLAND_DISPLAY = "wayland-1";
  };

  # Security limits for low-latency
  security.pam.loginLimits = [
      {
        domain = "@users";
        item = "priority";
        type = "hard";
        value = "-2";
      }
      {
        domain = "@users";
        item = "nice";
        type = "soft";
        value = "-19";
      }
      {
        domain = "@users";
        item = "nice";
        type = "hard";
        value = "-20";
      }
      {
        domain = "@messagebus";
        item = "priority";
        type = "soft";
        value = "-10";
      }
  ];

  services.udev.extraRules = ''
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"
  '';
  
  boot.postBootCommands = ''
    echo 3072 > /sys/class/rtc/rtc0/max_user_freq
    echo 3072 > /proc/sys/dev/hpet/max-user-freq
  '';

  musnix = {
    enable = true;
    alsaSeq.enable = false;

    rtirq = {
      resetAll = 1;
      prioLow = 0;
      enable = true;
      nameList = "rtc0 xhci_hcd snd";
    };
  };

  # Networking stuff
  networking.hostName = "jupiter";
  time.timeZone = "America/Chicago";
  networking.networkmanager.enable = true;
  
  ### Network Manager is fucking braindamaged ###
  environment.etc."resolv.conf".text = ''
    nameserver 1.1.1.1
    nameserver 1.0.0.1
  '';
  
  # Kernel Stuffs don't touch
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
    zfsSupport = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" "xfs" "zfs" ];
  boot.kernelPackages = pkgs.linux-cidkid;
  boot.kernelPatches = [
    {
      name = "acso";
      patch = builtins.fetchurl {
        url = "https://github.com/Frogging-Family/linux-tkg/raw/master/linux-tkg-patches/${kernelver}/0006-add-acs-overrides_iommu.patch";
        sha256 = "sha256:0al3fbswqlmsyr13mxwbaaa9h5smqwa34hrl5d2n75lzsg01wrhr";
      };
    }
    {
      name = "fsync";
      patch = builtins.fetchurl {
        url = "https://github.com/Frogging-Family/linux-tkg/raw/master/linux-tkg-patches/${kernelver}/0007-v${kernelver}-fsync.patch";
        sha256 = "sha256:0mplwdglw58bmkkxix4ccwgax3r02gahax9042dx33mybdnbl0mk";
      };
    }
    {
      name = "futex2";
      patch = builtins.fetchurl {
        url = "https://github.com/Frogging-Family/linux-tkg/raw/master/linux-tkg-patches/${kernelver}/0007-v${kernelver}-futex2_interface.patch";
        sha256 = "sha256:1j29zyx2s85scfhbprgb9cs11rp50glbzczl4plphli8wds342pw";
      };
    }
    {
      name = "winesync";
      patch = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/Frogging-Family/linux-tkg/8c2ba7508792fe1644948f31ddaab683643950fe/linux-tkg-patches/5.12/0007-v5.12-winesync.patch";
        sha256 = "sha256:1q82439450bldni0lra9hmhvdxnjxxhlv8v95kd36wah7fki4k83";
      };
    }
    {
      name = "clear-patches";
      patch = builtins.fetchurl {
        url = "https://github.com/Frogging-Family/linux-tkg/raw/master/linux-tkg-patches/${kernelver}/0002-clear-patches.patch";
        sha256 = "sha256:1h1gx6rq2c961d36z1szqv9xpq1xgz2bhqjsyb03jjdrdzlcv9rm";
      };
    }
    {
      name = "pjrc-v1";
      patch = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/Frogging-Family/linux-tkg/2da317c20ed6f70085b195639b9aad2cacf31ab5/linux-tkg-patches/5.12/0009-prjc_v5.12-r1.patch";
        sha256 = "sha256:1z731jiwyc7z4d5hzd6szrxnvw0iygbqx82y2anzm32n22731dqv";
      };
      extraConfig = ''
        SCHED_ALT y
        SCHED_PDS y
        SCHED_BMQ n
        SCHED_AUTOGROUP y
      '';
    }
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  hardware.cpu.amd.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "performance";

  # Always want to make TmpFS in ram
  boot.tmpOnTmpfs = true;
  
  # We don't use sudo past base installation
  security.sudo.enable = false;
  security.doas.enable = true;
  security.doas.extraRules = [ {
    groups = [ "wheel" ];
    persist = true;
  }];
}
