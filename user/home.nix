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
      chromium openhantek6022 glibc nerd-fonts.hack openboard
      (python3.withPackages (python-pkgs: [
        python-pkgs.matplotlib
      ]))
    ];

    fonts.fontconfig.enable = true;

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

    programs.bash = {
	enable = true;
	enableCompletion = true;
	historyControl = [ "erasedups" ];

	shellAliases = {
	    ll = "ls -l";
	    la = "ls -a";
	    dev = "nix develop";
	    google-chrome = "chromium";
	    bw = "bitwise";
	    rebuild = "~/nixos/rebuild.sh";
	    rewrite = "cd ~/nixos && nvim .";
	    work = "cd ~/code/work";
	    personal = "cd ~/code/personal";
	    rocket = "cd ~/code/work/rocket/rocket_caddis_original_fw/SW";
	    communal = "cd ~/code/personal/communal/communal_app";
	};
    };

    programs.starship = {
	enable = true;
	enableBashIntegration = true;
	settings = pkgs.lib.importTOML ./starship.toml;
    };

    programs.fzf = {
	enable = true;
    };

    programs.alacritty = {
      enable = true;
      settings = {
        window.opacity = 0.975;
        env = {
          TERM = "xterm-256color";
        };
	font = {
	    normal = {
		family = "Hack Nerd Font Mono";
		style = "Regular";
	    };
	    italic = {
		family = "Hack Nerd Font Mono";
		style = "Italic";
	    };
	    bold_italic = {
		family = "Hack Nerd Font Mono";
		style = "Bold Italic";
	    };
	    bold = {
		family = "Hack Nerd Font Mono";
		style = "Bold";
	    };
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
    
	vim.api.nvim_set_hl(0, 'Unselected', { fg = \"#cdd6fa\", bg = \"#24273a\" })

	vim.api.nvim_create_autocmd(\"WinEnter\", {
	    callback = function()
		vim.wo.winhighlight = \"Normal:Normal,NormalNC:NormalNC\"
	    end,
	})

	vim.api.nvim_create_autocmd(\"WinLeave\", {
	    callback = function()
		vim.wo.winhighlight = \"Normal:Unselected,NormalNC:Unselected\"
	    end,
	})
    ";
  
    autoCmd = [
      {
        event = "VimEnter";
        command = "packadd termdebug";
      }
    ];

    extraLuaPackages = ps: [ps.jsregexp];

    extraPlugins = with pkgs.vimPlugins; [ gruvbox-material-nvim ];

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
      lsp-lines.enable = true;

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
      flutter-tools.enable = true;
      web-devicons.enable = true;

      lsp = {
        enable = true;

        servers = {
          lua_ls.enable = true;
          nixd.enable = true;
          dartls.settings.lineLength = 120;
          clangd.enable = true;
          html.enable = true;
          cssls.enable = true;
          eslint.enable = true;
	  rust_analyzer.enable = true;
	  rust_analyzer.installCargo = false;
	  rust_analyzer.installRustc = false;
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
      {
	key = "<leader>fo";
	action = ":FlutterOutlineToggle<CR>";
      }

      ];
    
    # colorschemes.rose-pine.enable = true;
    # colorschemes.rose-pine.settings = {
    #   dark_variant = "moon";
    # };
    colorschemes.gruvbox.enable = true;

    colorschemes.everforest = {
	enable = true;
	settings = {
	    background = "hard";
	};
    };

    colorschemes.catppuccin.enable = true;
    colorschemes.catppuccin.settings.transparent_background = false;

    colorscheme = "catppuccin";
  };
}
