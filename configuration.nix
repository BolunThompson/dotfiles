# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, agenix, inputs, admin-scripts, ip, ... }: {
  nix.settings.experimental-features = [ "nix-command flakes" ];

  imports =
    [
      # Include the results of the hardware scan.
      ./laptop-hw.nix
    ];

  nixpkgs.config.allowUnfree = true;

  powerManagement.enable = false;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.runAsRoot = true;
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
    };
    docker = {
      enable = true;
    };
  };

  boot = {
    plymouth.enable = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    initrd.systemd.enable = true;
    kernelParams = [ "quiet" ];
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    interfaces.wlo1.wakeOnLan.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        2022
        80
        443
        42000
        6881
        9381
        8888
        1965
      ];
      allowedTCPPortRanges = [
        { from = 60000; to = 61000; }
      ];
      allowedUDPPorts = [ 42000 22 21116 ];
    };
  };

  time.timeZone = "America/Los_Angeles";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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

  };

  hardware = {
    graphics = {
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

  systemd = {
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    services.nginx.serviceConfig.ReadWritePaths = [
      "/var/spool/nginx/logs/"
    ];

    services.NetworkManager-wait-online.enable = true;

    extraConfig = "DefaultLimitNOFILE=104857";

  };


  programs = {
    git.enable = true;
    ssh.startAgent = true;
    light.enable = true;
    dconf.enable = true;
    mosh.enable = true;
    fish.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
  security.rtkit.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*"; # old behavior, if there's an issue with portals it could likely be this
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "me@bolun.dev";
  };
  services = {
    nginx = {
      enable = true;

      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;

      virtualHosts."personal.bolun.dev" = {
        forceSSL = false;
        enableACME = true;
        root = "/var/personal/bolun.dev/";
        locations."/jupyter" = {
          proxyPass = "http://127.0.0.1:8888";
          proxyWebsockets = true; # needed if you need to use WebSocket
        };
      };
    };
    openssh = {
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
    xserver = {
      enable = true;
      displayManager.gdm.enable = false;
      displayManager.startx.enable = true;
      desktopManager.gnome.enable = true;
    };
    fail2ban = {
      enable = true;
      maxretry = 10;
      ignoreIP = [ ];
    };
    openvpn = {
      servers = {
        #     pureVpn =
        #       { config = ''config ./usla2.ovpn''; };
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


  users.defaultUserShell = pkgs.bash;
  users.users.bolun = {
    isNormalUser = true;
    description = "Bolun Thompson";
    extraGroups = [ "docker" "networkmanager" "wheel" "video" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCp0dN+tnFtT8PHgQbfe3wvsI12rwjB4HsbqYS9Z2rLLtyeMJPsemnQFuwS14qt6L82l3nF9jk8lyZrNM5jlvbUy2/0pWITkWI3h3rZfkeW3pZIDfbDEkF8Erk2Gpf319jpMWHmV4N0BFY4SywmupKAF8IxZasrEqsCQGqRAqwHgDgjKmoSenh1oGsQRDBLuH3B6X9f4QeB1ws6ZR6SgiX4MiDzBNEaqwsQvmi8fjcoQcm+Ha5SGwj72CS7Rt4fCRlOyMD/6c1fHO12ockR8OTtwD+Cc3K09HIrT1Ej8HG1jmoiqGJVOZlU+pANnYG/kWSvDDIjUDdhM/yNVu6IgMGQNAQLEZ5+4fDlGyAI7jUH/AiV5LtQOkBWVMpoGD06HMXGgB0l//4Yo7LzzgDKAWNkC7qcw9PsHp3VFF7JJFvCYXJxQEJ1XYLHfY7kCVkBjqbl9ppZ/tqhy53kPXy1tWbdT3s+dGxbtkkOe67A6RT7+OJ5fCEyi7zdQBRwZEkGk12lAQLupZPxnwTUaSp6Lmvf9w/sCAlKS6S9JIbX5pg//+rmd340AAdJDkpnagANiktiZATrwuh9F6R/o90ZXQUcvOQsZ4I2RKjW5/5BPA1x1wVjCiXSxsH0XCWt91gylZtM6TJdvLjfs8O6gruBspUqwX1F/GJ7HJAy3I8Gy415Xw== ShellFish@iPad-17062024"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKEukozAVTOz81c7UghrCNmXP2v8dlkngCvciz6wVtQlhzAUqI0dQnpQUXghMDRu+ZWJz1xjJ4hVmB4z81Q9MvFkIIFqigbvt2+z157CoBlohV0cI/uYOi1UxPNatn/m7j2pee+NfJ9FlbokUhSZTg3H1P4Fs7TSBDD7XmQxRzy4VYHIVqU3CEmhJ/ypqm8LRK9BH5QK0b2xFijFVNy9tZFuFGTRKw0XiZpn5F4ggGepAho24yTNnzXMLRb14CdNteKzTGYYBMc1H9cPCoXZpT9Q2sOWucJBJbd9vnNiyuFVB4xcHBmgGU2XmLq8ckWrVrvuPHWoY4oxJLxCZf19CZ mobile@localhost"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxq8cbtLR8fV3F5gepSwdjOtZt98UNCVnzqTDYNgbb73yHde+LxPHYLy/OyBH6uxpgmIxPdSNTl8VTQ6R9tvcz9ir/ul3AsmDZj8qCDrKPpRpVJv9YzCZ1gbIVON98Y7e+KgSfnGaehOQtyjUAXczE97tjKJr9Mxy/1lNwLi0uzx5oWmDJXE+5Zp30nOxKXn0sKxzSF4Pxk5cmKEn05uZY4UMIHPZw6OLvBtjgRAtbzTbWs7dIUEpA8OJaUJpCVfwEtEVUSrXha+WYDf6y8UlmcJ66YfO1yfo5ctpz+5Jd8jQ4QaVelZfvx16HreEfKI73j5HTZTT4CrruI7hU5F5m3lwZ4PoOqpSEGSaqOPh5cqTc99rbPF8/fIyMUgfAbNoR+xVvUbxK9joCaV5aSX9NPpoYy0XPYZtK4tYS75xUYnRHzHnY1XNpSKmnuuDcfRBNCa7mRMwFcK2uq+m2S6UvboqYgsPcxYCr1ZtF/rbe+COSdxRiVPHBBtXkNSyKleE= bolun thompson@BolunLaptop"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOVtMxV5syQV7npVl4VibfxXKuG9L7doMT/bWz6LFwFtCV3PH/3hnInz23SsQBuxu7vSp9p6kyDcTGQxkRINOPY= bolun@iphone"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMkEtidwkP3fSOWjeVeY4kC2AqJDZuh3I0UNOeoHuWYL me@bolun.dev"
    ];
  };

  environment = {
    shells = [ pkgs.fish pkgs.bash ];
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
