vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
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

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set('n', 'U', '<C-r>')
vim.keymap.set('n', '<C-r>', '<Nop>')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
-- vim.keymap.set({ 'n', 'x' }, 'x', '"_x')
-- vim.keymap.set({ 'n', 'x' }, 'X', '"_X')
-- vim.keymap.set({ 'n', 'x' }, 'c', '"_c')
-- vim.keymap.set({ 'n', 'x' }, 'C', '"_C')

if vim.g.neovide then
  vim.o.guifont = 'Iosevka:h12'
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_hide_mouse_when_typing = true
end

vim.pack.add {
  'https://github.com/miikanissi/modus-themes.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/lewis6991/gitsigns.nvim',
}

require('modus-themes').setup {
  on_highlights = function(hl, c)
    hl['@keyword.function'] = { link = '@keyword' }
  end,
}
vim.cmd.colorscheme 'modus_vivendi'

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
vim.keymap.set('', '<leader>cf', function()
  require('conform').format { async = true }
end, { desc = '[F]ormat buffer' })

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    local lang = vim.treesitter.language.get_lang(filetype)
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf, lang)
    end
  end,
})
