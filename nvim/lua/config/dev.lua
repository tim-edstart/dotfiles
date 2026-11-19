-- `dev` from inside Neovim (see ~/.dotfiles/bin/dev).
-- On start and on :cd, a project with setup problems (a missing key, Docker not running,
-- no node_modules in this worktree) gets one notification. :DevDoctor opens `dev doctor`
-- in a floating terminal, which walks through fixing each problem.

local M = {}

local warned = {}  ---@type table<string, true>  directories already warned about this session

local function dev_bin()
  local bin = vim.fn.exepath('dev')
  return bin ~= '' and bin or vim.fn.expand('~/.dotfiles/bin/dev')
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'dev' })
end

--- Warn once per directory if `dev doctor --quiet` lists problems there.
function M.check(dir)
  dir = dir or vim.fn.getcwd()
  if warned[dir] or vim.fn.executable(dev_bin()) == 0 then return end
  vim.system({ dev_bin(), 'doctor', '--quiet' }, { cwd = dir, text = true }, vim.schedule_wrap(function(r)
    if r.code ~= 1 or vim.trim(r.stdout or '') == '' then return end
    warned[dir] = true
    local problems = vim.tbl_map(function(line) return '• ' .. (line:match('\t(.*)') or line) end,
      vim.split(vim.trim(r.stdout), '\n'))
    notify('Setup problems here:\n' .. table.concat(problems, '\n') .. '\n:DevDoctor walks you through fixing them.',
      vim.log.levels.WARN)
  end))
end

--- `dev doctor` in a floating terminal; checks again when it closes.
function M.doctor(dir)
  dir = dir or vim.fn.getcwd()
  local width = math.min(110, math.floor(vim.o.columns * 0.9))
  local height = math.min(32, math.floor(vim.o.lines * 0.8))
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor', style = 'minimal', border = 'rounded', title = ' dev doctor ', title_pos = 'center',
    width = width, height = height,
    row = math.floor((vim.o.lines - height) / 2), col = math.floor((vim.o.columns - width) / 2),
  })
  vim.fn.jobstart({ dev_bin(), 'doctor' }, {
    term = true,
    cwd = dir,
    on_exit = vim.schedule_wrap(function(_, code)
      warned[dir] = nil
      if code == 0 then notify('Setup checks pass.') end
    end),
  })
  vim.cmd.startinsert()
end

function M.setup()
  vim.api.nvim_create_user_command('DevDoctor', function() M.doctor() end,
    { desc = "Check this project's setup and walk through fixing each problem (dev doctor)" })
  local group = vim.api.nvim_create_augroup('dev_doctor', { clear = true })
  vim.api.nvim_create_autocmd({ 'VimEnter', 'DirChanged' }, {
    group = group,
    callback = function() M.check() end,
  })
end

return M
