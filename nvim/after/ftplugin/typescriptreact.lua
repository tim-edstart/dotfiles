--- typescriptreact.lua ftplugin (.tsx)

-- Treesitter highlight (tsx parser)
require("config.treesitter").ensure_parsers_installed { "tsx" }
require("config.treesitter").setup_highlight("tsx")

-- Use tab size 2
local setlocal = vim.opt_local
setlocal.expandtab = true
setlocal.ts = 2
setlocal.sw = 2
setlocal.sts = 2
