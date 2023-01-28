# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  nix-software-center = (import (pkgs.fetchFromGitHub {
    owner = "vlinkz";
    repo = "nix-software-center";
    rev = "0.1.0";
    sha256 = "d4LAIaiCU91LAXfgPCWOUr2JBkHj6n0JQ25EqRIBtBM=";
  })) { inherit pkgs lib;};
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelParams = [ "mitigations=off" ];

    
  # Suspend-then-hibernate everywhere
  #services.logind = {
  #  lidSwitch = "suspend-then-hibernate";
  #  extraConfig = ''
  #    HandlePowerKey=suspend-then-hibernate
  #    IdleAction=suspend-then-hibernate
  #    IdleActionSec=2m
  #  '';
  #};
  #systemd.sleep.extraConfig = "HibernateDelaySec=20h";

    # Suspend-then-hibernate everywhere
  services.logind = {
    lidSwitch = "suspend";
    extraConfig = ''
      HandlePowerKey=suspend
      IdleAction=suspend
      IdleActionSec=2m
    '';
  };
  
  services.upower.criticalPowerAction = "Hibernate";

  boot.kernel.sysctl = { "vm.swappiness" = 10;};

  # grub because we windows
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;

  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  networking.proxy.default = "socks5://127.0.0.1:10808/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  
  #journalctl -fu xray
  #enable xray
  services.xray.settingsFile = "/etc/nixos/config.json";
  services.xray.enable = true;

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
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    babelstone-han
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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
  
  #vaapi
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

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
      chromium
      vlc
      vscodium
      polkit_gnome
      polkit
      onlyoffice-bin
      #libreoffice
      meld
      kdiff3
      smplayer #fix by using a package with mpv as the default package
      mpv
      audacity
      pijul
      nix-software-center
      etcher
      krusader
      elisa
      psensor
      cpu-x
      cpupower-gui
      busybox
      #qt5ct
      kodi
    ];
  };

  services.cpupower-gui.enable = true;
  systemd.services.cpupower-gui.enable = false; #the root one fails

  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3"
  ];
    
  services.jellyfin.enable = true;

  programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
  programs.kdeconnect.enable = true;
  
  security.polkit.enable = true;
  
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    HISTSIZE = "10000";
    HISTFILESIZE = "10000";
  };

  #programs.bash.promptInit = "shopt -s histappend";

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "iopq";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  wget
  #  appimage-run
    gnome.dconf-editor
    gnomeExtensions.gsconnect
    iwd
    gparted
    qgnomeplatform
    adwaita-qt
    oxygen-icons5 #better icons for krusader
    libsForQt5.kio-extras #krusader image preview
    #tts
  ];

  qt.style = "adwaita-dark"; #dark mode in KDE apps

  #networking.networkmanager.wifi.backend = "iwd";
  #networking.wireless.iwd.enable = true;

  services.flatpak.enable = true;
  
  # Use Chinese mirror 
  #nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

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
