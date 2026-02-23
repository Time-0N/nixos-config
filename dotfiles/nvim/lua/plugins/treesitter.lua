return {
  {
    "nvim-treesitter/nvim-treesitter",
    dev = false,
    virtual = true, 
    
    opts = {
      ensure_installed = {}, -- Nix handles this, so leave it empty
      auto_install = false,   -- Stops the "dynamically linked" compiler errors
      highlight = { enable = true },
    },
    config = function(_, opts)
      local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
      if status_ok then
        treesitter_configs.setup(opts)
      end
    end,
  },
}
