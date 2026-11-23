local M = {}

local cmp = require("cmp")

local function setup_cmdline()
  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
    matching = { disallow_symbol_nonprefix_matching = false },
  })
end

function M.setup()
  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "vsnip" },
    }, {
      {
        name = "buffer",
        keyword_length = 3,
        max_item_count = 8,
        option = {
          -- Only the current buffer, so words from unrelated open files
          -- (and their deps) don't flood the menu.
          get_bufnrs = function()
            return { vim.api.nvim_get_current_buf() }
          end,
        },
      },
    }),
    -- Default order is offset, exact, score, kind, sort_text, length, order.
    -- `recently_used` and `locality` are inserted right after `score` so
    -- that, among equally-good fuzzy matches, cmp prefers whatever you just
    -- picked and whatever is textually close to the cursor (e.g. a name
    -- already used a few lines above) before falling back to kind/length.
    sorting = {
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },
  })

  setup_cmdline()

  local lsp = require("lsp_servers")
  lsp.configure()
  lsp.enable()
end

return M
