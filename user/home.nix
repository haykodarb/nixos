{pkgs, ...}: let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";

  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "nixos-24.05";
  });

  catppuccin = builtins.fetchTarball "https://github.com/catppuccin/nix/archive/main.tar.gz";
in {
  imports = [
    (import "${home-manager}/nixos")
    nixvim.nixosModules.nixvim
    (import "${catppuccin}/modules/nixos")
  ];

  home-manager.users.hayk = {
    imports = [
      (import "${catppuccin}/modules/home-manager")
    ];

    home.stateVersion = "24.05";
    home.packages = with pkgs; [
      btop ripgrep fd bear jdk17 gnumake openocd qgroundcontrol thunderbird slack discord
      electron lazygit catppuccin-gtk catppuccin-kde catppuccin-qt5ct catppuccin-cursors catppuccinifier-gui libreoffice-qt
      nethogs xclip gnome.gnome-disk-utility udisks qbittorrent remmina woeusb-ng
      ntfs3g apmplanner2 alejandra obs-studio kdenlive logseq marktext vlc zoxide util-linux
      calc teams-for-linux mavproxy bitwise fzf gdb cmake stremio supabase-cli
      platformio esptool freecad masterpdfeditor mtr prusa-slicer arduino
      (python3.withPackages (python-pkgs: [
        python-pkgs.matplotlib
      ]))
    ];

    catppuccin.flavor = "mocha";
    catppuccin.enable = true;

    home.sessionPath = [];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
    
    programs.git = {
      enable = true;
      userName = "Hayk Darbinyan";
      userEmail = "work@hayk.ar";
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      initExtra = "
          source ~/.nix-profile/share/git/contrib/completion/git-prompt.sh \n
          setopt PROMPT_SUBST \n
          PS1='%F{red} [ %f%F{cyan}%2~%f%F{red} ] [%f%F{yellow}$(__git_ps1 \" %s \")%f%F{red}] \n > %f'
          eval \"$(direnv hook zsh)\"
        ";
      
      shellAliases = {
        ll = "ls -l";
        bw = "bitwise";
        rebuild = "~/nixos/rebuild.zsh";
        rewrite = "nvim ~/nixos";
        work = "cd ~/code/work";
        personal = "cd ~/code/personal";
        rocket = "cd ~/code/work/rocket/rocket_caddis_original_fw/SW";
        communal = "cd ~/code/personal/communal/communal_app && nix develop";
      };

      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;

      syntaxHighlighting.highlighters = ["brackets" "main" "cursor"];

      history = {
        ignoreDups = true;
        ignoreAllDups = true;
      };
    };

    programs.alacritty = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        window.opacity = 0.975;
        env = {
          TERM = "xterm-256color";
        };
      };
    };

    programs.tmux = {
      enable = true;
      shortcut = "g";
      extraConfig = ''
        set-option -g default-shell $SHELL
        set  default-terminal "xterm-256color"
        set  terminal-overrides ",*:RGB"
        set  escape-time 20
      '';
        #set  base-index 1
        #setw pane-base-index 1
    };
  };

  catppuccin.flavor = "mocha";
  catppuccin.enable = true;

  programs.nixvim = {
    enable = true;

    autoCmd = [
      {
        event = "VimEnter";
        command = "packadd termdebug";
      }
    ];

    extraLuaPackages = ps: [ps.jsregexp];

    opts = {
      number = true;
      clipboard = "unnamedplus";
      shiftwidth = 4;
    };

    globals.mapleader = ",";

    globals.termdebug_config = {
      variables_window_height = 15;
      wide = 1;
    };

    plugins = {
      lualine.enable = true;
      nvim-colorizer.enable = true;
      luasnip.enable = true;
      rainbow-delimiters.enable = true;

      markdown-preview.enable = true;

      neo-tree = {
        enable = false;
        enableGitStatus = true;
        enableDiagnostics = true;
        enableModifiedMarkers = true;
        enableRefreshOnWrite = true;
        closeIfLastWindow = true;
        defaultSource = "buffers";
        resizeTimerInterval = -1;
        buffers = {
          followCurrentFile.enabled = true;
        };
        window.width = 30;
        window.position = "right";
      };

      telescope = {
        enable = true;

        settings = {
          defaults = {
            file_ignore_patterns = [
              "^.git/"
              "^build/"
              "^.cache/"
            ];
            path_display = [
              "filename_first"
              #"truncate"

            ];
          };

          layout_config = {
            prompt_position = "top";
          };
        };

        keymaps = {
          "<leader>p" = {
            action = "live_grep";
            options = {
              desc = "Grep in root dir";
            };
          };
          "<leader>o" = {
            action = "git_files";
            options = {
              desc = "Search git files";
            };
          };
          "<C-p>" = {
            action = "find_files"; 
            options = {
              desc = "Find files root dir";
            };
          };
          "<C-o>" = {
            action = "buffers";
            options = {
              desc = "Search open buffers";
            };
          };
        };
      };

      treesitter = {
        enable = true;
      };

      lsp = {
        enable = true;

        servers = {
          lua-ls.enable = true;
          nixd.enable = true;
          dartls.enable = true;
          clangd.enable = true;
          html.enable = true;
          cssls.enable = true;
          svelte.enable = true;
          #ccls = {
          #  enable = true;
          #  initOptions.cache.directory = "/tmp/ccls-cache";
          #};
        };  

        keymaps = {
          lspBuf = {
            "<C-m>" = "code_action";
            "<C-n>" = "hover";
            "<C-i>" = "format";
            "<leader>ld" = "definition";
            "<leader>lD" = "references";
            "<leader>lt" = "type_definition";
            "<leader>li" = "implementation";
            "<leader>lr" = "rename";
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
        ];
        settings.snippet = {
          expand = ''
            function(args)
            require('luasnip').lsp_expand(args.body)
            end
          '';
        };
        settings.mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.close()";
          "<Tab>" = "cmp.mapping.confirm({ select = true })";
          "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Down>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      gruvbox
      vim-nix
      lspkind-nvim
    ];

    keymaps = [
      # Those are somewhat doom-emacs keybinds...
      {
        # Escape out of terminal
        mode = "t";
        key = "<Esc>";
        action = "<C-\\><C-n>";
      }
      {
	# Escape to remove highlight
	mode = "n";
	key = "<Esc>";
	action = ":noh<CR>";
	options.silent = true;
      }
      {
        # Delete GDB program window and shift GDB to the right and set width to 80.
        key = "<leader>dx";
        action = "<C-\\><C-n>:Program<CR><C-w>:q!<CR>:Gdb<CR><C-W>L70<C-W>|";
      }
      {
        # Delete GDB program window and shift GDB to the right and set width to 80.
        key = "<leader>dz";
        action = ":Termdebug<CR>";
      }
      {
        key = "<leader>c";
        action = ":Continue<CR>";
      }
      {
        key = "<leader>b";
        action = ":Break<CR>";
      }
      {
        key = "<leader>v";
        action = ":Clear<CR>";
      }
      {
        key = "<leader>n";
        action = ":Over<CR>";
      }
      {
        key = "<leader>s";
        action = ":Stop<CR>";
      }
      {
        key = "<leader>a";
        action = ":Run<CR>";
      }

    ];
    
    colorschemes.rose-pine.enable = true;
    colorschemes.rose-pine.settings = {
      dark_variant = "moon";
    };
    colorschemes.catppuccin.enable = true;
    colorschemes.catppuccin.settings.transparent_background = true;

    colorscheme = "catppuccin";
  };
}
