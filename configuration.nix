# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# shopt -s histappend
# make this work later
# also ctrl+shift+c doesn't work when no selection, so it's annoying

{ inputs, config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
 #     ./cachix.nix
    ];
    
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  
  #boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  networking.hostName = "desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "socks5://127.0.0.1:10808/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain,192.168.2.0/8";
 
  services.gvfs.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;
  
  #enable v2raya
  #sudo tail -f /var/log/v2raya/v2raya.log
  #sudo nixos-rebuild switch --rollback
  #services.v2raya.enable = true;
  
  #enable xray
  #journalctl -fu xray
  #services.xray.settingsFile = "/etc/nixos/config.json";
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
  fonts.packages = with pkgs; [
    noto-fonts-cjk
    babelstone-han
  ];
  

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
 #     vaapiVdpau
 #     libvdpau-va-gl
       nvidia-vaapi-driver
    ];
  };

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Do not disable this unless your GPU is unsupported or if you have a good reason to.
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  #Disable Wayland
  #services.xserver.displayManager.gdm.wayland = false;

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

  # Enable sound with pulseaudio, comment out to enable pipewire
  #hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;
  
  # Enable sound with pipewire
  services.pipewire = {
#    alsa.enable = true;
#    alsa.support32Bit = true;
#    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  

  hardware.pulseaudio.support32Bit = true;
  hardware.bluetooth.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.iopq = {
    isNormalUser = true;
    description = "Igor";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    packages = with pkgs; [
      firefox
      thunderbird
      git
      gedit
      tdesktop
      steam
      qbittorrent
      #wineWowPackages.stagingFull #(version with experimental features)
      stable.wineWowPackages.staging
      #wineWowPackages.waylandFull
      winetricks
      
      krita
      vlc
      kodi
      mpv
      smplayer
      
      chromium
      #obs-studio
      
      stuntman
      pavucontrol
      
      #bitcoin-abc
      p7zip
      
      #blueman not solving my pairing issue
      #bluez
      wireplumber
      exodus

      dig
      nftables
      samba #ntlm_auth for starcraft
      
      pulseeffects-legacy
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

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
    go
    gcc
    nix-prefetch-github
    pkgs.gnome3.gnome-tweaks
    mission-center
    libva-utils
  ];
  
  #services.dnscrypt-proxy2.enable = false;
  #services.dnscrypt-proxy2.settings = {
  #sources.public-resolvers = {
  #    urls = [ "https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md" ];
  #    cache_file = "public-resolvers.md";
  #    minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
  #    refresh_delay = 72;
  #  };
  #};
  
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
