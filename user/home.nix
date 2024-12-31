{pkgs, ...}: let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";

  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    # ref = "nixos-24.05";
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
      btop ripgrep fd bear jdk17 gnumake openocd qgroundcontrol thunderbird-bin slack discord
      electron lazygit catppuccin-gtk catppuccin-kde catppuccin-qt5ct catppuccin-cursors catppuccinifier-gui libreoffice-qt
      nethogs xclip gnome-disk-utility udisks qbittorrent remmina woeusb-ng
      ntfs3g obs-studio kdenlive logseq marktext vlc zoxide util-linux
      calc teams-for-linux mavproxy bitwise fzf gdb cmake stremio supabase-cli
      platformio esptool freecad masterpdfeditor mtr prusa-slicer arduino nodejs_22 ugs
      chromium openhantek6022 glibc
      (python3.withPackages (python-pkgs: [
        python-pkgs.matplotlib
      ]))
    ];

    catppuccin.flavor = "mocha";
    catppuccin.enable = true;
    catppuccin.alacritty.enable = true;
    catppuccin.btop.enable = true;

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
        la = "ls -a";
	dev = "nix develop -c \"zsh\"";
        google-chrome = "chromium";
        bw = "bitwise";
        rebuild = "~/nixos/rebuild.zsh";
        rewrite = "nvim ~/nixos";
        work = "cd ~/code/work";
        personal = "cd ~/code/personal";
        rocket = "cd ~/code/work/rocket/rocket_caddis_original_fw/SW";
        communal = "cd ~/code/personal/communal/communal_app && dev";
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
        set  default-terminal "xterm-256color"
        set  terminal-overrides ",*:RGB"
        set  escape-time 20
      '';
        #set  base-index 1
        #setw pane-base-index 1
    };
  };

  programs.nixvim = {
    enable = true;
    
    extraConfigLua = "
      vim.lsp.handlers[\"textDocument/hover\"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = 'single'
        }
      )
      vim.lsp.handlers[\"textDocument/signatureHelp\"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = 'single'
        }
      ) 
      vim.diagnostic.config{
        float={border='single'}
      }
    ";
  
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
      relativenumber = true;
      shiftwidth = 4;
    };

    globals.mapleader = ",";

    globals.termdebug_config = {
      variables_window_height = 15;
      variables_window = 1;
      wide = 1;
    };

    plugins = {
      lualine.enable = true;
      luasnip.enable = true;
      friendly-snippets.enable = true;

      #mini = {
      #  enable = true;
      #  modules.icons = { };
      #  mockDevIcons = true;
      # };

      rainbow-delimiters.enable = true;
      rainbow-delimiters.highlight = [
        "RainbowDelimiterYellow"
        "RainbowDelimiterBlue"
        "RainbowDelimiterOrange"
        "RainbowDelimiterGreen"
        "RainbowDelimiterViolet"
        "RainbowDelimiterCyan"
      ];

      markdown-preview.enable= true;

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

      treesitter.enable = true;

      web-devicons.enable = true;

      lsp = {
        enable = true;

        servers = {
          lua_ls.enable = true;
          nixd.enable = true;
          dartls.enable = true;
          dartls.settings.lineLength = 120;
          clangd.enable = true;
          html.enable = true;
          cssls.enable = true;
          eslint.enable = true;
	  rust_analyzer.enable = true;
	  rust_analyzer.installCargo = true;
	  rust_analyzer.installRustc = true;

        };

        keymaps = {
          lspBuf = {
            "<C-n>" = "hover";
            "<C-m>" = "code_action";
            "<C-i>" = "format";
            "<leader>ld" = "definition";
            "<leader>lD" = "references";
            "<leader>lt" = "type_definition";
            "<leader>li" = "implementation";
            "<leader>lr" = "rename";
          };
        };
      };

	#      blink-cmp = {
	#        enable = true;
	# autoLoad = true;
	#        settings = {
	#          accept = {
	#            auto_brackets = {
	#              enabled = true;
	#            };
	#          };
	#          completion.ghost_text.enabled = true;
	#          trigger = {
	#            signature_help = {
	#              enabled = true;
	#            };
	#          };
	#          signature = {
	#            enabled = true;
	#          };
	#   highlight = {
	#       use_nvim_cmp_as_default = true;
	#   };
	#          sources = {
	#            default = [
	#              "lsp"
	#              "path"
	#              # "luasnip"
	#              "snippets"
	#              "buffer"
	#              "treesitter"
	#            ];
	#          };
	#          opts = {
	#            snippets = {
	#              expand.__raw = ''
	#                function(snippet) require('luasnip').lsp_expand(snippet) end
	#              '';
	#              active.__raw = ''
	#                function(filter)
	#                if filter and filter.direction then
	#                  return require('luasnip').jumpable(filter.direction)
	#                end
	#                return require('luasnip').in_snippet()
	#                end
	#              '';
	#              jump.__raw = ''
	#                function(direction) require('luasnip').jump(direction) end
	#              '';
	#            };
	#          };
	#          menu = {
	#            auto_show = true;
	#            border = "single";
	#            draw = {
	#              gap = 2;
	#              columns = [
	#                {
	#                  __unkeyed-1 = "label";
	#                  __unkeyed-2 = "label_description";
	#                  gap = 1;
	#                }
	#                {
	#                  __unkeyed-1 = "kind_icon";
	#                  __unkeyed-2 = "kind";
	#                  gap = 1;
	#                }
	#                { __unkeyed-1 = "source_name"; }
	#              ];
	#              components = {
	#                label = {
	#                  width = {
	#                    fill = true;
	#                  };
	#                };
	#                "kind_icon" = {
	#                  width = {
	#                    fill = true;
	#                  };
	#                };
	#              };
	#            };
	#          };
	#
	#          documentation = {
	#            auto_show = true;
	#            auto_show_delay_ms = 100;
	#            window.border = "single";
	#          };
	#
	#          keymap = {
	#            preset = "enter";
	#          };
	#
	#         appearance = {
	#           kind_icons = {
	#             Text = "Text";
	#             Method = "Method";
	#             Function = "Function";
	#             Constructor = "Constructor";
	#
	#             Field = "Field";
	#             Variable = "Variable";
	#             Property = "Property";
	#
	#             Class = "Class";
	#             Interface = "Interface";
	#             Struct = "Struct";
	#             Module = "Module";
	#
	#             Unit = "Unit";
	#             Value = "Value";
	#             Enum = "Enum";
	#             EnumMember = "EnumMember";
	#
	#             Keyword = "Keyword";
	#             Constant = "Constant";
	#
	#             Snippet = "Snippet";
	#             Color = "Color";
	#             File = "File";
	#             Reference = "Reference";
	#             Folder = "Folder";
	#             Event = "Event";
	#             Operator = "Operator";
	#             TypeParameter = "Type";
	#            };
	#         };
	#       };
	#      };
	#

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
         "<Enter>" = "cmp.mapping.confirm({ select = true })";
         "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
         "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
       };

       settings.window = {
	   completion.border = "single";
	   documentation.border = "single";
       };
      };
    };

    keymaps = [
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
	key = "<leader>tb";
	action = ":below terminal<CR>12<C-W>_";
      }
      {
	key = "<leader>tr";
	action = ":vertical terminal<CR>";
      }
      {
        # Delete GDB program window and shift GDB to the right and set width to 80.
        key = "<leader>dx";
        action = "<C-\\><C-n>:Program<CR><C-w>:q!<CR>:Gdb<CR><C-W>J:Source<CR><C-W>H:Gdb<CR>70<C-W>|<C-W>r:Var<CR>:below terminal<CR>10<C-W>_:Gdb<CR>30<C-W>_";
      }
      {
        key = "<leader>dz";
        action = ":Termdebug<CR>";
      }
      {
        key = "<leader>dm";
        action = ":make -j8<CR>";
      }
      {
        key = "<leader>dc";
        action = ":Continue<CR>";
      }
      {
        key = "<leader>db";
        action = ":Break<CR>";
      }
      {
        key = "<leader>dv";
        action = ":Clear<CR>";
      }
      {
        key = "<leader>dn";
        action = ":Over<CR>";
      }
      {
        key = "<leader>ds";
        action = ":Stop<CR>";
      }
      {
        key = "<leader>da";
        action = ":Run<CR>";
      }
      {
        key = "<leader>dl";
        action = ":call TermDebugSendCommand('load')<CR>";
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
