# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
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

  # clear generations
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
    jetbrains.pycharm-oss
    wget
    firefox
    ptyxis
    python3
    tor-browser
    keepass
    telegram-desktop
    amneziawg-tools
    amneziawg-go
    git
    wl-clipboard
  ];

  environment.sessionVariables = {
    GDK_BACKEND = "wayland";
    GSK_RENDERER = "ngl";
  };

  services.tor = {
    enable = true;
    client.enable = true;

    settings = {
      SocksPort = 1488;

    };
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
          gnomeExtensions.forge
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

          history = {
            size = 50000;
            save = 50000;
            ignoreDups = true;
          };
        };

        programs.starship = {
          enable = true;
          enableZshIntegration = true;

          settings = builtins.fromTOML (
            builtins.readFile (
              pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/fang2hou/starship-gruvbox-rainbow/refs/heads/main/starship.toml";
                sha256 = "sha256-DEQN4VZjMQevnAsGI4EE+UJH3B+948PYuUzhCMQfXsw=";
              }
            )
          );
        };

        programs.helix = {
          enable = true;

          settings = {
            theme = "gruvbox_transparent";
            
            keys.normal = {
              y = [ "yank" "yank_to_clipboard" ];
              p = [ "paste_clipboard_after" ];
              P = [ "paste_clipboard_before" ];
              d = [ "delete_selection" "yank_to_clipboard" ];
              c = [ "change_selection" "yank_to_clipboard" ];
            };

            keys.select = {
              y = [ "yank" "yank_to_clipboard" ];
              p = [ "paste_clipboard_after" ];
              P = [ "paste_clipboard_before" ];
              d = [ "delete_selection" "yank_to_clipboard" ];
              c = [ "change_selection" "yank_to_clipboard" ];
            };
            editor = {
              clipboard-provider = "wayland";
              line-number = "relative";
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

        dconf.settings = {
          "org/gnome/Ptyxis" = {
            theme-set-by-appearance = true;
            font-name = "JetBrainsMono Nerd Font 11";
            use-system-font = false;
            default-profile-uuid = "4ef800c438c0bbb23deced356a4536bb";
          };

          "org/gnome/Ptyxis/Profiles/4ef800c438c0bbb23deced356a4536bb" = {
            opacity = 0.80;
          };

          "org/gnome/Ptyxis/Profiles/default" = {
            audible-bell = false;
            scrollback-lines = 10000;
          };

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
