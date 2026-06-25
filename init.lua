-- Neovim options
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = '81'
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.wrap = false
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 600
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true

-- We must set leader early to ensure correct keymaps in plugins.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Neovide
if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_hide_mouse_when_typing = true
end

-- Plugins
vim.cmd.packadd 'nvim.undotree'

vim.api.nvim_create_autocmd('PackChanged', {
  pattern = 'nvim-treesitter',
  desc = 'Run `:TSUpdate` after pack changed',
  callback = function(e)
    local kind = e.data.kind
    if kind == 'install' or kind == 'update' then
      local pack_name = e.data.spec.name
      vim.cmd.packadd(pack_name)
      vim.cmd.TSUpdate()
    end
  end,
})
vim.pack.add {
  'https://github.com/miikanissi/modus-themes.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/neogitorg/neogit',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/folke/snacks.nvim',
  'https://github.com/nvim-mini/mini.nvim',
}

-- Modus theme
require('modus-themes').setup {
  on_highlights = function(hl, c)
    hl['@keyword.function'] = { link = '@keyword' }
  end,
}
vim.cmd.colorscheme 'modus_vivendi'

-- Statusline
-- TODO: this section needs a refactoring and clean up
vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
  group = vim.api.nvim_create_augroup('MyStatuslineRedrawMode', { clear = true }),
  callback = function()
    vim.cmd.redrawstatus()
  end,
})
do
  vim.api.nvim_set_hl(0, 'MyStatuslineBar', {
    fg = '#2fafff',
  })

  local ctrl_v = vim.api.nvim_replace_termcodes('<C-v>', true, true, true)
  local ctrl_s = vim.api.nvim_replace_termcodes('<C-s>', true, true, true)

  -- stylua: ignore
  local mode_names = {
    -- TODO: refactor characters
    n = 'Ω',    -- navigation / normal
    no = '∗',   -- operator pending
    nov = '∗',
    noV = '∗',
    ['no' .. ctrl_v] = '∗',
    niI = 'Ω·ι',
    niR = 'Ω·ρ',
    niV = 'Ω·ν',
    nt = 'τ·∇',

    i = 'ζ', -- insert
    ic = 'ζ',
    ix = 'ζ',

    v = '◉ ', -- visual
    V = '◈ ', -- visual line
    [ctrl_v] = '▣ ', -- visual block

    s = '◉ ′', -- select
    S = '◈ ′',
    [ctrl_s] = '▣ ′',

    R = 'ρ', -- replace
    Rc = 'ρ',
    Rx = 'ρ',

    Rv = 'ρᵥ',
    Rvc = 'ρᵥ',
    Rvx = 'ρᵥ',

    c = 'λ', -- command
    cv = 'λ',
    ce = 'λ',

    r = '?',
    rm = '…',
    ['r?'] = '⁇',

    ['!'] = 'λ', -- shell
    t = 'τ', -- terminal
  }

  local function section_mode_riced()
    local _, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
    local raw_mode = vim.fn.mode(1)

    return mode_names[raw_mode] or raw_mode:upper(), mode_hl
  end

  -- stylua: ignore
  local function get_content_active()
    local mode, mode_hl = section_mode_riced()
    local git           = MiniStatusline.section_git({ trunc_width = 40 })
    local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
    local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
    local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
    local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
    local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
    local location      = MiniStatusline.section_location({ trunc_width = 75 })
    local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

    return MiniStatusline.combine_groups({
      '%#MyStatuslineBar#▍%* ',
      { hl = mode_hl,                  strings = { mode } },
      { hl = 'MiniStatuslineDevinfo',  strings = { git, diff, diagnostics, lsp } },
      '%<',
      { hl = 'MiniStatuslineFilename', strings = { filename } },
      '%=',
      { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
      { hl = mode_hl,                  strings = { search, location } },
    })
  end

  local statusline = require 'mini.statusline'
  statusline.setup {
    use_icons = vim.g.have_nerd_font,
    content = {
      active = get_content_active,
    },
  }
end

-- Набор на русском языке
vim.opt.keymap = 'russian-jcukenwin'
vim.opt.iminsert = 0
vim.opt.imsearch = 0

-- Picker
require('snacks').setup {
  picker = {
    enabled = true,
    layout = {
      preview = 'main',
      layout = {
        box = 'vertical',
        backdrop = false,
        width = 0,
        height = 0.4,
        position = 'bottom',
        border = 'top',
        title = ' {title} {live} {flags}',
        title_pos = 'left',
        { win = 'input', height = 1, border = 'bottom' },
        {
          box = 'horizontal',
          { win = 'list', border = 'none' },
          {
            win = 'preview',
            title = '{preview}',
            width = 0.6,
            border = 'left',
          },
        },
      },
    },
    win = {
      input = {
        keys = {
          ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
        },
      },
    },
    sources = {
      files = {
        layout = { hidden = { 'preview' } },
      },
    },
  },
}

-- mini.surround
require('mini.surround').setup {}

-- mini.pairs
require('mini.pairs').setup {}

-- mini.ai
require('mini.ai').setup {}

-- mini.operators
require('mini.operators').setup {}

-- Automatic code formatting
require('conform').setup {
  formatters_by_ft = {
    lua = { 'stylua' },
    php = { 'php_cs_fixer' },
  },
  default_format_opts = {
    lsp_format = 'fallback',
  },
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    else
      return { timeout_ms = 1000 }
    end
  end,
}

-- Syntax highlighting via treesitter
require('nvim-treesitter').install { 'cpp', 'rust', 'zig' }
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    local lang = vim.treesitter.language.get_lang(filetype)
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf, lang)
    end
  end,
})

-- LSP
vim.lsp.config('clangd', {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = {
    '.clangd',
    'compile_commands.json',
    'compile_flags.txt',
    '.git',
  },
})
vim.lsp.enable 'clangd'

-- Autocommands
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('my-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Key mappings
do
  local MiniBufremove = require 'mini.bufremove'

  local function insert_newline_above()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_lines(0, row - 1, row - 1, true, { '' })
  end

  local function insert_newline_below()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_lines(0, row, row, true, { '' })
  end

  local function yank_whole_buffer()
    local reg = vim.v.register
    if reg == '"' then
      reg = '+'
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    vim.fn.setreg(reg, lines, 'l')

    local line_count = #lines
    local last_line = lines[line_count] or ''
    vim.api.nvim_buf_set_mark(0, '[', 1, 0, {})
    vim.api.nvim_buf_set_mark(0, ']', line_count, math.max(#last_line - 1, 0), {})
    vim.hl.on_yank {
      event = {
        operator = 'y',
        regtype = 'V',
        regname = reg,
      },
    }
  end

  -- stylua: ignore
  local maps = {
    { {'i','c'}, '<C-l>', '<C-^>'               },
    { 'n',       'U',     '<C-r>'               },
    { 'n',       '<C-r>', '<NOP>'               },
    { {'n','x'}, 'x',     '"_x'                 },
    { {'n','x'}, 'X',     '"_X'                 },
    { 'n',       '<Esc>', '<cmd>nohlsearch<CR>' },
    { 'x',       '>',     '>gv'                 },
    { 'x',       '<',     '<gv'                 },
    { 'x',       '=',     '=gv'                 },

    { 'n', '[o', insert_newline_above },
    { 'n', ']o', insert_newline_below },

    { 'n', '<leader>bd', function() MiniBufremove.delete() end },
    { 'n', '<leader>by', yank_whole_buffer                     },

    { 'n', '<leader>.',        '<cmd>Ex<CR>'                          },
    { 'n', '<leader><leader>', function() Snacks.picker.files()   end },
    { 'n', '<leader>,',        function() Snacks.picker.buffers() end },
    { 'n', '<leader>/',        function() Snacks.picker.grep()    end },

    { 'n', '<leader>cf', function() require('conform').format{async=true} end },

    { 'n', '<leader>gg', '<cmd>Neogit<CR>' },
  }

  for _, mapping in ipairs(maps) do
    local mode, key, action, description = unpack(mapping)
    vim.keymap.set(mode, key, action, { desc = description })
  end
end
