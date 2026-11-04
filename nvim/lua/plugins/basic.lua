-- Basic and essential plugins.
---@diagnostic disable: missing-fields

local Plug = require('utils.plug_utils').Plug

return {
  Plug 'nvim-lua/plenary.nvim' { priority = 10000 };
  Plug 'rcarriga/nvim-notify' {
    version = '^3',  -- v3.x releases; lazy-lock.json pins the exact commit
    config = require 'config.ui'.setup_notify,
  };

  Plug 'tweekmonster/helpful.vim' {
    cmd = 'HelpfulVersion',
    func = 'helpful#*',
    init = function()
      pcall(vim.fn.CommandAlias, "HV", "HelpfulVersion")
    end,
    keys = {
      { '<leader>hv', mode = 'n' },
      { '<leader>hv', mode = 'v' },
    },
    config = function()
      vim.keymap.set({'n', 'v'}, '<leader>hv', '<Cmd>echon ""<CR><Cmd>call helpful#cursor_word()<CR>')
    end,
  };

  Plug 'dstein64/vim-startuptime' {
    cmd = 'StartupTime',
  };

  Plug 'embear/vim-localvimrc';
}
