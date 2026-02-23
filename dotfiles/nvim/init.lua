-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local status, lspconfig = pcall(require, "lspconfig")
if status then
    lspconfig.nil_ls.setup{}
    lspconfig.rust_analyzer.setup{}
    lspconfig.pyright.setup{}
    lspconfig.hls.setup{}
end
