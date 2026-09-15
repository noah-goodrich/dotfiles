-- Custom :checkhealth report for external binaries this nvim config depends on
-- (LSP servers, formatters, and CLI tools used by plugins).
--
-- DELIBERATE DESIGN: this list is HAND-MAINTAINED, not derived by executing
-- or parsing the rest of the config. Two independent blind design reviews
-- considered and rejected extraction (walking mason-tool-installer's
-- ensure_installed, conform's formatters_by_ft, etc.) as too fragile and too
-- indirect for the value it would add. Do NOT "fix" this into a parser.
--
-- If you add a formatter, linter, or CLI dependency to this config, you MUST
-- add it here too. This file will not do it for you and will not warn you
-- that it drifted.

local M = {}

-- name -> human-readable reason it's required
local required_binaries = {
  ruff = 'python formatter/linter (conform.nvim, Mason)',
  sqlfluff = 'sql formatter (conform.nvim)',
  stylua = 'lua formatter (conform.nvim, Mason)',
  rg = 'ripgrep — telescope.nvim live_grep/grep_string',
  fd = 'fd — telescope.nvim fast file finding',
  jq = 'jq — merge_claude_settings in install.sh',
  gh = 'GitHub CLI — git credential helper, gp alias',
  pipx = 'pipx — installs/manages ruff, sqlfluff, and other Python CLI tools',
}

function M.check()
  vim.health.start('user: required external binaries')

  local names = vim.tbl_keys(required_binaries)
  table.sort(names)

  for _, name in ipairs(names) do
    local reason = required_binaries[name]
    if vim.fn.executable(name) == 1 then
      vim.health.ok(string.format('%s found (%s)', name, reason))
    else
      vim.health.error(string.format('%s NOT found (%s)', name, reason))
    end
  end
end

return M
