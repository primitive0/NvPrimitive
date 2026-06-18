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
  vim.o.guifont = 'Iosevka:h11'
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_hide_mouse_when_typing = true
end

-- Plugins
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
  },
  default_format_opts = {
    lsp_format = 'fallback',
  },
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    else
      return { timeout_ms = 500 }
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

-- Key mappings
do
  -- stylua: ignore start
  local maps = {
    { {'i','c'}, '<C-l>', '<C-^>'               },
    { 'n',       'U',     '<C-r>'               },
    { 'n',       '<C-r>', '<NOP>'               },
    { {'n','x'}, 'x',     '"_x'                 },
    { {'n','x'}, 'X',     '"_X'                 },
    { 'n',       '<Esc>', '<cmd>nohlsearch<CR>' },

    { 'n', '<leader>.',        '<cmd>Ex<CR>'                          },
    { 'n', '<leader><leader>', function() Snacks.picker.files()   end },
    { 'n', '<leader>,',        function() Snacks.picker.buffers() end },
    { 'n', '<leader>/',        function() Snacks.picker.grep()    end },

    { 'n', '<leader>cf', function() require('conform').format{async=true} end },

    { 'n', '<leader>gg', '<cmd>Neogit<CR>' },
  }
  -- stylua: ignore end

  for _, mapping in ipairs(maps) do
    local mode, key, action, description = unpack(mapping)
    vim.keymap.set(mode, key, action, { desc = description })
  end
end
