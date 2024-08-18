
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, agenix, inputs, ip, ... }: {
  nix.settings.experimental-features = [ "nix-command flakes" ];

  imports =
    [
      # Include the results of the hardware scan.
      ./laptop-hw.nix
    ];

  systemd.services.NetworkManager-wait-online.enable = true;
  systemd.extraConfig = "DefaultLimitNOFILE=104857";
  powerManagement.enable = false;


  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = true;
    qemu.vhostUserPackages = [ pkgs.virtiofsd ];
  };
  virtualisation.docker = {
    enable = true;
  };

  # Bootloader.
  boot.plymouth.enable = true;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "quiet" ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.interfaces.wlo1.wakeOnLan.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 2022 80 443 42000 6881 9381 8888 
  # Rust desk
  8000 21115 21116 21117 21118 21119
  ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 60000; to = 61000; }
  ];
  networking.firewall.allowedUDPPorts = [ 42000 22 21116];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  hardware = {
  opengl = {
    enable = true;
    extraPackages =
      with pkgs; [
        intel-media-driver
        vaapiVdpau
        libvdpau-va-gl
      ];
  };
  pulseaudio.enable = false;
  };
  

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  systemd.tmpfiles.rules = [
  "d /opt/rustdesk 0700 root root"
  "d /var/log/rustdesk 0700 root root"
];

systemd.services.light = {
  script = "light -S 1";
  serviceConfig = {
    Type = "oneshot";
    User = "root";
  };
};
systemd.timers.light = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; 
    };
};

systemd.services.rustdesksignal = {
  description = "Rustdesk Signal Server (hbbs)";
  documentation = [ 
    "https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/install/"
    "https://github.com/techahold/rustdeskinstall/blob/master/install.sh"
  ];
  after = [ "network-pre.target" ];
  wants = [ "network-pre.target" ];
  partOf = [ "rustdeskrelay.service" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "simple";
    LimitNOFILE=1000000;
    WorkingDirectory="/opt/rustdesk";
    StandardOutput="append:/var/log/rustdesk/hbbs.log";
    StandardError="append:/var/log/rustdesk/hbbs.error";
    ExecStart="${pkgs.rustdesk-server}/bin/hbbs -r 192.168.0.167";
    Restart="always";
    RestartSec=10;
  };
};

systemd.services.rustdeskrelay = {
  description = "Rustdesk Relay Server (hbbr)";
  documentation = [ 
    "https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/install/"
    "https://github.com/techahold/rustdeskinstall/blob/master/install.sh"
  ];
  after = [ "network-pre.target" ];
  wants = [ "network-pre.target" ];
  partOf = [ "rustdesksignal.service" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "simple";
    LimitNOFILE=1000000;
    WorkingDirectory="/opt/rustdesk";
    StandardOutput="append:/var/log/rustdesk/hbbr.log";
    StandardError="append:/var/log/rustdesk/hbbr.error";
    ExecStart="${pkgs.rustdesk-server}/bin/hbbr";
    Restart="always";
    RestartSec=10;
  };
};

  programs = {
    tmux = {
    enable = true;
    keyMode = "vi";
    shortcut = "s";
    extraConfig = "
    set-option -g mouse on
    setw -g alternate-screen on
    set -g default-terminal 'tmux-256color'

    set -g set-clipboard on
    # allow other apps to passthrough sequences (including OSC52)
    set -g allow-passthrough on
    set -ag terminal-overrides \"vte*:XT:Ms=\\\\E]52;c;%p2%s\\\\7,xterm*:XT:Ms=\\\\E]52;c;%p2%s\\\\7\"
#    bind -Tcopy-mode WheelUpPane   select-pane \\; send-keys -X -N 5 scroll-down
#    bind -Tcopy-mode WheelDownPane select-pane \\; send-keys -X -N 5 scroll-up
#    bind -Tcopy-mode-vi WheelUpPane   select-pane \\; send-keys -X -N 5 scroll-down
#    bind -Tcopy-mode-vi WheelDownPane select-pane \\; send-keys -X -N 5 scroll-up
#    bind -Troot WheelDownPane if-shell -F '#{||:#{pane_in_mode},#{mouse_any_flag}}' { send-keys -M } { copy-mode -e }
    ";
};
   ssh.startAgent = true;
light.enable = true;
    dconf.enable = true;
    mosh.enable = true;
    # should I move this to home.nix?
    fish = {
	enable = true;
    shellInit = "
    command -v 'direnv' && direnv hook fish | source
    command -v 'thefuck' && thefuck --alias | source
    export PATH=\"\$PATH:\$HOME/.local/bin:\$HOME/scripts\"
    ";
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };
  security.rtkit.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*"; # old behavior, if there's an issue with portals it could likely be this
  };
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = false;
      displayManager.startx.enable = true;
      desktopManager.gnome.enable = true;
    };
    eternal-terminal.enable = true;
    fail2ban = {
      enable = true;
      maxretry = 10;
      # ignoreIP = [
      #   "76.88.2.159"
      #   "192.168.0.0/24"
      # ];
    };
    openvpn = {
      servers = {
        pureVpn =
          { config = ''config ./usla2.ovpn''; };
      };
    };
    tlp = {
      enable = false;
      settings = {
        STOP_CHARGE_THRESH_BAT0 = 80;
        START_CHARGE_THRESH_BAT0 = 50;
      };
    };
    pipewire = {
      enable = true; # Only for desktop
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
    };
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    flatpak = {
      enable = true;
    };
    greetd = {
      enable = true;
      settings = {
        default_session = {
          # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd fish";
          command = "${pkgs.greetd.greetd}/bin/agreety --cmd fish";
          user = "bolun";
        };
        initial_session = {
          command = "bash";
          user = "bolun";
        };
      };
    };
    printing = {
      enable = true;
      drivers = [ pkgs.canon-cups-ufr2 ];
    };
    avahi = {
	enable = true;
	    nssmdns4 = true;
	    openFirewall = true;
    };
    # for a WiFi printer
    logind = {
      extraConfig = ''
        IdleAction=ignore
        IdleActionSec=500
      '';
    };
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.fish;
  users.users.bolun = {
    isNormalUser = true;
    description = "Bolun Thompson";
    extraGroups = [ "docker" "networkmanager" "wheel" "video" "libvirtd" ];
    packages = with pkgs; [
      inputs.agenix.packages.${system}.default
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCp0dN+tnFtT8PHgQbfe3wvsI12rwjB4HsbqYS9Z2rLLtyeMJPsemnQFuwS14qt6L82l3nF9jk8lyZrNM5jlvbUy2/0pWITkWI3h3rZfkeW3pZIDfbDEkF8Erk2Gpf319jpMWHmV4N0BFY4SywmupKAF8IxZasrEqsCQGqRAqwHgDgjKmoSenh1oGsQRDBLuH3B6X9f4QeB1ws6ZR6SgiX4MiDzBNEaqwsQvmi8fjcoQcm+Ha5SGwj72CS7Rt4fCRlOyMD/6c1fHO12ockR8OTtwD+Cc3K09HIrT1Ej8HG1jmoiqGJVOZlU+pANnYG/kWSvDDIjUDdhM/yNVu6IgMGQNAQLEZ5+4fDlGyAI7jUH/AiV5LtQOkBWVMpoGD06HMXGgB0l//4Yo7LzzgDKAWNkC7qcw9PsHp3VFF7JJFvCYXJxQEJ1XYLHfY7kCVkBjqbl9ppZ/tqhy53kPXy1tWbdT3s+dGxbtkkOe67A6RT7+OJ5fCEyi7zdQBRwZEkGk12lAQLupZPxnwTUaSp6Lmvf9w/sCAlKS6S9JIbX5pg//+rmd340AAdJDkpnagANiktiZATrwuh9F6R/o90ZXQUcvOQsZ4I2RKjW5/5BPA1x1wVjCiXSxsH0XCWt91gylZtM6TJdvLjfs8O6gruBspUqwX1F/GJ7HJAy3I8Gy415Xw== ShellFish@iPad-17062024" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKEukozAVTOz81c7UghrCNmXP2v8dlkngCvciz6wVtQlhzAUqI0dQnpQUXghMDRu+ZWJz1xjJ4hVmB4z81Q9MvFkIIFqigbvt2+z157CoBlohV0cI/uYOi1UxPNatn/m7j2pee+NfJ9FlbokUhSZTg3H1P4Fs7TSBDD7XmQxRzy4VYHIVqU3CEmhJ/ypqm8LRK9BH5QK0b2xFijFVNy9tZFuFGTRKw0XiZpn5F4ggGepAho24yTNnzXMLRb14CdNteKzTGYYBMc1H9cPCoXZpT9Q2sOWucJBJbd9vnNiyuFVB4xcHBmgGU2XmLq8ckWrVrvuPHWoY4oxJLxCZf19CZ mobile@localhost"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxq8cbtLR8fV3F5gepSwdjOtZt98UNCVnzqTDYNgbb73yHde+LxPHYLy/OyBH6uxpgmIxPdSNTl8VTQ6R9tvcz9ir/ul3AsmDZj8qCDrKPpRpVJv9YzCZ1gbIVON98Y7e+KgSfnGaehOQtyjUAXczE97tjKJr9Mxy/1lNwLi0uzx5oWmDJXE+5Zp30nOxKXn0sKxzSF4Pxk5cmKEn05uZY4UMIHPZw6OLvBtjgRAtbzTbWs7dIUEpA8OJaUJpCVfwEtEVUSrXha+WYDf6y8UlmcJ66YfO1yfo5ctpz+5Jd8jQ4QaVelZfvx16HreEfKI73j5HTZTT4CrruI7hU5F5m3lwZ4PoOqpSEGSaqOPh5cqTc99rbPF8/fIyMUgfAbNoR+xVvUbxK9joCaV5aSX9NPpoYy0XPYZtK4tYS75xUYnRHzHnY1XNpSKmnuuDcfRBNCa7mRMwFcK2uq+m2S6UvboqYgsPcxYCr1ZtF/rbe+COSdxRiVPHBBtXkNSyKleE= bolun thompson@BolunLaptop"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOVtMxV5syQV7npVl4VibfxXKuG9L7doMT/bWz6LFwFtCV3PH/3hnInz23SsQBuxu7vSp9p6kyDcTGQxkRINOPY= bolun@iphone"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMkEtidwkP3fSOWjeVeY4kC2AqJDZuh3I0UNOeoHuWYL me@bolun.dev"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    shells = [ pkgs.fish ];
shellAliases = {
	",h" = "sudoedit /etc/nixos/home.nix";
	",c" = "sudoedit /etc/nixos/configuration.nix";
	",fl" = "sudoedit /etc/nixos/flake.nix";
	",r" = "sudo nixos-rebuild switch";
  ",f" = "$VISUAL flake.nix";
  ",d" = "nix develop";
  ",bat" = "cat /sys/class/power_supply/BAT1/capacity";
  "poweroff" = "test  -n $SSH_CLIENT; and echo 'Do you really want to do that?'; or sudo systemctl poweroff";
  ",img" = "imgcat --depth=iterm2"; # only for iterm2 compatible shells
  ",copy_pass" = "bw get password SSH | osc-copy";
#    "exit" = "test -n $SSH_CLIENT && test -n $TMUX; and tmux detatch -P; or builtin exit";
};
    systemPackages =
      let
        qemu_uefi = pkgs.writeScriptBin "qemu-system-x86_64-uefi"
          ''qemu-system-x86_64 -bios ${pkgs.OVMF.fd}/FV/OVMF.fd "$@"'';
      in
      with pkgs; [
        netcat-gnu
        nmap
        htop
        w3m
        sshpass
        bottom
        inetutils
        viu
        imgcat
        nixpkgs-fmt
        trash-cli
        jq
        unzip
        ripgrep
        sd
        gcc
        gnumake
        rustdesk
        rustdesk-server
        qemu
        OVMF
        greetd.greetd
        greetd.tuigreet
        qemu_uefi
        zip
        file
        python3
        fd
        links2
        unrar
        tldr
        git
        bat
        p7zip
      ];
    variables = {
      EDITOR = "hx";
      VISUAL = "hx";
      SHELL = "fish";
      QT_IM_MODULE = "fcitx";
      GTK_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      # Attempt to fix printer; cups errors from not being able to access /usr/share/cnpkbidir
      # TODO: Fix after college apps
      #LD_PRELOAD = "${pkgs.libredirect.outPath}/lib/libredirect.so"; # TODO: Does doing this globally have performance implications? *dark magic continues*. Crashes firefox at least.
      #NIX_REDIRECTS = "/usr/share/cnpkbidir/=${pkgs.canon-cups-ufr2.outPath}/share/cnpkbidir/";
      QT_QPA_PLATFORM = "wayland";
      GLFW_IM_MODULE = "fcitx";
      INPUT_METHOD = "fcitx";
      IMSETTINGS_MODULE = "fcitx";
      SDL_IM_MODULE = "fcitx";
    };
    sessionVariables = {
      BROWSER = "firefox";
      TERMINAL = "kitty";
      NIXOS_OZONE_WL = "1";
    };
  };
  #programs.kitty = {
  #    enable = true;
  #    font = with pkgs; [(nerdfonts.override { fonts = ["FireCode"]; })];
  #};
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
    ];
    # I have to control in the extraConfig, not with nix settings
    # since for some reason the Match passwordAuthentication
    # doesn't actulaly let me authenticate locally using settings
    extraConfig = "
      PasswordAuthentication no
      PubkeyAuthentication yes
      Match address ${ip.public-ip}
        PasswordAuthentication yes
        ChallengeResponseAuthentication yes
    ";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];nts

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];


}
