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
      btop ripgrep fd bear jdk17 gnumake openocd gcc_multi qgroundcontrol thunderbird slack discord
      electron lazygit catppuccin-gtk catppuccin-kde catppuccin-qt5ct catppuccin-cursors catppuccinifier-gui libreoffice-qt
      nethogs xclip gnome.gnome-disk-utility udisks qbittorrent remmina woeusb-ng
      ntfs3g apmplanner2 alejandra obs-studio kdenlive logseq marktext vlc zoxide util-linux
      calc teams-for-linux inkscape stremio gdb mavproxy python3 wine64 bitwise 
    ];


    catppuccin.flavor = "mocha";
    catppuccin.enable = true;

    home.sessionPath = [];

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
        ";

      shellAliases = {
        ll = "ls -l";
        bw = "bitwise";
        rebuild = "~/nixos/rebuild.zsh";
        rewrite = "nvim ~/nixos";
        work = "cd ~/code/work";
        personal = "cd ~/code/personal";
        rocket = "cd ~/code/work/rocket/rocket_caddis_original_fw/SW";
        communal = "cd ~/code/personal/communal/communal_app";
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

    extraLuaPackages = ps: [ps.jsregexp];

    opts = {
      number = true;
      clipboard = "unnamedplus";
      relativenumber = true;
      shiftwidth = 4;
    };

    globals.mapleader = ",";

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
          "<C-p>" = {
            action = "find_files"; 
            options = {
              desc = "Find files root dir";
            };
          };
          "<C-o>" = {
            action = "git_files";
            options = {
              desc = "Find git files";
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
          ccls = {
            enable = true;
            initOptions.cache.directory = "/tmp/ccls-cache";
          };
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

      dap = {
          enable = true;
          adapters = {
            executables = {
              gdb = {
                command = "gdb";
                id = "gdb";
                args = [
                  "--quiet"
                  "--interpreter=dap"
                ];
              };
            };
          };
          configurations = {
            c = [
              { 
                name = "Attach to port :3333 (Ideally)";
                request = "attach";
                type = "gdb";
                target = "localhost:3333";
                cwd = "\${workspaceFolder}";
                program.__raw = ''
                function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. '/', "file")
                end'';
              }
            ];
          };
          extensions = {
            dap-ui = {
              enable = true;
              layouts = [
                {
                  elements = [
                    {
                      id = "scopes";
                      size = 0.25;
                    }
                    {
                      id = "breakpoints";
                      size = 0.25;
                    }
                    {
                      id = "stacks";
                      size = 0.25;
                    }
                    {
                      id = "watches";
                      size = 0.25;
                    }
                  ];
                  position = "right";
                  size = 40;
                }
              ];
            };
          };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      gruvbox
      vim-nix
      lspkind-nvim
    ];

    keymaps = [];
    
    colorschemes.rose-pine.enable = true;
    colorschemes.rose-pine.settings = {
      dark_variant = "moon";
    };
    colorschemes.catppuccin.enable = true;

    colorscheme = "catppuccin";
  };
}
