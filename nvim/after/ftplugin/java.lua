-- java.lua: java ftplugin

-- Basic buffer options (indent size, etc.)
local indent_size = tonumber((vim.b.editorconfig or {}).indent_size) or 4
vim.opt_local.expandtab = true
vim.opt_local.ts = indent_size
vim.opt_local.sw = indent_size
vim.opt_local.sts = indent_size

vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = '+1'

-- Use treesitter highlight for java
require("config.treesitter").ensure_parsers_installed({ 'java' })
require("config.treesitter").setup_highlight('java')

-- makeprg for :Make support
if vim.fn.filereadable('gradlew') > 0 then
  vim.opt_local.makeprg = './gradlew build'
end
