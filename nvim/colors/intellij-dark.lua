-- IntelliJ Dark (New UI) colours for Neovim.
-- Palette taken by eye from IntelliJ IDEA's default "Dark" editor scheme.

vim.cmd 'highlight clear'
if vim.fn.exists('syntax_on') == 1 then vim.cmd 'syntax reset' end
vim.o.background = 'dark'
vim.o.termguicolors = true
vim.g.colors_name = 'intellij-dark'

local c = {
  bg        = '#161719',
  bg_alt    = '#2B2D30',  -- popups, sidebars
  bg_line   = '#202125',  -- current line
  border    = '#393B40',
  fg        = '#BCBEC4',
  fg_bright = '#DFE1E5',
  fg_dim    = '#6F737A',
  line_nr   = '#4B5059',
  comment   = '#7A7E85',
  doc       = '#5F826B',
  keyword   = '#CF8E6D',
  string    = '#6AAB73',
  number    = '#2AACB8',
  func      = '#56A8F5',
  field     = '#C77DBB',
  annot     = '#B3AE60',
  tparam    = '#16BAAC',
  tag       = '#D5B778',
  type      = '#D5B778',  -- IntelliJ leaves class names plain; coloured here by choice
  selection = '#214283',
  search    = '#32593D',
  search_cur= '#2D6099',
  red       = '#F75464',
  yellow    = '#F2C55C',
  green     = '#5FB865',
  blue      = '#548AF7',
  diff_add  = '#294436',
  diff_chg  = '#303C51',
  diff_del  = '#4D2F33',
  diff_txt  = '#385570',
}

local hl = function(group, spec) vim.api.nvim_set_hl(0, group, spec) end
local link = function(group, target) vim.api.nvim_set_hl(0, group, { link = target }) end

-- Editor UI
hl('Normal',        { fg = c.fg, bg = c.bg })
hl('NormalNC',      { fg = c.fg, bg = c.bg })
hl('NormalFloat',   { fg = c.fg, bg = c.bg_alt })
hl('FloatBorder',   { fg = c.border, bg = c.bg_alt })
hl('FloatTitle',    { fg = c.fg_bright, bg = c.bg_alt, bold = true })
hl('Cursor',        { fg = c.bg, bg = '#CED0D6' })
hl('CursorLine',    { bg = c.bg_line })
hl('CursorColumn',  { bg = c.bg_line })
hl('ColorColumn',   { bg = c.bg_line })
hl('CursorLineNr',  { fg = '#A1A3AB', bg = c.bg_line })
hl('LineNr',        { fg = c.line_nr })
hl('SignColumn',    { bg = c.bg })
hl('FoldColumn',    { fg = c.line_nr, bg = c.bg })
hl('Folded',        { fg = c.comment, bg = '#2B2D30' })
hl('VertSplit',     { fg = c.border })
hl('WinSeparator',  { fg = c.border })
hl('StatusLine',    { fg = c.fg, bg = c.bg_alt })
hl('StatusLineNC',  { fg = c.fg_dim, bg = c.bg_alt })
hl('TabLine',       { fg = c.fg_dim, bg = c.bg_alt })
hl('TabLineFill',   { bg = c.bg_alt })
hl('TabLineSel',    { fg = c.fg_bright, bg = c.bg })
hl('WinBar',        { fg = c.fg, bg = c.bg })
hl('WinBarNC',      { fg = c.fg_dim, bg = c.bg })
hl('Pmenu',         { fg = c.fg, bg = c.bg_alt })
hl('PmenuSel',      { fg = c.fg_bright, bg = '#2E436E' })
hl('PmenuSbar',     { bg = c.bg_alt })
hl('PmenuThumb',    { bg = '#4E5157' })
hl('Visual',        { bg = c.selection })
hl('VisualNOS',     { bg = c.selection })
hl('Search',        { bg = c.search })
hl('IncSearch',     { bg = c.search_cur })
hl('CurSearch',     { bg = c.search_cur })
hl('Substitute',    { bg = c.search_cur })
hl('MatchParen',    { fg = c.fg_bright, bg = '#43454A', bold = true })
hl('NonText',       { fg = c.line_nr })
hl('Whitespace',    { fg = c.line_nr })
hl('SpecialKey',    { fg = c.line_nr })
hl('EndOfBuffer',   { fg = c.bg })
hl('Directory',     { fg = c.func })
hl('Title',         { fg = c.fg_bright, bold = true })
hl('ErrorMsg',      { fg = c.red })
hl('WarningMsg',    { fg = c.yellow })
hl('MoreMsg',       { fg = c.green })
hl('ModeMsg',       { fg = c.fg })
hl('Question',      { fg = c.green })
hl('QuickFixLine',  { bg = c.bg_line, bold = true })
hl('SpellBad',      { undercurl = true, sp = c.green })
hl('SpellCap',      { undercurl = true, sp = c.yellow })
hl('SpellRare',     { undercurl = true, sp = c.field })
hl('SpellLocal',    { undercurl = true, sp = c.number })
hl('WildMenu',      { fg = c.fg_bright, bg = '#2E436E' })

-- Diff
hl('DiffAdd',       { bg = c.diff_add })
hl('DiffChange',    { bg = c.diff_chg })
hl('DiffDelete',    { fg = '#6F4A4E', bg = c.diff_del })
hl('DiffText',      { bg = c.diff_txt })
hl('Added',         { fg = c.green })
hl('Changed',       { fg = c.blue })
hl('Removed',       { fg = c.red })

-- Syntax
hl('Comment',       { fg = c.comment, italic = true })
hl('Constant',      { fg = c.field, italic = true })
hl('String',        { fg = c.string })
hl('Character',     { fg = c.string })
hl('Number',        { fg = c.number })
hl('Float',         { fg = c.number })
hl('Boolean',       { fg = c.keyword })
hl('Identifier',    { fg = c.fg })
hl('Function',      { fg = c.func })
hl('Statement',     { fg = c.keyword })
hl('Keyword',       { fg = c.keyword })
hl('Conditional',   { fg = c.keyword })
hl('Repeat',        { fg = c.keyword })
hl('Label',         { fg = c.keyword })
hl('Exception',     { fg = c.keyword })
hl('Operator',      { fg = c.fg })
hl('PreProc',       { fg = c.annot })
hl('Include',       { fg = c.keyword })
hl('Define',        { fg = c.keyword })
hl('Macro',         { fg = c.annot })
hl('Type',          { fg = c.type })
hl('StorageClass',  { fg = c.keyword })
hl('Structure',     { fg = c.keyword })
hl('Typedef',       { fg = c.keyword })
hl('Special',       { fg = c.keyword })
hl('SpecialChar',   { fg = c.keyword })
hl('Tag',           { fg = c.tag })
hl('Delimiter',     { fg = c.fg })
hl('SpecialComment',{ fg = c.doc, italic = true })
hl('Debug',         { fg = c.red })
hl('Underlined',    { fg = c.func, underline = true })
hl('Error',         { fg = c.red })
hl('Todo',          { fg = '#8BB33D', bold = true, italic = true })

-- Treesitter
link('@variable',              'Identifier')
hl('@variable.builtin',        { fg = c.keyword })
link('@variable.parameter',    'Identifier')
hl('@variable.member',         { fg = c.field })
hl('@property',                { fg = c.field })
link('@constant',              'Constant')
hl('@constant.builtin',        { fg = c.keyword })
link('@constant.macro',        'Macro')
link('@module',                'Identifier')
link('@label',                 'Label')
link('@string',                'String')
hl('@string.escape',           { fg = c.keyword })
hl('@string.regexp',           { fg = c.string })
hl('@string.special',          { fg = c.keyword })
link('@character',             'Character')
link('@number',                'Number')
link('@boolean',               'Boolean')
link('@type',                  'Type')
hl('@type.builtin',            { fg = c.keyword })
link('@type.definition',       'Type')
hl('@attribute',               { fg = c.annot })
link('@function',              'Function')
hl('@function.call',           { fg = c.fg })
hl('@function.builtin',        { fg = c.fg, italic = true })
link('@function.macro',        'Macro')
hl('@function.method',         { fg = c.func })
hl('@function.method.call',    { fg = c.fg })
hl('@constructor',             { fg = c.fg })
link('@operator',              'Operator')
link('@keyword',               'Keyword')
link('@punctuation',           'Delimiter')
hl('@punctuation.special',     { fg = c.keyword })
link('@comment',               'Comment')
hl('@comment.documentation',   { fg = c.doc, italic = true })
hl('@comment.todo',            { fg = '#8BB33D', bold = true, italic = true })
hl('@comment.error',           { fg = c.red, bold = true })
hl('@comment.warning',         { fg = c.yellow, bold = true })
hl('@comment.note',            { fg = c.func, bold = true })
hl('@tag',                     { fg = c.tag })
hl('@tag.attribute',           { fg = c.fg })
hl('@tag.delimiter',           { fg = c.tag })
hl('@markup.heading',          { fg = c.keyword, bold = true })
hl('@markup.strong',           { bold = true })
hl('@markup.italic',           { italic = true })
hl('@markup.strikethrough',    { strikethrough = true })
hl('@markup.link',             { fg = c.func, underline = true })
hl('@markup.link.url',         { fg = c.func, underline = true })
hl('@markup.raw',              { fg = c.string })
hl('@markup.list',             { fg = c.keyword })
hl('@markup.quote',            { fg = c.comment, italic = true })
link('@diff.plus',             'Added')
link('@diff.minus',            'Removed')
link('@diff.delta',            'Changed')

-- LSP semantic tokens
hl('@lsp.type.parameter',      { fg = c.fg })
hl('@lsp.type.property',       { fg = c.field })
hl('@lsp.type.enumMember',     { fg = c.field, italic = true })
hl('@lsp.type.typeParameter',  { fg = c.tparam })
hl('@lsp.type.annotation',     { fg = c.annot })
hl('@lsp.type.decorator',      { fg = c.annot })
hl('@lsp.type.namespace',      { fg = c.fg })
hl('@lsp.type.method',         { fg = c.fg })
hl('@lsp.type.function',       { fg = c.fg })
hl('@lsp.typemod.method.declaration',   { fg = c.func })
hl('@lsp.typemod.function.declaration', { fg = c.func })
hl('@lsp.typemod.variable.readonly',    { fg = c.field, italic = true })
hl('@lsp.typemod.property.static',      { fg = c.field, italic = true })
hl('@lsp.typemod.method.static',        { italic = true })
hl('@lsp.mod.deprecated',      { strikethrough = true })

-- Diagnostics
hl('DiagnosticError',          { fg = c.red })
hl('DiagnosticWarn',           { fg = c.yellow })
hl('DiagnosticInfo',           { fg = c.func })
hl('DiagnosticHint',           { fg = c.fg_dim })
hl('DiagnosticOk',             { fg = c.green })
hl('DiagnosticUnderlineError', { undercurl = true, sp = c.red })
hl('DiagnosticUnderlineWarn',  { undercurl = true, sp = c.yellow })
hl('DiagnosticUnderlineInfo',  { undercurl = true, sp = c.func })
hl('DiagnosticUnderlineHint',  { undercurl = true, sp = c.fg_dim })
hl('DiagnosticUnnecessary',    { fg = c.fg_dim })
hl('LspReferenceText',         { bg = '#373B39' })
hl('LspReferenceRead',         { bg = '#373B39' })
hl('LspReferenceWrite',        { bg = '#402F33' })
hl('LspInlayHint',             { fg = '#868A91', bg = '#2B2D30' })
hl('LspSignatureActiveParameter', { bold = true, underline = true })

-- Git signs
hl('GitSignsAdd',              { fg = '#549159' })
hl('GitSignsChange',           { fg = '#375FAD' })
hl('GitSignsDelete',           { fg = '#868A91' })

-- Terminal colours (match the iTerm2 "IntelliJ Dark" preset)
local term = { '#161719', '#F75464', '#6AAB73', '#E0BB65', '#56A8F5', '#C77DBB', '#2AACB8', '#BCBEC4',
               '#6F737A', '#FA6675', '#5FB865', '#F2C55C', '#548AF7', '#D88FD0', '#35C0CC', '#DFE1E5' }
for i, col in ipairs(term) do vim.g['terminal_color_' .. (i - 1)] = col end
