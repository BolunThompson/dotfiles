{ config, nix, pkgs, lib, specialArgs, options, modulesPath, nixosConfig, osConfig }:
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
  home.username = "bolun";
  home.homeDirectory = "/home/bolun";
  home.sessionVariables.XDG_RUNTIME_DIR = "/run/user/1000/";
  home.sessionPath = [ "${home.homeDirectory}/.local/bin" ];
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


  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';
  fonts.fontconfig.enable = true;

  home.file.".jupyter/jupyter_lab_config.py".text = builtins.readFile ./jupyter_lab_config.py;
  home.file.".xinitrc".text = "
  perl -MPOSIX -e '$0=\"Xorg\"; pause' &
  exec gnome-session
";
  home.file.".config/hypr/hyprpaper.conf".text = ''
    ipc = off
    preload = ~/Photos/miku_wallpaper_1.jpg
    wallpaper = DP-1,~/Photos/miku_wallpaper_1.jpg
    wallpaper = DP-2,~/Photos/miku_wallpaper_1.jpg
  '';
  home.file.".config/ranger/rc.conf".text = ''
    set preview_images false
  '';
  home.file.".config/ranger/rifle.conf".text = builtins.readFile ./rifle.conf;

  home.packages = with pkgs; [
    gdrive
    pipewire
    virt-manager
    bitwarden-cli
    discord
    oscclip
    direnv
    neovim-remote
    glow
    deno
    lunarvim
    thefuck
    xorg.xclock
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
    #wineWowPackages.waylandFull
    # winetricks
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

    # bash tooling, since I'm not going to enter a dev shell just to shell script
    nodePackages_latest.bash-language-server
    shellcheck
    shfmt
  ];

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

  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs;
    [
      fcitx5-rime
    ];

  wayland.windowManager.hyprland = {
    # TODO: Set cursor size to be right on 4K monitors
    extraConfig = builtins.readFile ./hyprland.conf;
    enable = false;
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

  programs = {
    git = {
      enable = true;
      userName = "Bolun Thompson";
      userEmail = "me@bolun.dev";
      aliases = {
        commit-add = "commit --amend --no-edit";
      };
    };
    fish.enable = true;
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
        # nvim-web-devicons
        #black
        plenary-nvim
        nvim-treesitter.withAllGrammars
        telescope-nvim
        trouble-nvim
        # vim-startify
        vim-commentary
        vim-bufkill
        # vim-markdown
        #nerdtree-visual-selection
        vim-floaterm
        #copilot-vim
        #gx-entended-vim
        undotree
        vim-fugitive
        # nvim-lspconfig
        # null-ls-nvim
        # purescript-vim
        # haskell-tools-nvim
        # typescript-nvim
        # rust-tools-nvim
        # nvim-cmp
        # cmp-nvim-lsp
        # cmp_luasnip
        # luasnip
        #copilot-lua
        #copilot-cmp
      ];
      extraConfig = ''
        so /etc/nixos/init.vim
        so /etc/nixos/init.lua
          	'';
    };
    pandoc.enable = true;
    fuzzel = {
      enable = true;
      settings = {
        # fuzzel.ini in the codeberg repo

      };
    };
    feh = {
      enable = true;
    };
    # wofi.enable = true; # only for menu scripts, not application launcher
    waybar = {
      enable = true;
      settings.mainBar =
        {
          "layer" = "top";
          "position" = "top";

          "modules-left" = [
            "custom/right-arrow-dark"
          ];
          "modules-center" = [
            "custom/left-arrow-dark"
            "clock#1"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "clock#2"
            "custom/right-arrow-dark"
            "custom/right-arrow-light"
            "clock#3"
            "custom/right-arrow-dark"
          ];
          "modules-right" = [
            "custom/left-arrow-dark"
            "pulseaudio"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "memory"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "cpu"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "battery"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "disk"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "tray"
          ];

          "custom/left-arrow-dark" = {
            "format" = "";
            "tooltip" = false;
          };
          "custom/left-arrow-light" = {
            "format" = "";
            "tooltip" = false;
          };
          "custom/right-arrow-dark" = {
            "format" = "";
            "tooltip" = false;
          };
          "custom/right-arrow-light" = {
            "format" = "";
            "tooltip" = false;
          };

          "clock#1" = {
            "format" = "{:%a}";
            "tooltip" = false;
          };
          "clock#2" = {
            "format" = "{:%I:%M %p}";
            "tooltip" = true;
          };
          "clock#3" = {
            "format" = "{:%b %d}";
            "tooltip" = false;
          };

          "pulseaudio" = {
            "format" = "{icon} {volume:2}%";
            "format-bluetooth" = "{icon}  {volume}%";
            "format-muted" = "MUTE";
            "format-icons" = {
              "headphones" = "";
              "default" = [
                ""
                ""
              ];
            };
            "scroll-step" = 5;
            "on-click" = "pamixer -t";
            "on-click-right" = "pavucontrol";
          };
          "memory" = {
            "interval" = 5;
            "format" = "Mem {}%";
          };
          "cpu" = {
            "interval" = 5;
            "format" = "CPU {usage:2}%";
          };
          "battery" = {
            "states" = {
              "good" = 95;
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{icon}  {capacity}%";
            "format-icons" = [
              ""
              ""
              ""
              ""
              ""
            ];
          };
          "disk" = {
            "interval" = 5;
            "format" = "Disk {percentage_used:2}%";
            "path" = "/";
          };
          "tray" = {
            "icon-size" = 20;
          };
        };
      style = ''
        * {
        	font-size: 1em;
        	font-family: fira-code, monospace;
        }

        window#waybar {
        	background: #292b2e;
        	color: #fdf6e3;
        	padding: 0;
        	margin: 0;
        }

        #custom-right-arrow-dark,
        #custom-left-arrow-dark {
        	color: #1a1a1a;
        }
        #custom-right-arrow-light,
        #custom-left-arrow-light {
        	color: #292b2e;
        	background: #1a1a1a;
        }

        #workspaces,
        #clock.1,
        #clock.2,
        #clock.3,
        #pulseaudio,
        #memory,
        #cpu,
        #battery,
        #disk,
        #tray {
        	background: #1a1a1a;
        }

        #workspaces button {
        	padding: 0 2px;
        	color: #fdf6e3;
        }
        #workspaces button.focused {
        	color: #268bd2;
        }
        #workspaces button:hover {
        	box-shadow: inherit;
        	text-shadow: inherit;
        }
        #workspaces button:hover {
        	background: #1a1a1a;
        	border: #1a1a1a;
        	padding: 0 3px;
        }

        #pulseaudio {
        	color: #268bd2;
        }
        #memory {
        	color: #2aa198;
        }
        #cpu {
        	color: #6c71c4;
        }
        #battery {
        	color: #859900;
        }
        #disk {
        	color: #b58900;
        }

        #clock,
        #pulseaudio,
        #memory,
        #cpu,
        #battery,
        #disk {
        	padding: 0 10px;
        }
      '';
    };
  };
}

           
