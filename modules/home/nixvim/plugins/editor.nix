{ ... }:

{
  programs.nixvim = {
    extraConfigLuaPre = ''
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    '';

    extraConfigLua = ''
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local arg = vim.fn.argv(0)
          if arg == "" then return end
          local stat = vim.uv.fs_stat(arg)
          if stat and stat.type == "directory" then
            vim.cmd.bwipeout({ args = { vim.fn.bufnr(arg) }, bang = true })
            vim.cmd.cd(arg)
            vim.schedule(function()
              vim.cmd("Neotree dir=" .. vim.fn.fnameescape(vim.fn.getcwd()))
            end)
          end
        end,
      })
    '';

    plugins = {
      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          filesystem = {
            follow_current_file.enabled = true;
            hijack_netrw_behavior = "disabled";
            filtered_items = {
              visible = true;
              hide_dotfiles = false;
            };
          };
          window = {
            position = "left";
            width = 30;
            mappings = {
              "l" = "open";
              "h" = "close_node";
            };
          };
        };
      };

      flash = {
        enable = true;
        settings.modes.search.enabled = false;
      };

      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
          untracked.text = "▎";
        };
      };

      todo-comments.enable = true;

      trouble = {
        enable = true;
        settings.auto_close = true;
      };

      persistence.enable = true;

      mini = {
        enable = true;
        modules = {
          pairs = { };
          surround = { };
          ai = { };
          indentscope = {
            symbol = "│";
            options.try_as_border = true;
          };
          comment = { };
          hipatterns = { };
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "Explorer (Neo-tree)";
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options.desc = "Diagnostics (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xX";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
        options.desc = "Buffer diagnostics (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xt";
        action = "<cmd>TodoTrouble<cr>";
        options.desc = "TODOs (Trouble)";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "s";
        action.__raw = ''function() require("flash").jump() end'';
        options.desc = "Flash";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "S";
        action.__raw = ''function() require("flash").treesitter() end'';
        options.desc = "Flash Treesitter";
      }
    ];
  };
}
