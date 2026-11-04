--- typescript.lua ftplugin

-- Treesitter highlight
require("config.treesitter").ensure_parsers_installed { "typescript" }
require("config.treesitter").setup_highlight("typescript")

-- Use tab size 2
local setlocal = vim.opt_local
setlocal.expandtab = true
setlocal.ts = 2
setlocal.sw = 2
setlocal.sts = 2
