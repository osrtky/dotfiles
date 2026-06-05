local M = {}

local function configure_lua_ls_with_vim()
  vim.lsp.config("lua_ls", {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using (most
          -- likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
          -- Tell the language server how to find Lua modules same way as Neovim
          -- (see `:h lua-module-load`)
          path = {
            "lua/?.lua",
            "lua/?/init.lua",
          },
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            -- For LSP Settings Type Annotations: https://github.com/neovim/nvim-lspconfig#lsp-settings-type-annotations
            vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
          },
          -- Or pull in all of 'runtimepath'.
          -- NOTE: this is a lot slower and will cause issues when working on
          -- your own configuration.
          -- See https://github.com/neovim/nvim-lspconfig/issues/3189
          -- library = vim.api.nvim_get_runtime_file('', true),
        },
      })
    end,
    settings = {
      Lua = {},
    },
  })
end

function M.configure()
  -- todo: assert on missing cmp_nvim_lsp
  vim.lsp.config.clangd = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  }

  vim.lsp.config.ruff = {
    init_options = {
      settings = {
        lineLength = 100,
      },
    },
  }

  vim.lsp.config.ty = {
    settings = {},
  }

  configure_lua_ls_with_vim()
end

function M.enable()
  vim.lsp.enable("clangd")

  vim.lsp.enable("ruff")
  vim.lsp.enable("ty")

  vim.lsp.enable("stylua")
  vim.lsp.enable("lua_ls")

  vim.lsp.enable('sourcekit')
end

return M
