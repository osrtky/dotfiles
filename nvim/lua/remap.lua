local M = {}

local tls_util = require("telescope_util")
local util = require("util")

local format_file_keymap = "<leader>lf"
local lsp_filetypes = { "cpp", "python", "cuda", "c", "lua", "swift", "rust" }

local function set_generic_keymap()
  local termit = require("termit")

  vim.g.mapleader = " "

  -- [Hint] System clipboard:
  -- "* register is updated immediately upon mouse selection
  -- "+ register is updated with explicit <C-c>

  -- terminal
  vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
  vim.keymap.set("t", "<A-Esc>", "<C-\\><Esc>")
  vim.keymap.set("n", "<A-S-enter>", termit.termit_new)
  vim.keymap.set("n", "<A-enter>", termit.termit_global)

  local tls_blt = require("telescope.builtin")
  -- convenience bindings
  -- [
  vim.keymap.set("n", "<leader><leader>", ":noh<enter>")
  vim.keymap.set("n", "<leader><enter>", tls_blt.resume)
  vim.keymap.set("n", "<leader>q", ":qa<enter>")
  vim.keymap.set("n", "<leader>p", "viwP")
  -- vim.keymap.set("i", "<C-enter>", "<C-n>")  -- not needed anymore with cmp
  -- ]

  -- pum bindings
  -- [
  vim.keymap.set("n", "<leader>b", function()
    tls_blt.buffers({ only_cwd = true })
  end, {}) -- prevent NoName buffers
  vim.keymap.set("n", "<leader>r", tls_blt.registers, {})
  vim.keymap.set("n", "<leader>/", tls_blt.search_history, {})
  vim.keymap.set("n", "<leader>:", tls_blt.command_history, {})
  vim.keymap.set("n", "<leader>m", tls_blt.marks, {})
  vim.keymap.set("n", "<leader>D", ":Telescope file_browser<enter>")
  vim.keymap.set("n", "<leader>d", ":Telescope file_browser path=%:p:h select_buffer=true<enter>")
  vim.keymap.set("n", "<leader>g", tls_blt.live_grep, {})
  vim.keymap.set("n", "<leader>G", tls_blt.grep_string, {})
  vim.keymap.set("n", "<leader>f", tls_blt.find_files, {})
  vim.keymap.set("n", "<leader>F", tls_util.telescope_find_directories, {})
  vim.keymap.set("n", "<leader>a", tls_util.make_telescope_actions_picker("n"), {})
  -- ]

  -- distinguish delete and cut
  vim.keymap.set("v", "d", '"_d')

  -- replace in visual mode
  vim.keymap.set("v", "r", ":s//")

  -- open file in split by default, in tab if requested
  vim.keymap.set("n", "gfv", ":vsplit<enter> gf")
  vim.keymap.set("n", "gft", ":tabnew %<enter> gf")

  -- [VISUAL] move blocks
  vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
  vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
  vim.keymap.set("v", "H", "<gv")
  vim.keymap.set("v", "L", ">gv")

  -- [INSERT] mode hjkl
  vim.keymap.set("i", "<C-h>", "<Left>")
  vim.keymap.set("i", "<C-j>", "<Down>")
  vim.keymap.set("i", "<C-k>", "<Up>")
  vim.keymap.set("i", "<C-l>", "<Right>")

  -- [NORMAL]
  --   current buffer navigation, CTRL
  vim.keymap.set("n", "<C-u>", "<C-u>zz")
  vim.keymap.set("n", "<C-d>", "<C-d>zz")
  vim.keymap.set("n", "<C-j>", "j<C-e>")
  vim.keymap.set("n", "<C-k>", "k<C-y>")

  --   buffer management, ALT
  vim.keymap.set("n", "<A-q>", ":q<enter>")
  vim.keymap.set("n", "<A-w>", ":w<enter>")
  vim.keymap.set("n", "<A-S-q>", ":bd<enter>")
  vim.keymap.set("n", "<A-S-x>", "<C-w>x") -- exchange current with next
  vim.keymap.set("n", "<A-S-t>", "<C-w>T") -- send current to a newtab

  --   split navigation, ALT
  vim.keymap.set("n", "<A-v>", ":vsplit<enter>") -- open split to right
  vim.keymap.set("n", "<A-s>", ":split<enter>") -- open split to bottom
  vim.keymap.set("n", "<A-t>", ":tabnew<enter>") -- open tab to right
  vim.keymap.set("n", "<A-e>", "<C-W>=<enter>") -- equalize
  vim.keymap.set("n", "<A-h>", "<C-w>h")
  vim.keymap.set("n", "<A-j>", "<C-w>j")
  vim.keymap.set("n", "<A-k>", "<C-w>k")
  vim.keymap.set("n", "<A-l>", "<C-w>l")

  --   tab navigation CTRL + ALT
  vim.keymap.set("n", "<C-A-l>", ":tabnext<enter>")
  vim.keymap.set("n", "<C-A-h>", ":tabprev<enter>")
  vim.keymap.set("n", "<C-A-S-l>", ":tabmove +1<enter>")
  vim.keymap.set("n", "<C-A-S-h>", ":tabmove -1<enter>")
end

local function set_lsp_keymap(opts)
  local ft = vim.bo.filetype
  if not util.item_in(ft, lsp_filetypes) then
    return
  end

  -- symbol jumps
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

  vim.keymap.set("n", "gdv", util.make_lsp_jump_to_symbol_definition_in_split("vertical"), opts)
  vim.keymap.set("n", "gds", util.make_lsp_jump_to_symbol_definition_in_split("horizontal"), opts)
  vim.keymap.set("n", "gdt", util.make_lsp_jump_to_symbol_definition_in_tab(), opts)
  vim.keymap.set("n", "gdd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gdr", tls_util.telescope_lsp_refs, opts)

  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

  -- diagnostics' jumps
  vim.keymap.set("n", "ge", vim.diagnostic.open_float)
  vim.keymap.set("n", "gn", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end)
  vim.keymap.set("n", "gp", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end)

  -- actions
  vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>ld", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", format_file_keymap, function()
    vim.lsp.buf.format({ async = true })
  end, opts)
  vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help, opts)

  if ft == "cpp" then
    vim.keymap.set("n", "gh", ":LspClangdSwitchSourceHeader<enter>")
  end
end

local function set_gitsigns_keymap()
  vim.keymap.set("n", "<leader>cn", ":Gitsigns next_hunk<enter>")
  vim.keymap.set("n", "<leader>cp", ":Gitsigns prev_hunk<enter>")
  vim.keymap.set("n", "<leader>cb", ":Gitsigns blame<enter>")
  vim.keymap.set("n", "<leader>cd", ":Gitsigns preview_hunk<enter>")
  vim.keymap.set("n", "<leader>ca", ":Gitsigns stage_hunk<enter>")
  vim.keymap.set("n", "<leader>caa", ":Gitsigns stage_buffer<enter>")
  vim.keymap.set("n", "<leader>cu", ":Gitsigns undo_stage_hunk<enter>")
  vim.keymap.set("n", "<leader>cr", ":Gitsigns reset_hunk<enter>")
end

local function set_lsp_autocmd()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
      set_lsp_keymap({ buf = ev.buf })
    end,
  })
end

function M.setup()
  set_generic_keymap()
  set_gitsigns_keymap()
  set_lsp_autocmd()
end

return M
