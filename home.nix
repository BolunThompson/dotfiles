{config, nix, pkgs, lib, specialArgs, options, modulesPath, nixosConfig, osConfig}:
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
  home.sessionPath = ["${home.homeDirectory}/.local/bin"];
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

  home.file.".jupyter/jupyter_lab_config.py".text = ''
  c = get_config()
  c.ServerApp.ip = '0.0.0.0'
  c.ServerApp.port = 60001
  c.PasswordIdentityProvider.password_required = True
  c.PasswordIdentityProvider.password = 'Keilun 1228!'

'';
home.file.".xinitrc".text = "
  perl -MPOSIX -e '$0=\"Xorg\"; pause' &
  exec gnome-session
";
home.file.".config/autostart/rustdesk.desktop".text = ''
[Desktop Entry]
# The type as listed above
Type=Application
# The version of the desktop entry specification to which this file complies
Version=1.0
# The name of the application
Name=Rustdesk
# The executable of the application, possibly with arguments.
Exec=rustdesk

Type=Application
''; 
  home.file.".config/hypr/hyprpaper.conf".text = ''
    ipc = off
    preload = ~/Photos/miku_wallpaper_1.jpg
    wallpaper = DP-1,~/Photos/miku_wallpaper_1.jpg
    wallpaper = DP-2,~/Photos/miku_wallpaper_1.jpg
  '';
  home.file.".config/ranger/rc.conf".text = ''
  set preview_images false
  '';
  home.file.".config/ranger/rifle.conf".text = ''
    # vim: ft=cfg
    # backport of ranger 1.9.4 rifle.conf
    # This is the configuration file of "rifle", ranger's file executor/opener.
    # Each line consists of conditions and a command.  For each line the conditions
    # are checked and if they are met, the respective command is run.
    #
    # Syntax:
    #   <condition1> , <condition2> , ... = command
    #
    # The command can contain these environment variables:
    #   $1-$9 | The n-th selected file
    #   $@    | All selected files
    #
    # If you use the special command "ask", rifle will ask you what program to run.
    #
    # Prefixing a condition with "!" will negate its result.
    # These conditions are currently supported:
    #   match <regexp> | The regexp matches $1
    #   ext <regexp>   | The regexp matches the extension of $1
    #   mime <regexp>  | The regexp matches the mime type of $1
    #   name <regexp>  | The regexp matches the basename of $1
    #   path <regexp>  | The regexp matches the absolute path of $1
    #   has <program>  | The program is installed (i.e. located in $PATH)
    #   env <variable> | The environment variable "variable" is non-empty
    #   file           | $1 is a file
    #   directory      | $1 is a directory
    #   number <n>     | change the number of this command to n
    #   terminal       | stdin, stderr and stdout are connected to a terminal
    #   X              | A graphical environment is available (darwin, Xorg, or Wayland)
    #
    # There are also pseudo-conditions which have a "side effect":
    #   flag <flags>  | Change how the program is run. See below.
    #   label <label> | Assign a label or name to the command so it can
    #                 | be started with :open_with <label> in ranger
    #                 | or `rifle -p <label>` in the standalone executable.
    #   else          | Always true.
    #
    # Flags are single characters which slightly transform the command:
    #   f | Fork the program, make it run in the background.
    #     |   New command = setsid $command >& /dev/null &
    #   r | Execute the command with root permissions
    #     |   New command = sudo $command
    #   t | Run the program in a new terminal.  If $TERMCMD is not defined,
    #     | rifle will attempt to extract it from $TERM.
    #     |   New command = $TERMCMD -e $command
    # Note: The "New command" serves only as an illustration, the exact
    # implementation may differ.
    # Note: When using rifle in ranger, there is an additional flag "c" for
    # only running the current file even if you have marked multiple files.

    #-------------------------------------------
    # Websites
    #-------------------------------------------
    # Rarely installed browsers get higher priority; It is assumed that if you
    # install a rare browser, you probably use it.  Firefox/konqueror/w3m on the
    # other hand are often only installed as fallback browsers.
    ext x?html?, has surf,             X, flag f = surf -- file://"$1"
    ext x?html?, has vimprobable,      X, flag f = vimprobable -- "$@"
    ext x?html?, has vimprobable2,     X, flag f = vimprobable2 -- "$@"
    ext x?html?, has qutebrowser,      X, flag f = qutebrowser -- "$@"
    ext x?html?, has dwb,              X, flag f = dwb -- "$@"
    ext x?html?, has jumanji,          X, flag f = jumanji -- "$@"
    ext x?html?, has luakit,           X, flag f = luakit -- "$@"
    ext x?html?, has uzbl,             X, flag f = uzbl -- "$@"
    ext x?html?, has uzbl-tabbed,      X, flag f = uzbl-tabbed -- "$@"
    ext x?html?, has uzbl-browser,     X, flag f = uzbl-browser -- "$@"
    ext x?html?, has uzbl-core,        X, flag f = uzbl-core -- "$@"
    ext x?html?, has midori,           X, flag f = midori -- "$@"
    ext x?html?, has opera,            X, flag f = opera -- "$@"
    ext x?html?, has firefox,          X, flag f = firefox -- "$@"
    ext x?html?, has seamonkey,        X, flag f = seamonkey -- "$@"
    ext x?html?, has iceweasel,        X, flag f = iceweasel -- "$@"
    ext x?html?, has chromium-browser, X, flag f = chromium-browser -- "$@"
    ext x?html?, has chromium,         X, flag f = chromium -- "$@"
    ext x?html?, has google-chrome,    X, flag f = google-chrome -- "$@"
    ext x?html?, has epiphany,         X, flag f = epiphany -- "$@"
    ext x?html?, has konqueror,        X, flag f = konqueror -- "$@"
    ext x?html?, has elinks,            terminal = elinks "$@"
    ext x?html?, has links2,            terminal = links2 "$@"
    ext x?html?, has links,             terminal = links "$@"
    ext x?html?, has lynx,              terminal = lynx -- "$@"
    ext x?html?, has w3m,               terminal = w3m "$@"

    #-------------------------------------------
    # Misc
    #-------------------------------------------
    # Define the "editor" for text files as first action
    mime ^text,  label editor = ''${VISUAL:-$EDITOR} -- "$@"
    mime ^text,  label pager  = $PAGER -- "$@"
    !mime ^text, label editor, ext xml|json|csv|tex|py|pl|rb|rs|js|sh|php|dart = ''${VISUAL:-$EDITOR} -- "$@"
    !mime ^text, label pager,  ext xml|json|csv|tex|py|pl|rb|rs|js|sh|php|dart = $PAGER -- "$@"

    ext 1                         = man "$1"
    ext s[wmf]c, has zsnes, X     = zsnes "$1"
    ext s[wmf]c, has snes9x-gtk,X = snes9x-gtk "$1"
    ext nes, has fceux, X         = fceux "$1"
    ext exe, has wine             = wine "$1"
    name ^[mM]akefile$            = make

    #--------------------------------------------
    # Scripts
    #-------------------------------------------
    ext py  = python -- "$1"
    ext pl  = perl -- "$1"
    ext rb  = ruby -- "$1"
    ext js  = node -- "$1"
    ext sh  = sh -- "$1"
    ext php = php -- "$1"
    ext dart = dart run -- "$1"

    #--------------------------------------------
    # Audio without X
    #-------------------------------------------
    mime ^audio|ogg$, terminal, has mpv      = mpv -- "$@"
    mime ^audio|ogg$, terminal, has mplayer2 = mplayer2 -- "$@"
    mime ^audio|ogg$, terminal, has mplayer  = mplayer -- "$@"
    ext midi?,        terminal, has wildmidi = wildmidi -- "$@"

    #--------------------------------------------
    # Video/Audio with a GUI
    #-------------------------------------------
    mime ^video|^audio, has gmplayer, X, flag f = gmplayer -- "$@"
    mime ^video|^audio, has smplayer, X, flag f = smplayer "$@"
    mime ^video,        has mpv,      X, flag f = mpv -- "$@"
    mime ^video,        has mpv,      X, flag f = mpv --fs -- "$@"
    mime ^video,        has mplayer2, X, flag f = mplayer2 -- "$@"
    mime ^video,        has mplayer2, X, flag f = mplayer2 -fs -- "$@"
    mime ^video,        has mplayer,  X, flag f = mplayer -- "$@"
    mime ^video,        has mplayer,  X, flag f = mplayer -fs -- "$@"
    mime ^video|^audio, has vlc,      X, flag f = vlc -- "$@"
    mime ^video|^audio, has totem,    X, flag f = totem -- "$@"
    mime ^video|^audio, has totem,    X, flag f = totem --fullscreen -- "$@"
    mime ^audio,        has audacity, X, flag f = audacity -- "$@"
    ext aup,            has audacity, X, flag f = audacity -- "$@"

    #--------------------------------------------
    # Video without X
    #-------------------------------------------
    mime ^video, terminal, !X, has mpv       = mpv -- "$@"
    mime ^video, terminal, !X, has mplayer2  = mplayer2 -- "$@"
    mime ^video, terminal, !X, has mplayer   = mplayer -- "$@"

    #-------------------------------------------
    # Documents
    #-------------------------------------------
    ext pdf, has llpp,     X, flag f = llpp "$@"
    ext pdf, has zathura,  X, flag f = zathura -- "$@"
    ext pdf, has mupdf,    X, flag f = mupdf "$@"
    ext pdf, has mupdf-x11,X, flag f = mupdf-x11 "$@"
    ext pdf, has apvlv,    X, flag f = apvlv -- "$@"
    ext pdf, has xpdf,     X, flag f = xpdf -- "$@"
    ext pdf, has evince,   X, flag f = evince -- "$@"
    ext pdf, has atril,    X, flag f = atril -- "$@"
    ext pdf, has okular,   X, flag f = okular -- "$@"
    ext pdf, has epdfview, X, flag f = epdfview -- "$@"
    ext pdf, has qpdfview, X, flag f = qpdfview "$@"
    ext pdf, has open,     X, flag f = open "$@"

    ext sc,    has sc,                    = sc -- "$@"
    ext docx?, has catdoc,       terminal = catdoc -- "$@" | $PAGER

    ext                        sxc|xlsx?|xlt|xlw|gnm|gnumeric, has gnumeric,    X, flag f = gnumeric -- "$@"
    ext                        sxc|xlsx?|xlt|xlw|gnm|gnumeric, has kspread,     X, flag f = kspread -- "$@"
    ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has libreoffice, X, flag f = libreoffice "$@"
    ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has soffice,     X, flag f = soffice "$@"
    ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has ooffice,     X, flag f = ooffice "$@"

    ext djvu, has zathura,X, flag f = zathura -- "$@"
    ext djvu, has evince, X, flag f = evince -- "$@"
    ext djvu, has atril,  X, flag f = atril -- "$@"
    ext djvu, has djview, X, flag f = djview -- "$@"

    ext epub, has ebook-viewer, X, flag f = ebook-viewer -- "$@"
    ext epub, has zathura,      X, flag f = zathura -- "$@"
    ext epub, has mupdf,        X, flag f = mupdf -- "$@"
    ext mobi, has ebook-viewer, X, flag f = ebook-viewer -- "$@"

    ext cb[rz], has qcomicbook, X, flag f = qcomicbook "$@"
    ext cb[rz], has mcomix,     X, flag f = mcomix -- "$@"
    ext cb[rz], has zathura,    X, flag f = zathura -- "$@"
    ext cb[rz], has atril,      X, flag f = atril -- "$@"

    ext sla,  has scribus,      X, flag f = scribus -- "$@"
    #-------------------------------------------
    # Images
    #-------------------------------------------
    # mime ^image, has viewnior,  X, flag f = viewnior -- "$@"

    # mime ^image/svg, has inkscape, X, flag f = inkscape -- "$@"
    # mime ^image/svg, has display,  X, flag f = display -- "$@"

    # mime ^image, has imv,       X, flag f = imv -- "$@"
    # mime ^image, has pqiv,      X, flag f = pqiv -- "$@"
    # mime ^image, has sxiv,      X, flag f = sxiv -- "$@"
    # mime ^image, has feh,       X, flag f, !ext gif = feh -- "$@"
    # mime ^image, has mirage,    X, flag f = mirage -- "$@"
    # mime ^image, has ristretto, X, flag f = ristretto "$@"
    # mime ^image, has eog,       X, flag f = eog -- "$@"
    # mime ^image, has eom,       X, flag f = eom -- "$@"
    # mime ^image, has nomacs,    X, flag f = nomacs -- "$@"
    # mime ^image, has geeqie,    X, flag f = geeqie -- "$@"
    # mime ^image, has gpicview,  X, flag f = gpicview -- "$@"
    # mime ^image, has gwenview,  X, flag f = gwenview -- "$@"
    # mime ^image, has xviewer,   X, flag f = xviewer -- "$@"
    # mime ^image, has mcomix,    X, flag f = mcomix -- "$@"
    # mime ^image, has gimp,      X, flag f = gimp -- "$@"
    # mime ^image, has krita,     X, flag f = krita -- "$@"
    # ext kra,     has krita,     X, flag f = krita -- "$@"
    # ext xcf,                    X, flag f = gimp -- "$@"

    #-------------------------------------------
    # Archives
    #-------------------------------------------

    # avoid password prompt by providing empty password
    ext 7z, has 7z = 7z -p l "$@" | $PAGER
    # This requires atool
    ext ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz,     has atool = atool --list --each -- "$@" | $PAGER
    ext iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip, has atool = atool --list --each -- "$@" | $PAGER
    ext 7z|ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz,  has atool = atool --extract --each -- "$@"
    ext iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip, has atool = atool --extract --each -- "$@"

    # Listing and extracting archives without atool:
    ext tar|gz|bz2|xz, has tar = tar vvtf "$1" | $PAGER
    ext tar|gz|bz2|xz, has tar = for file in "$@"; do tar vvxf "$file"; done
    ext bz2, has bzip2 = for file in "$@"; do bzip2 -dk "$file"; done
    ext zip, has unzip = unzip -l "$1" | less
    ext zip, has unzip = for file in "$@"; do unzip -d "''${file%.*}" "$file"; done
    ext ace, has unace = unace l "$1" | less
    ext ace, has unace = for file in "$@"; do unace e "$file"; done
    ext rar, has unrar = unrar l "$1" | less
    ext rar, has unrar = for file in "$@"; do unrar x "$file"; done
    ext rar|zip, has qcomicbook, X, flag f = qcomicbook "$@"
    ext rar|zip, has mcomix,     X, flag f = mcomix -- "$@"
    ext rar|zip, has zathura,    X, flag f = zathura -- "$@"

    #-------------------------------------------
    # Fonts
    #-------------------------------------------
    mime ^font, has fontforge, X, flag f = fontforge "$@"

    #-------------------------------------------
    # Flag t fallback terminals
    #-------------------------------------------
    # Rarely installed terminal emulators get higher priority; It is assumed that
    # if you install a rare terminal emulator, you probably use it.
    # gnome-terminal/konsole/xterm on the other hand are often installed as part of
    # a desktop environment or as fallback terminal emulators.
    mime ^ranger/x-terminal-emulator, has terminology = terminology -e "$@"
    mime ^ranger/x-terminal-emulator, has kitty = kitty -- "$@"
    mime ^ranger/x-terminal-emulator, has alacritty = alacritty -e "$@"
    mime ^ranger/x-terminal-emulator, has sakura = sakura -e "$@"
    mime ^iiiiii/x-terminal-emulator, has lilyterm = lilyterm -e "$@"
    #mime ^ranger/x-terminal-emulator, has cool-retro-term = cool-retro-term -e "$@"
    mime ^ranger/x-terminal-emulator, has termite = termite -x '"$@"'
    #mime ^ranger/x-terminal-emulator, has yakuake = yakuake -e "$@"
    mime ^ranger/x-terminal-emulator, has guake = guake -ne "$@"
    mime ^ranger/x-terminal-emulator, has tilda = tilda -c "$@"
    mime ^ranger/x-terminal-emulator, has st = st -e "$@"
    mime ^ranger/x-terminal-emulator, has terminator = terminator -x "$@"
    mime ^ranger/x-terminal-emulator, has urxvt = urxvt -e "$@"
    mime ^ranger/x-terminal-emulator, has pantheon-terminal = pantheon-terminal -e "$@"
    mime ^ranger/x-terminal-emulator, has lxterminal = lxterminal -e "$@"
    mime ^ranger/x-terminal-emulator, has mate-terminal = mate-terminal -x "$@"
    mime ^ranger/x-terminal-emulator, has xfce4-terminal = xfce4-terminal -x "$@"
    mime ^ranger/x-terminal-emulator, has konsole = konsole -e "$@"
    mime ^ranger/x-terminal-emulator, has gnome-terminal = gnome-terminal -- "$@"
    mime ^ranger/x-terminal-emulator, has xterm = xterm -e "$@"

    #-------------------------------------------
    # Misc
    #-------------------------------------------
    label wallpaper, number 11, mime ^image, has feh, X = feh --bg-scale "$1"
    label wallpaper, number 12, mime ^image, has feh, X = feh --bg-tile "$1"
    label wallpaper, number 13, mime ^image, has feh, X = feh --bg-center "$1"
    label wallpaper, number 14, mime ^image, has feh, X = feh --bg-fill "$1"

    #-------------------------------------------
    # Generic file openers
    #-------------------------------------------
    label open, has xdg-open = xdg-open "$@"
    label open, has open     = open -- "$@"

    # Define the editor for non-text files + pager as last action
  '';

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
    cinnamon.warpinator
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

  # TODO: Set cursor size to be right


  wayland.windowManager.hyprland = {
    # TODO: Make borderless and add extra thing
    extraConfig = ''

  # TODO: Set ideal position based on normal setup
  monitor=eDP-1, preferred,auto,1.5
  monitor=DP-1, preferred,auto,2
  monitor=DP-2, preferred,auto,2
  monitor=,preferred,auto,1

  # exec-once nvim # get eternal nvim and notes setup
  exec-once = waybar & fcitx5 & nm-applet & hyprpaper
  $mod = SUPER
  bind = $mod, Return, exec, kitty
  bind = $mod, W, exec, firefox
#  bind = $mod, E, exec, obsidian
#  bind = $mod, R, exec, kitty nvim
  bind = $mod, T, exec, kitty ranger
  bind = $mod, Q, exec, deluge
  bind = $mod, K, exec, QT_QPA_PLATFORM=xcb anki &
  bind = $mod, M, exec, firefox app.wakingup.com
  bind = $mod, L, exec, virt-manager
  bind = $mod, Y, exec, zathura
  bindr = $mod, D, exec, pkill fuzzel || fuzzel

  bind = $mod, left, movefocus, l
  bind = $mod, right, movefocus, r
  bind = $mod, up, movefocus, u
  bind = $mod, down, movefocus, d
  bind = $mod, 1, workspace, 1
  bind = $mod, 2, workspace, 2
  bind = $mod, 3, workspace, 3
  bind = $mod, 4, workspace, 4
  bind = $mod, 5, workspace, 5
  bind = $mod, 6, workspace, 6
  bind = $mod, 7, workspace, 7
  bind = $mod, 8, workspace, 8
  bind = $mod, 9, workspace, 9
  bind = $mod, 0, workspace, 10

  bind = $mod SHIFT, 1, movetoworkspace, 1
  bind = $mod SHIFT, 1, movetoworkspace, 1
  bind = $mod SHIFT, 2, movetoworkspace, 2
  bind = $mod SHIFT, 3, movetoworkspace, 3
  bind = $mod SHIFT, 4, movetoworkspace, 4
  bind = $mod SHIFT, 5, movetoworkspace, 5
  bind = $mod SHIFT, 6, movetoworkspace, 6
  bind = $mod SHIFT, 7, movetoworkspace, 7
  bind = $mod SHIFT, 8, movetoworkspace, 8
  bind = $mod SHIFT, 9, movetoworkspace, 9
  bind = $mod SHIFT, 0, movetoworkspace, 10
  
  bind = $mod, mouse_down, workspace, e+1
  bind = $mod, mouse_up, workspace, e-1

  bindm = $mod, mouse:272, movewindow
  bindm = $mod, mouse:273, resizewindow

  bind = $mod shift, A, killactive

  bind = $mod, S, layoutmsg,swapwithmaster

  bind = ,XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK +5%
  bind = ,XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK +5%
  bind = ,XF86AudioPlay, exec, playerctl play-pause
  bind = ,XF86AudioNext, exec, playerctl next
  bind = ,XF86AudioPrev, exec, playerctl previous

  bind = ,Print, exec, grim -g "$(slurp)" - | wl-copy

  general {
    border_size = 0
    layout = master
    gaps_in = 5
    gaps_out = 8
  }

  decoration {
     rounding = 8
  }

  master {
    new_is_master = false
  }

  xwayland {
    force_zero_scaling = true
  }

  input {
    touchpad {
      natural_scroll = true
  }
  kb_options = grp:alt_shift_toggle, compose:menu
    follow_mouse = 2
}
  '';
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
  home.stateVersion = "23.05";

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
        settings = {
          editor = {
            line-number = "relative";
            auto-save = true;
            cursor-shape.insert = "bar";
            true-color = true; # because it doesn't recognize blink as true color
          };
            theme = "ayu_dark";
        };
        languages = {
            language-server.ruff = {
                command = "ruff";
                args = ["server" "--preview"];
            };
            language-server.svls = {
              command = "svls";
              args = [];
            };
            language = [{
                name = "python";
                language-servers = ["ruff" "pyright"];
                }
                {
                  # not working for some reason
                  name = "typescript";
                  language-servers = ["typescript-language-server"];
                }
                {
                  name = "verilog";
                  language-servers = ["svls"];
                }
                {
                  name = "rust";
                  # Not working -- try to fix in 2025 when it's less experimental
                  debugger = {
                    name = "binary";
                    transport = "stdio";
                    command = "rust-lldb";
                    templates = [{
                      name = "binary";
                      request = "launch";
                      completion = [ { name = "binary"; completion = "filename"; } ];
                      args = { program = "{0}"; initCommands = [ "command script import /etc/nixos/lldb_vscode_rustc_primer.py" ]; };
                    }];
                  };

                }
            ];
            };
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
