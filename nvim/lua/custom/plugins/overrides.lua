-- noah-kickstart-overrides.lua
--
-- Personal overrides for Kickstart.nvim, ported from Noah's ~15-year-old vimrc.
--
-- HOW TO USE:
-- 1. Clone kickstart.nvim normally:
--      git clone https://github.com/nvim-lua/kickstart.nvim.git ~/.config/nvim
--
-- 2. In Kickstart's init.lua, uncomment this line near the bottom:
--      { import = 'custom.plugins' },
--
-- 3. Create the custom plugins directory:
--      mkdir -p ~/.config/nvim/lua/custom/plugins
--
-- 4. Drop this file in there:
--      cp noah-kickstart-overrides.lua ~/.config/nvim/lua/custom/plugins/overrides.lua
--
-- 5. ALSO apply the init.lua edits listed at the bottom of this file.
--
-- Everything below is returned as a Lazy.nvim plugin spec (even though most
-- of it is just config/keymaps — Lazy allows "virtual" plugins for this).

return {
  -- ============================================================
  -- SECTION 1: Options & Settings
  -- These override Kickstart defaults. Applied via a virtual
  -- plugin that runs at startup.
  -- ============================================================
  {
    'folke/lazy.nvim', -- piggyback on lazy itself to run our init config
    init = function()
      -- --------------------------------------------------------
      -- Display
      -- --------------------------------------------------------
      vim.opt.relativenumber = true -- Kickstart comments this out; you want it on
      vim.opt.colorcolumn = '120' -- Visual guide at 120 chars (from your old cc=120)
      vim.opt.cursorline = true -- Kickstart already sets this, but being explicit

      -- --------------------------------------------------------
      -- Whitespace (your muscle memory: 4-space tabs everywhere)
      -- Kickstart defaults to 2-space. This overrides globally.
      -- Per-filetype overrides are in the autocommands below.
      -- --------------------------------------------------------
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.softtabstop = 4
      vim.opt.expandtab = true
      vim.opt.smartindent = true
      vim.opt.wrap = false -- You've always had nowrap

      -- Visible whitespace characters (ported from your listchars)
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
      vim.opt.hidden = true -- Allow background buffers without saving
      vim.opt.showcmd = true -- Show incomplete commands

      -- --------------------------------------------------------
      -- Search (Kickstart has ignorecase + smartcase already,
      -- but you also want hlsearch explicitly on)
      -- --------------------------------------------------------
      vim.opt.hlsearch = true

      -- --------------------------------------------------------
      -- Keymaps ported from your vimrc
      -- --------------------------------------------------------

      -- jj to escape insert mode (in your fingers for 15 years)
      vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode' })

      -- ; mapped to : (your "semicolon is useless" efficiency hack)
      vim.keymap.set({ 'n', 'v' }, ';', ':', { desc = 'Command mode shortcut' })

      -- <leader><leader> to jump to previously edited file
      vim.keymap.set('n', '<leader><leader>', '<C-^>', { desc = 'Jump to previous file' })

      -- <leader>p to jump to previous pane
      vim.keymap.set('n', '<leader>p', '<C-W><C-P>', { desc = 'Jump to previous pane' })

      -- <leader>w to strip trailing whitespace
      vim.keymap.set('n', '<leader>w', ':%s/\\s\\+$//e<CR>', { desc = 'Strip trailing whitespace' })

      -- Enter to clear search highlighting
      -- NOTE: Kickstart maps <Esc> for this. Having both is fine.
      vim.keymap.set('n', '<CR>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
      vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle file [E]xplorer' })

      -- Buffer navigation
      vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = '[B]uffer [N]ext' })
      vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = '[B]uffer [P]revious' })
      vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = '[B]uffer [D]elete' })
      vim.keymap.set('n', '<leader>bl', '<cmd>Telescope buffers<CR>', { desc = '[B]uffer [L]ist' })
      -- --------------------------------------------------------
      -- Per-filetype tab/indent settings
      -- (Treesitter handles detection; these set your preferences)
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
  -- SECTION 2: Plugins that replace old vimrc plugins
  -- ============================================================

  -- vim-fugitive: You've used this for years. Still the best Git
  -- plugin for Vim/Neovim. No modern replacement needed.
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Gdiffsplit', 'Gread', 'Gwrite', 'Glog', 'Gblame' },
    keys = {
      { '<leader>gs', '<cmd>Git<CR>', desc = '[G]it [S]tatus' },
      { '<leader>gb', '<cmd>Git blame<CR>', desc = '[G]it [B]lame' },
      { '<leader>gd', '<cmd>Gdiffsplit<CR>', desc = '[G]it [D]iff' },
      { '<leader>gl', '<cmd>Git log --oneline<CR>', desc = '[G]it [L]og' },
    },
  },

  -- NOTE: mini.surround is already in Kickstart (replaces your vim-surround).
  -- NOTE: Telescope replaces your ack.vim for project-wide search.
  -- NOTE: Treesitter replaces your vim-markdown, vim-javascript, etc.
  -- NOTE: mini.statusline replaces your custom statusline function.
  -- NOTE: Kickstart has a neo-tree option you can uncomment in init.lua
  --       (replaces your NERDTree). Look for this line and uncomment it:
  --         require 'kickstart.plugins.neo-tree',
}

-- ============================================================
-- SECTION 3: Edits to make DIRECTLY in Kickstart's init.lua
-- (Don't put these in this file — edit init.lua itself)
-- ============================================================
--
-- 1. LEADER KEY: Kickstart sets space as leader. Try it for a week.
--    If you hate it, change these two lines near the top of init.lua:
--      vim.g.mapleader = ','
--      vim.g.maplocalleader = ','
--
-- 2. NERD FONT: If you install a Nerd Font in Ghostty (recommended
--    for nice icons in the file tree, statusline, etc.), flip this:
--      vim.g.have_nerd_font = true
--
-- 3. NEO-TREE: Uncomment this line near the bottom of init.lua to
--    get a file explorer sidebar (replaces your NERDTree):
--      require 'kickstart.plugins.neo-tree',
--
-- 4. COLORSCHEME: Kickstart defaults to tokyonight-night. To match
--    your Ghostty theme, you could swap to catppuccin. Replace the
--    entire colorscheme plugin block in init.lua with:
--
--    {
--      'catppuccin/nvim',
--      name = 'catppuccin',
--      priority = 1000,
--      config = function()
--        require('catppuccin').setup({
--          flavour = 'mocha',
--          no_italic = true,
--        })
--        vim.cmd.colorscheme 'catppuccin-mocha'
--      end,
--    },
--
-- 5. TREESITTER PARSERS: In the treesitter config section, add the
--    languages you actually use to the parsers list:
--      local parsers = {
--        'bash', 'c', 'diff', 'html', 'lua', 'luadoc',
--        'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
--        'python', 'sql', 'json', 'yaml', 'toml', 'dockerfile',
--      }
--
-- 6. CUSTOM PLUGINS IMPORT: Uncomment this line near the bottom:
--      { import = 'custom.plugins' },
--    This is what makes Lazy.nvim load THIS file.
