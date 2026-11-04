--- javascriptreact.lua ftplugin (.jsx)

-- Treesitter highlight (javascript parser covers jsx)
require("config.treesitter").ensure_parsers_installed { "javascript" }
require("config.treesitter").setup_highlight("javascript")

-- Use tab size 2
local setlocal = vim.opt_local
setlocal.expandtab = true
setlocal.ts = 2
setlocal.sw = 2
setlocal.sts = 2
