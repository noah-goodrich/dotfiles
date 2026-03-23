-- overrides.lua
--
-- Noah's personal overrides for Kickstart.nvim.
-- Ported from ~15 years of vimrc muscle memory.
--
-- Loaded automatically via { import = 'custom.plugins' } in init.lua.

return {
  -- ============================================================
  -- SECTION 1: Options & Keymaps
  -- Piggybacked on lazy.nvim so they apply at startup.
  -- ============================================================
  {
    'folke/lazy.nvim',
    init = function()
      -- --------------------------------------------------------
      -- Display
      -- --------------------------------------------------------
      vim.opt.relativenumber = true
      vim.opt.colorcolumn = '120'     -- visual ruler at 120 chars
      vim.opt.cursorline = true

      -- --------------------------------------------------------
      -- Whitespace — 4-space tabs globally, per-filetype below
      -- --------------------------------------------------------
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.softtabstop = 4
      vim.opt.expandtab = true
      vim.opt.smartindent = true
      vim.opt.wrap = false

      vim.opt.list = true
      vim.opt.listchars = {
        tab = '» ',
        trail = '·',
        extends = '>',
        precedes = '<',
        nbsp = '␣',
      }

      -- --------------------------------------------------------
      -- Buffers & Behavior
      -- --------------------------------------------------------
      vim.opt.hidden = true    -- allow background buffers without saving
      vim.opt.showcmd = true   -- show incomplete commands in status line
      vim.opt.hlsearch = true

      -- --------------------------------------------------------
      -- Keymaps ported from vimrc
      -- --------------------------------------------------------

      -- jj → Esc (15 years of muscle memory)
      vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode' })

      -- ; → : (command mode without Shift)
      vim.keymap.set({ 'n', 'v' }, ';', ':', { desc = 'Command mode shortcut' })

      -- ,, → Telescope buffer list (fuzzy-pick any open file quickly)
      -- Use Ctrl+^ natively if you want to toggle just the last two files.
      -- This mapping is defined in init.lua and left intentionally here as a comment
      -- so the two files stay in sync. DO NOT re-map <leader><leader> here.

      -- ,p → jump to previous window
      vim.keymap.set('n', '<leader>p', '<C-W><C-P>', { desc = 'Jump to previous pane' })

      -- ,w → strip trailing whitespace
      vim.keymap.set('n', '<leader>w', ':%s/\\s\\+$//e<CR>', { desc = 'Strip trailing whitespace' })

      -- ,o → toggle paste mode (useful when pasting from clipboard in some contexts)
      vim.keymap.set('n', '<leader>o', '<cmd>set paste!<CR>', { desc = 'Toggle [O]paste mode' })

      -- Enter → clear search highlight (Kickstart maps Esc; having both is fine)
      vim.keymap.set('n', '<CR>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

      -- ,e → toggle Neo-tree file explorer
      vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle file [E]xplorer' })

      -- Space+z → zoom/maximize current window  (Space+= to equalise back)
      vim.keymap.set('n', '<Space>z', '<C-w>_<C-w>|', { desc = 'Zoom/maximize window' })

      -- Buffer navigation
      vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>',               { desc = '[B]uffer [N]ext' })
      vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>',           { desc = '[B]uffer [P]revious' })
      vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>',             { desc = '[B]uffer [D]elete' })
      vim.keymap.set('n', '<leader>bl', '<cmd>Telescope buffers<CR>',   { desc = '[B]uffer [L]ist' })

      -- --------------------------------------------------------
      -- Per-filetype indent settings
      -- --------------------------------------------------------
      local ft_group = vim.api.nvim_create_augroup('NoahFiletypeSettings', { clear = true })

      vim.api.nvim_create_autocmd('FileType', {
        group = ft_group,
        pattern = { 'python' },
        callback = function()
          vim.opt_local.tabstop = 4
          vim.opt_local.shiftwidth = 4
          vim.opt_local.softtabstop = 4
          vim.opt_local.foldmethod = 'indent'
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = ft_group,
        pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'json' },
        callback = function()
          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
          vim.opt_local.softtabstop = 2
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = ft_group,
        pattern = { 'sql' },
        callback = function()
          vim.opt_local.tabstop = 4
          vim.opt_local.shiftwidth = 4
          vim.opt_local.softtabstop = 4
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = ft_group,
        pattern = { 'yaml', 'lua' },
        callback = function()
          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
          vim.opt_local.softtabstop = 2
        end,
      })
    end,
  },

  -- ============================================================
  -- SECTION 2: Plugins
  -- ============================================================

  -- vim-fugitive: best Git plugin for Vim/Neovim. No replacement needed.
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Gdiffsplit', 'Gread', 'Gwrite', 'Glog', 'Gblame' },
    keys = {
      { '<leader>gs', '<cmd>Git<CR>',              desc = '[G]it [S]tatus' },
      { '<leader>gb', '<cmd>Git blame<CR>',        desc = '[G]it [B]lame' },
      { '<leader>gd', '<cmd>Gdiffsplit<CR>',       desc = '[G]it [D]iff' },
      { '<leader>gl', '<cmd>Git log --oneline<CR>', desc = '[G]it [L]og' },
    },
  },

  -- toggleterm: floating terminal inside Neovim.
  -- Use Ctrl+\ to open/close. Run claude, cortex, or any CLI from here.
  -- Tip: you can open multiple terminals with a count, e.g. 2<C-\> for terminal #2.
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
      { '<C-\\>', '<cmd>ToggleTerm<CR>', mode = { 'n', 't' }, desc = 'Toggle terminal' },
    },
    opts = {
      shell = 'zsh -i',       -- interactive zsh — sources ~/.zshrc, aliases, prompt
      direction = 'float',
      float_opts = { border = 'curved' },
      shade_terminals = false,
    },
  },
}
