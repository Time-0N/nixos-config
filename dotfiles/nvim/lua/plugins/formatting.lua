return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        nix = { "nixfmt" },
        python = { "ruff" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        json = { "prettierd" },
        java = { "google-java-format" },
        c = { "clang-format" },
      },
    },
  }
}
