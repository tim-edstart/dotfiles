-- Show git blame for the cursor line in the tmux status bar, next to the working directory.
-- Neovim writes it to the pane option @nvim_blame; tmux/tmux.conf shows it in status-right.
-- Each pane keeps its own value, so it only shows while a Neovim pane is active.

local M = {}

local DELAY_MS = 150
local MAX_SUMMARY = 50

local pane = vim.env.TMUX_PANE
local timer = nil
local last_key = nil
local job = nil

local function tmux_set(text)
  local cmd = { 'tmux', 'set-option', '-p', '-t', pane }
  if text == nil then
    vim.list_extend(cmd, { '-u', '@nvim_blame' })
  else
    -- '#[' would start a tmux style in the status line; '#' alone is harmless
    vim.list_extend(cmd, { '@nvim_blame', (text:gsub('#%[', '# [')) })
  end
  vim.list_extend(cmd, { ';', 'refresh-client', '-S' })
  vim.system(cmd)
end

local function ago(epoch)
  local s = os.time() - epoch
  if s < 3600 then return math.max(1, math.floor(s / 60)) .. 'm ago' end
  if s < 86400 then return math.floor(s / 3600) .. 'h ago' end
  if s < 86400 * 30 then return math.floor(s / 86400) .. 'd ago' end
  if s < 86400 * 365 then return math.floor(s / (86400 * 30)) .. 'mo ago' end
  return os.date('%Y-%m-%d', epoch)
end

local function parse(porcelain)
  local sha = porcelain:match('^(%x+)')
  if not sha then return nil end
  if sha:match('^0+$') then return 'Not committed yet' end
  local author = porcelain:match('\nauthor ([^\n]*)') or '?'
  local time = tonumber(porcelain:match('\nauthor%-time (%d+)') or '')
  local summary = porcelain:match('\nsummary ([^\n]*)') or ''
  if vim.fn.strchars(summary) > MAX_SUMMARY then
    summary = vim.fn.strcharpart(summary, 0, MAX_SUMMARY - 1) .. '…'
  end
  return string.format('%s %s, %s · %s', sha:sub(1, 7), author, time and ago(time) or '?', summary)
end

local function update()
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= '' or file == '' or vim.fn.filereadable(file) == 0 then
    if last_key ~= nil then last_key = nil; tmux_set(nil) end
    return
  end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local key = table.concat({ buf, line, vim.b[buf].changedtick }, ':')
  if key == last_key then return end
  last_key = key

  if job then pcall(job.kill, job, 15) end
  -- --contents - blames the buffer as it is now, so unsaved edits keep line numbers right
  local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n') .. '\n'
  job = vim.system(
    { 'git', 'blame', '-w', '--porcelain', '-L', line .. ',' .. line, '--contents', '-', '--', file },
    { cwd = vim.fs.dirname(file), stdin = content, text = true },
    function(res)
      vim.schedule(function()
        if key ~= last_key then return end  -- cursor moved on while git ran
        tmux_set(res.code == 0 and parse(res.stdout) or nil)
      end)
    end)
end

function M.setup()
  if not pane or vim.fn.executable('tmux') == 0 then return end
  timer = vim.uv.new_timer()
  local group = vim.api.nvim_create_augroup('tmux_blame', { clear = true })
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufEnter', 'BufWritePost', 'FocusGained' }, {
    group = group,
    callback = function()
      timer:stop()
      timer:start(DELAY_MS, 0, vim.schedule_wrap(update))
    end,
  })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      vim.system({ 'tmux', 'set-option', '-p', '-t', pane, '-u', '@nvim_blame' }):wait(500)
    end,
  })
end

return M
