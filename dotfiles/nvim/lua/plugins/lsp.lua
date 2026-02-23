return {
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {},
        rust_analyzer = {},
        pyright = {},
        jdtls = {},
        html = {},
        cssls = {},
        jsonls = {},
        vtsls = {},
        bashls = {},
        clangd = {},
        ruby_lsp = {},
        asm_lsp = {},
        lemminx = {},
      },
    },
  },
}
