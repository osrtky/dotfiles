local M = {}

function M.setup()
  require("nvim-treesitter").setup({
    -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
    install_dir = vim.fn.stdpath("data") .. "/site",
  })

  require("nvim-treesitter").install({
    "bash",
    "c",
    "cpp",
    "cuda",
    "lua",
    "json",
    "make",
    "vim",
    "vimdoc",
    "query",
    "python",
    "rust",
    "sql",
    "toml",
  })
end

return M
