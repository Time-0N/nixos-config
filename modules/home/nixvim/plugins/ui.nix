{ ... }:

{
  programs.nixvim.plugins = {
    lualine = {
      enable = true;
      settings.options = {
        globalstatus = true;
        disabled_filetypes.statusline = [ "dashboard" "alpha" ];
      };
    };

    bufferline = {
      enable = true;
      settings.options = {
        diagnostics = "nvim_lsp";
        always_show_bufferline = false;
        offsets = [
          {
            filetype = "neo-tree";
            text = "Neo-tree";
            highlight = "Directory";
            text_align = "left";
          }
        ];
      };
    };

    noice = {
      enable = true;
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
        };
      };
    };

    which-key = {
      enable = true;
      settings.spec = [
        { __unkeyed-1 = "<leader>f"; group = "Find / File"; }
        { __unkeyed-1 = "<leader>s"; group = "Search"; }
        { __unkeyed-1 = "<leader>g"; group = "Git"; }
        { __unkeyed-1 = "<leader>c"; group = "Code"; }
        { __unkeyed-1 = "<leader>b"; group = "Buffer"; }
        { __unkeyed-1 = "<leader>x"; group = "Diagnostics / Quickfix"; }
      ];
    };

    dashboard = {
      enable = true;
      settings = {
        theme = "doom";
        config = {
          header = [
            ""
            "  ███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗  "
            "  ████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║  "
            "  ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║  "
            "  ██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║  "
            "  ██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║  "
            "  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝ ╚═╝╚═╝     ╚═╝  "
            ""
          ];
          center = [
            { action = "Telescope find_files"; desc = " Find file"; icon = " "; key = "f"; }
            { action = "ene | startinsert"; desc = " New file"; icon = " "; key = "n"; }
            { action = "Telescope oldfiles"; desc = " Recent files"; icon = " "; key = "r"; }
            { action = "Telescope live_grep"; desc = " Find text"; icon = " "; key = "g"; }
            { action = "qa"; desc = " Quit"; icon = " "; key = "q"; }
          ];
        };
      };
    };

    indent-blankline = {
      enable = true;
      settings = {
        indent.char = "│";
        scope.enabled = false;
      };
    };

    notify = {
      enable = true;
      settings.background_colour = "#000000";
    };

    dressing.enable = true;
    web-devicons.enable = true;
    nvim-colorizer.enable = true;
  };
}
