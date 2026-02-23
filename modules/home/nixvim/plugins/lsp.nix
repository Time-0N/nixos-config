{ ... }:

{
  programs.nixvim.plugins.lsp = {
    enable = true;

    servers = {
      nil_ls = {
        enable = true;
        settings.formatting.command = [ "nixfmt" ];
      };
      rust_analyzer = {
        enable = true;
        installRustc = false;
        installCargo = false;
      };
      pyright.enable = true;
      hls = {
        enable = true;
        installGhc = false;
      };
      jdtls.enable = true;
      html.enable = true;
      cssls.enable = true;
      jsonls.enable = true;
      vtsls.enable = true;
      bashls.enable = true;
      clangd.enable = true;
      ruby_lsp.enable = true;
      asm_lsp.enable = true;
      lemminx.enable = true;
      lua_ls.enable = true;
      dockerls.enable = true;
      docker_compose_language_service.enable = true;
      yamlls.enable = true;
      taplo.enable = true;
      sqls.enable = true;
      marksman.enable = true;
    };

    keymaps = {
      diagnostic = {
        "[d" = { action = "goto_prev"; desc = "Previous diagnostic"; };
        "]d" = { action = "goto_next"; desc = "Next diagnostic"; };
        "<leader>cd" = { action = "open_float"; desc = "Line diagnostics"; };
      };
      lspBuf = {
        "gd" = { action = "definition"; desc = "Go to definition"; };
        "gD" = { action = "declaration"; desc = "Go to declaration"; };
        "gr" = { action = "references"; desc = "References"; };
        "gI" = { action = "implementation"; desc = "Go to implementation"; };
        "K" = { action = "hover"; desc = "Hover"; };
        "<leader>cr" = { action = "rename"; desc = "Rename"; };
        "<leader>ca" = { action = "code_action"; desc = "Code action"; };
      };
    };
  };
}
