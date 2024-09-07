{ config, nix, pkgs, lib, specialArgs, options, modulesPath, nixosConfig, osConfig, admin-scripts }:
rec {
  nixpkgs.config.allowUnfreePredicate = _: true;
  nix.registry = {
    template.from = {
      id = "template";
      type = "indirect";
    };
    template.to = {
      type = "path";
      path = "${home.homeDirectory}/templates/";
    };
  };
  home = {
    username = "bolun";
    homeDirectory = "/home/${home.username}";
    sessionPath = [ "${home.homeDirectory}/.local/bin" ];
    sessionVariables = {
      XDG_RUNTIME_DIR = "/run/user/1000/";
      NIXOS_OZONE_WL = "1";
    };

    file =
      let
        wall2 = ./assets/miku_wallpaper_1.jpg;
      in
      {
        ".config/hypr/hyprpaper.conf".text = ''
          ipc = off
          preload = ${wall2}
          wallpaper = DP-2,${wall2}
        '';

        ".xinitrc".source = ./.xinitrc;
        ".config/ranger/rc.conf".source = ./rc.conf;
        ".config/ranger/rifle.conf".source = ./rifle.conf;
        ".jupyter/jupyter_lab_config.py".source = ./jupyter_lab_config.py;
        ".config/glow/glow.yml".source = ./glow.yml;
        "config".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/";
      };

    packages =
      let
        qemu_uefi = pkgs.writeScriptBin "qemu-system-x86_64-uefi"
          ''qemu-system-x86_64 -bios ${pkgs.OVMF.fd}/FV/OVMF.fd "$@"'';
      in

      with pkgs; [
        # configuration
        w3m
        admin-scripts.packages."${pkgs.system}".default
        netcat-gnu
        nmap
        htop
        nix-index
        w3m
        bottom
        inetutils
        imgcat
        nixpkgs-fmt
        trash-cli
        jq
        unzip
        ripgrep
        sd
        qemu
        OVMF
        greetd.greetd
        greetd.tuigreet
        qemu_uefi
        zip
        file
        python3
        fd
        unrar
        tldr
        bat
        p7zip
        delta

        gdrive
        pipewire
        virt-manager
        bitwarden-cli
        discord
        oscclip
        direnv
        glow
        thefuck
        qbittorrent
        tor-browser-bundle-bin
        obsidian
        poppler_utils
        unoconv
        img2pdf
        gparted
        tagtime
        google-chrome
        alsa-utils
        pavucontrol
        pdftk
        warpinator
        progress
        ranger
        libcaca
        hyprpaper
        wl-clipboard
        libreoffice-fresh
        texlive.combined.scheme-small
        lutris
        cabextract
        anki

        # jc games
        bubblewrap
        fuse-overlayfs
        dwarfs

        # Programming helpers
        license-cli
        git-ignore
        gh
        glab

        # added by add_pkg
        ed
        yt-dlp
        wcurl
        unixtools.xxd
        # END PACKAGES
      ];

    shellAliases = {
      ",h" = "sudoedit /etc/nixos/home.nix";
      ",c" = "sudoedit /etc/nixos/configuration.nix";
      ",f" = "sudoedit /etc/nixos/flake.nix";
      ",r" = "sudo nixos-rebuild switch";
      # ",f" = "$VISUAL flake.nix";
      ",d" = "nix develop";
      ",bat" = "cat /sys/class/power_supply/BAT1/capacity";
      "poweroff" = "ssh_poweroff";
      ",img" = "imgcat --depth=iterm2"; # only for iterm2 compatible shells
      # TODO: Would be much less needed if ssh agent was properly working
      ",cpp" = "passphrase | osc-copy";
    };
  };

  # TODO: Setup Hyprland RDP for GUI
  accounts.email.accounts.porkbun = {
    address = "me@bolun.dev";
    realName = "Bolun Thompson";
    userName = "me@bolun.dev";
    primary = true;
    aerc = {
      enable = true;
    };
    passwordCommand = "${pkgs.coreutils}/bin/cat '${config.age.secrets.porkbun2.path}'";
    imap = {
      host = "imap.porkbun.com";
      port = 993;
    };
  };

  age = {
    secrets = {
      porkbun2 = {
        file = "${home.homeDirectory}/.agenix/porkbun.age";
        path = "${config.home.sessionVariables.XDG_RUNTIME_DIR}/agenix/porkbun";

        symlink = false;
      };
    };
    identityPaths = [ "${home.homeDirectory}/.ssh/id_ed25519" ];
    secretsDir = "${config.home.sessionVariables.XDG_RUNTIME_DIR}/agenix/";
  };

  fonts.fontconfig.enable = true;

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        noannoyance-fork.extensionUuid
        no-overview.extensionUuid
      ];
    };
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs;
      [
        fcitx5-rime
      ];
  };

  wayland.windowManager.hyprland = {
    # TODO: Set cursor size to be right on 4K monitors
    extraConfig = builtins.readFile ./hyprland.conf;
    enable = false;
  };

  services = {
    udiskie.enable = true;
    wlsunset = {
      enable = false;
      longitude = "-117.07";
      latitude = "33.01";
      temperature.night = 3000;
    };
    playerctld.enable = true;
  };

  # At some point I could refactor these into tradtional systemd service files
  systemd.user = {
    services.light.Service = {
      ExecStart = "${pkgs.light}/bin/light -S 1";
      Type = "oneshot";
    };
    timers.light.Timer = {
      WantedBy = [ "timers.target" ];
      OnCalendar = "daily";
      Persistent = true;
    };

    services.mv_from_home.Service = {
      ExecStart = "${admin-scripts.packages.${pkgs.system}.default.outPath}/bin/mv_from_home";
      Type = "oneshot";
    };
    timers.mv_from_home.Timer = {
      WantedBy = [ "timers.target" ];
      OnCalendar = "daily";
    };
  };


  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      extraConfig = builtins.fromTOML (builtins.readFile ./gitconfig);
    };
    fish = {
      enable = true;
      shellInit = builtins.readFile ./config.fish;
      plugins = with pkgs.fishPlugins; [
        # could factor the boilerplate into a nix function
        {
          name = "z";
          src = z.src;
        }
        {
          name = "sponge";
          src = sponge.src;
        }
        {
          name = "plugin-git";
          src = plugin-git.src;
        }
      ];
    };
    emacs = {
      enable = true;
      package = pkgs.emacs;

    };
    helix = {
      enable = true;
      defaultEditor = true;
      settings = builtins.fromTOML (builtins.readFile ./helix_settings.toml);
      languages = builtins.fromTOML (builtins.readFile ./helix_languages.toml);
    };
    keychain = {
      enable = true;
      enableFishIntegration = true;
      # due to lack of fish being enabled this wsn't working earlier, so i can fix this sometime. These keys are still wrong tho.
      # keys = [
      # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCp0dN+tnFtT8PHgQbfe3wvsI12rwjB4HsbqYS9Z2rLLtyeMJPsemnQFuwS14qt6L82l3nF9jk8lyZrNM5jlvbUy2/0pWITkWI3h3rZfkeW3pZIDfbDEkF8Erk2Gpf319jpMWHmV4N0BFY4SywmupKAF8IxZasrEqsCQGqRAqwHgDgjKmoSenh1oGsQRDBLuH3B6X9f4QeB1ws6ZR6SgiX4MiDzBNEaqwsQvmi8fjcoQcm+Ha5SGwj72CS7Rt4fCRlOyMD/6c1fHO12ockR8OTtwD+Cc3K09HIrT1Ej8HG1jmoiqGJVOZlU+pANnYG/kWSvDDIjUDdhM/yNVu6IgMGQNAQLEZ5+4fDlGyAI7jUH/AiV5LtQOkBWVMpoGD06HMXGgB0l//4Yo7LzzgDKAWNkC7qcw9PsHp3VFF7JJFvCYXJxQEJ1XYLHfY7kCVkBjqbl9ppZ/tqhy53kPXy1tWbdT3s+dGxbtkkOe67A6RT7+OJ5fCEyi7zdQBRwZEkGk12lAQLupZPxnwTUaSp6Lmvf9w/sCAlKS6S9JIbX5pg//+rmd340AAdJDkpnagANiktiZATrwuh9F6R/o90ZXQUcvOQsZ4I2RKjW5/5BPA1x1wVjCiXSxsH0XCWt91gylZtM6TJdvLjfs8O6gruBspUqwX1F/GJ7HJAy3I8Gy415Xw== ShellFish@iPad-1706202"
      # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxq8cbtLR8fV3F5gepSwdjOtZt98UNCVnzqTDYNgbb73yHde+LxPHYLy/OyBH6uxpgmIxPdSNTl8VTQ6R9tvcz9ir/ul3AsmDZj8qCDrKPpRpVJv9YzCZ1gbIVON98Y7e+KgSfnGaehOQtyjUAXczE97tjKJr9Mxy/1lNwLi0uzx5oWmDJXE+5Zp30nOxKXn0sKxzSF4Pxk5cmKEn05uZY4UMIHPZw6OLvBtjgRAtbzTbWs7dIUEpA8OJaUJpCVfwEtEVUSrXha+WYDf6y8UlmcJ66YfO1yfo5ctpz+5Jd8jQ4QaVelZfvx16HreEfKI73j5HTZTT4CrruI7hU5F5m3lwZ4PoOqpSEGSaqOPh5cqTc99rbPF8/fIyMUgfAbNoR+xVvUbxK9joCaV5aSX9NPpoYy0XPYZtK4tYS75xUYnRHzHnY1XNpSKmnuuDcfRBNCa7mRMwFcK2uq+m2S6UvboqYgsPcxYCr1ZtF/rbe+COSdxRiVPHBBtXkNSyKleE= bolunthompson@BolunLaptop"
      # ];
    };
    home-manager = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    zathura.enable = true;
    kitty = {
      enable = true;
    };
    aerc = {
      enable = true;
      extraConfig.general.unsafe-accounts-conf = true;
    };
    nushell.enable = true;
    mpv.enable = true;
    firefox = {
      enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = false;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-surround
        nerdtree
        vim-devicons
        plenary-nvim
        nvim-treesitter.withAllGrammars
        telescope-nvim
        trouble-nvim
        vim-commentary
        vim-bufkill

        vim-floaterm

        undotree
        vim-fugitive
      ];
      extraConfig = ''
        so /etc/nixos/init.vim
        so /etc/nixos/init.lua
          	'';
    };
    pandoc.enable = true;
    tmux = {
      enable = true;
      shell = "${pkgs.fish}/bin/fish";
      extraConfig = builtins.readFile ./tmux.conf;
    };
    fuzzel = {
      enable = true;
      settings = {
        # fuzzel.ini in the codeberg repo
      };
    };
    feh = {
      enable = true;
    };
    waybar = {
      enable = true;
      inherit (import ./waybar.nix);
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

}
          
