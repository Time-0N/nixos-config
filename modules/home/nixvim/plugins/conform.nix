{ pkgs, ... }:

{
  programs.nixvim = {
    extraPackages = with pkgs; [
      stylua
      shfmt
      nixfmt
      ruff
      prettierd
      google-java-format
      clang-tools
      sqlfluff
      alejandra
    ];

    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          lua = [ "stylua" ];
          sh = [ "shfmt" ];
          nix = [ "nixfmt" ];
          python = [ "ruff_format" ];
          javascript = [ "prettierd" ];
          typescript = [ "prettierd" ];
          html = [ "prettierd" ];
          css = [ "prettierd" ];
          json = [ "prettierd" ];
          java = [ "google-java-format" ];
          c = [ "clang-format" ];
          cpp = [ "clang-format" ];
          yaml = [ "prettierd" ];
          markdown = [ "prettierd" ];
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
      };
    };
  };
}
