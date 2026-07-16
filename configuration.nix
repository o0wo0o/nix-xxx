# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixsos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Samara";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."owo" = {
    isNormalUser = true;
    description = "owo";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # nix configs
  services.fstrim.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  systemd.services.nix-gc.preStart = ''
    ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +3
  '';

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    openvpn
    wget
    firefox
    python3
    tor-browser
    keepass
    gparted
    telegram-desktop
    burpsuite
    steam
    amneziawg-tools
    amneziawg-go
    git
    wl-clipboard
  ];

  # Flatpak packages
  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      "com.logseq.Logseq"
      "com.cakewallet.CakeWallet"
      "com.cypherstack.stackwallet"
    ];
  };

  environment.sessionVariables = {
    GDK_BACKEND = "wayland";
    GSK_RENDERER = "ngl";
  };

  environment.variables = {
    EDITOR = "hx";
    SUDO_EDITOR = "hx";
  };

  system.stateVersion = "26.05"; # Did you read the comment?

  # home manager
  home-manager.users =
    let
      configTemplate = { pkgs, lib, ... }: {

        home.stateVersion = "26.05";

        home.packages = with pkgs; [
          gruvbox-gtk-theme
          gruvbox-plus-icons
          capitaine-cursors

        ];

        programs.home-manager.enable = true;
        fonts.fontconfig.enable = true;

        gtk = {
          enable = true;

          theme = {
            name = "Gruvbox-Dark-B";
            package = pkgs.gruvbox-gtk-theme;
          };

          iconTheme = {
            name = "Gruvbox-Plus-Dark";
            package = pkgs.gruvbox-plus-icons;
          };

          cursorTheme = {
            name = "capitaine-cursors";
            package = pkgs.capitaine-cursors;
          };

          gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };

          gtk4.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };
        };

        programs.zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;

          initExtra = ''
            # Автозапуск Zellij только внутри Foot с замещением процесса Zsh
            if [[ "$TERMINAL_EMULATOR" == "foot" || "$TERM" == "foot" ]] && [ -z "$ZELLIJ" ]; then
                exec zellij attach -c
            fi
          '';

          history = {
            size = 50000;
            save = 50000;
            ignoreDups = true;
          };
        };

        programs.starship = {
          enable = true;
          enableZshIntegration = true;

          settings =
            (builtins.fromTOML (
              builtins.readFile (
                pkgs.fetchurl {
                  url = "https://raw.githubusercontent.com/fang2hou/starship-gruvbox-rainbow/refs/heads/main/starship.toml";
                  sha256 = "sha256-DEQN4VZjMQevnAsGI4EE+UJH3B+948PYuUzhCMQfXsw=";
                }
              )
            ))
            // {
              time.disabled = true;
            };
        };

        programs.foot = {
          enable = true;

          settings = {
            main = {
              font = "JetBrainsMono Nerd Font:size=13";
            };

            csd = {
              preferred = "none";
              size = 0;
            };

            colors-dark = {
              alpha = 0.80;

              # Точное попадание в палитру Helix Gruvbox
              background = "282828";
              foreground = "ebdbb2";

              # Базовая палитра (Regular)
              regular0 = "282828"; # black
              regular1 = "cc241d"; # red
              regular2 = "b8bb26"; # green (взят яркий, чтобы ls соответствовал коду)
              regular3 = "d79921"; # yellow
              regular4 = "458588"; # оригинальный приглушенный синий (для баланса системы)
              regular5 = "b16286"; # magenta
              regular6 = "689d6a"; # cyan (мягкий морской)
              regular7 = "a89984"; # white

              # Интенсивная палитра (Bright — то, что Helix берет для подсветки кода)
              bright0 = "928374"; # bright black (комментарии)
              bright1 = "fb4934"; # bright red
              bright2 = "b8bb26"; # bright green
              bright3 = "fabd2f"; # bright yellow
              bright4 = "00a1a1"; # ВАШ яркий синий/бирюзовый (Helix подсветит им переменные)
              bright5 = "d3869b"; # bright magenta
              bright6 = "8ec07c"; # bright cyan
              bright7 = "fbf1c7"; # bright white
            };
          };
        };

        programs.helix = {
          enable = true;

          settings = {
            theme = "gruvbox_transparent";

            editor = {
              line-number = "relative";
              clipboard-provider = "wayland";
              mouse = true;

              lsp.display-messages = true;
              auto-completion = true;
            };

            editor.cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
          };

          languages.language-server = {
            pyright = {
              command = "pyright-langserver";
              args = [ "--stdio" ];
            };
            nixd = {
              command = "nixd";
            };
            vtsls = {
              command = "vtsls";
              args = [ "--stdio" ];
            };
            sqls = {
              command = "sqls";
            };
            phpactor = {
              command = "phpactor";
              args = [ "language-server" ];
            };
          };

          languages.language = [
            {
              name = "nix";
              language-servers = [ "nixd" ];
              formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
              auto-format = true;
            }
            {
              name = "python";
              language-servers = [ "pyright" ];
              formatter = {
                command = lib.getExe pkgs.black;
                args = [
                  "-"
                  "--quiet"
                ];
              };
              auto-format = true;
            }
            {
              name = "javascript";
              language-servers = [ "vtsls" ];
              formatter = {
                command = lib.getExe pkgs.prettier;
                args = [
                  "--parser"
                  "typescript"
                ];
              };
              auto-format = true;
            }
            {
              name = "php";
              language-servers = [ "phpactor" ];
              auto-format = false;
            }
            {
              name = "sql";
              language-servers = [ "sqls" ];
            }
          ];

          themes = {
            gruvbox_transparent = {
              "inherits" = "gruvbox";
              "ui.background" = { };
            };
          };

          extraPackages = with pkgs; [
            pyright
            black
            vtsls
            prettier
            sqls
            phpactor
            nixd
            nixfmt-rfc-style
          ];
        };

        programs.zellij = {
          enable = true;
          enableZshIntegration = false;

          settings = {
            theme = "gruvbox-dark";
            copy_command = "wl-copy";
            copy_on_select = true;
          };
        };

        dconf.settings = {

          "org/gnome/shell/extensions/user-theme" = {
            name = "Gruvbox-Dark-B";
          };

          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };

          "org/gnome/desktop/input-sources" = {
            sources = [
              (lib.gvariant.mkTuple [
                "xkb"
                "us"
              ])
              (lib.gvariant.mkTuple [
                "xkb"
                "ru"
              ])
            ];
            xkb-options = [ "grp:alt_shift_toggle" ];
          };
        };
      };
    in
    builtins.mapAttrs (name: value: configTemplate) {
      owo = { };
      root = { };
    };

  # nix linker
  programs.nix-ld.enable = true;

  # zsh
  programs.zsh.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # gnome
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

}
