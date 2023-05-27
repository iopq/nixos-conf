# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
 #     ./cachix.nix
      ./xraya/xraya.nix
    ];
 
  #boot.loader.grub.enable = true;
  #boot.loader.grub.version = 2;
  #boot.loader.grub.device = "nodev";
  #boot.loader.grub.efiSupport = true;
  #boot.loader.grub.useOSProber = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "socks5://127.0.0.1:10808/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain,192.168.2.0/8";
 
  services.gvfs.enable = true;
   
  nix.settings.experimental-features = "nix-command";

  # Enable networking
  networking.networkmanager.enable = true;
  
  #enable xraya
  #sudo tail -f /var/log/v2raya/v2raya.log
  #nixos-rebuild switch --rollback
  services.xraya.enable = true;
  
  #enable xray
  #journalctl -fu xray
  services.xray.settingsFile = "/etc/nixos/config.json";
  #services.xray.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Chinese, Korean text input
  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ 
    libpinyin
    hangul
  ];
  
  #fonts
  fonts.fonts = with pkgs; [
    noto-fonts-cjk
    babelstone-han
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
  programs.kdeconnect.enable = true;

  # Enable KDE
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;
  
  
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  hardware.opengl.enable = true;
  
  #vaapi
  #nixpkgs.config.packageOverrides = pkgs: {
  #  vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  #};
  #hardware.opengl = {
  #  enable = true;
  #  extraPackages = with pkgs; [
  #    intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #    vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #    vaapiVdpau
  #    libvdpau-va-gl
  #  ];
  #};
  
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # fix unsuspend VRAM issues
  hardware.nvidia.powerManagement.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.iopq = {
    isNormalUser = true;
    description = "Igor";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      thunderbird
      haruna
      git
      gnome.gedit
      tdesktop
      steam
      qbittorrent
      piper
      wineWowPackages.stagingFull #(version with experimental features)
      #stable.wineWowPackages.staging

      # winetricks (all versions)
      winetricks
      
      krita
      vlc
      kodi
      mplayer
      smplayer
      
      chromium
      nicotine-plus
    ];
  };
  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  hardware.opengl.driSupport32Bit = true;
  
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        libgdiplus
      ];
    };
  };
  
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };
  
  services.flatpak.enable = true;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "iopq";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  #nixpkgs.config.cudaSupport = true;
  #makes it rebuild

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    inputs.nix-software-center.packages.${system}.nix-software-center
    xray
    tun2socks
  #  dnscrypt-proxy2
    go
    gcc
    nix-prefetch-github
    samba
    pkgs.gnome3.gnome-tweaks
#    python310
#    python310Packages.pip
#    python310Packages.pysocks
#    cachix
    cudatoolkit
    busybox
    gnomeExtensions.gsconnect
  #  tts
    
  ];
  
  #for mouse
  services.ratbagd.enable = true;
  
 # services.dnscrypt-proxy2.enable = false;
 # services.dnscrypt-proxy2.settings = {
 # sources.public-resolvers = {
 #     urls = [ "https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md" ];
 #     cache_file = "public-resolvers.md";
 #     minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
 #     refresh_delay = 72;
 #   };
 # };
  
  # I used these steps
  # sudo ip tuntap add mode tun dev tun0
  # sudo ip addr add 198.18.0.1/15 dev tun0
  # sudo ip link set dev tun0 up
  
  # curl --socks5 socks5://localhost:10808 https://myip.wtf/json
  
  # sudo ip route del default
  # sudo ip route add default via 198.18.0.1 dev tun0 metric 1
  # sudo ip route add default via 192.168.2.9 dev wlp38s0 metric 10

  # sudo ip r a 3.38.51.174 via 192.168.2.9
  # tun2socks -device tun0 -proxy socks5://127.0.0.1:10808 -interface wlp38s0
  
  #https://github.com/repos-holder/nur-packages/blob/81503c5e70952a837c9be8a1412bc64091b50aa1/modules/tun2socks.nix
  
  
  
  # Use Chinese mirror 
  # nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
