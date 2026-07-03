-- kotlin.lua: kotlin ftplugin

-- Basic buffer options (indent size, etc.)
-- Note: FileType triggered again after editorconfig might override options, so set it again
local indent_size = tonumber((vim.b.editorconfig or {}).indent_size) or 4
vim.opt_local.expandtab = true
vim.opt_local.ts = indent_size
vim.opt_local.sw = indent_size
vim.opt_local.sts = indent_size

vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = '+1'

-- Use treesitter highlight for kotlin
require("config.treesitter").setup_highlight('kotlin')
require("config.treesitter").ensure_parsers_installed({ 'kotlin' })

-- Formatting: buffer-local :Ktlint command
require("config.formatting").create_buf_command("Ktlint", "ktlint")

-- Auto-format detection
local bufnr = vim.api.nvim_get_current_buf()
vim.api.nvim_create_autocmd('LspAttach', {
  once = true,
  buffer = bufnr,
  callback = function()
    require("config.formatting").maybe_autostart_autoformatting(bufnr, function(project_root)
      local file_contains_pattern = require("utils.path_utils").file_contains_pattern

      -- Check .editorconfig for ktlint settings
      local editorconfig = assert(project_root) .. '/.editorconfig'
      if vim.fn.filereadable(editorconfig) > 0 then
        local _, match = file_contains_pattern(editorconfig, { "^%[%*%.kt%]", "ktlint" })
        if match then
          return true, ("`%s:%s: %s`"):format(".editorconfig", match.line, match.match)
        end
      end

      -- Check build.gradle.kts for ktlint/spotless plugin
      local build_gradle_kts = assert(project_root) .. '/build.gradle.kts'
      if vim.fn.filereadable(build_gradle_kts) > 0 then
        local _, match = file_contains_pattern(build_gradle_kts, { "ktlint", "spotless" })
        if match then
          return true, ("`build.gradle.kts:%s: %s`"):format(match.line, match.match)
        end
      end

      local build_gradle = assert(project_root) .. '/build.gradle'
      if vim.fn.filereadable(build_gradle) > 0 then
        local _, match = file_contains_pattern(build_gradle, { "ktlint", "spotless" })
        if match then
          return true, ("`build.gradle:%s: %s`"):format(match.line, match.match)
        end
      end

      return false, nil
    end)
  end,
})

-- Gradle commands (uses asyncrun, already installed)
local bufcmd = function(...) return vim.api.nvim_buf_create_user_command(0, ...) end

bufcmd('Gradle', function(opts)
  local task = opts.args ~= "" and opts.args or "build"
  vim.cmd(('AsyncRun -mode=term -pos=bottom -rows=15 ./gradlew %s'):format(task))
end, {
  nargs = '?',
  complete = function()
    return { 'build', 'clean', 'test', 'run', 'assemble', 'check', 'dependencies' }
  end,
  desc = 'Run a Gradle task via ./gradlew',
})

bufcmd('GradleTest', function(_)
  vim.cmd('AsyncRun -mode=term -pos=bottom -rows=15 ./gradlew test')
end, { nargs = 0, desc = 'Run Gradle tests' })

bufcmd('GradleRun', function(_)
  vim.cmd('AsyncRun -mode=term -pos=bottom -rows=15 ./gradlew run')
end, { nargs = 0, desc = 'Run Gradle application' })

-- makeprg for :Make support
if vim.fn.filereadable('gradlew') > 0 then
  vim.opt_local.makeprg = './gradlew build'
end
