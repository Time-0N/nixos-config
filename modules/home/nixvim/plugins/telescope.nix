{ ... }:

{
  programs.nixvim.plugins.telescope = {
    enable = true;

    settings.defaults = {
      layout_strategy = "horizontal";
      layout_config.prompt_position = "top";
      sorting_strategy = "ascending";
      winblend = 0;
    };

    keymaps = {
      "<leader><space>" = {
        action = "find_files";
        options.desc = "Find files";
      };
      "<leader>ff" = {
        action = "find_files";
        options.desc = "Find files";
      };
      "<leader>fg" = {
        action = "live_grep";
        options.desc = "Grep";
      };
      "<leader>fb" = {
        action = "buffers";
        options.desc = "Buffers";
      };
      "<leader>fr" = {
        action = "oldfiles";
        options.desc = "Recent files";
      };
      "<leader>fh" = {
        action = "help_tags";
        options.desc = "Help pages";
      };
      "<leader>fw" = {
        action = "grep_string";
        options.desc = "Word under cursor";
      };
      "<leader>sd" = {
        action = "diagnostics";
        options.desc = "Diagnostics";
      };
      "<leader>sk" = {
        action = "keymaps";
        options.desc = "Keymaps";
      };
      "<leader>sc" = {
        action = "command_history";
        options.desc = "Command history";
      };
      "<leader>sm" = {
        action = "marks";
        options.desc = "Marks";
      };
      "<leader>sr" = {
        action = "resume";
        options.desc = "Resume last search";
      };
      "<leader>gc" = {
        action = "git_commits";
        options.desc = "Git commits";
      };
      "<leader>gs" = {
        action = "git_status";
        options.desc = "Git status";
      };
      "<leader>sg" = {
        action = "live_grep";
        options.desc = "Grep (root dir)";
      };
    };

    extensions = {
      fzf-native.enable = true;
      ui-select.enable = true;
    };
  };
}
