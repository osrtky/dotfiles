local util = require("util")

local function launch_mason()
  vim.cmd("Mason")
end

local function update_plugins()
  vim.cmd("PlugUpdate")
end

local function telescope_show_mappings()
  require("telescope.builtin").keymaps()
end

local function toggle_line_number()
  local current_value = vim.wo.number
  if current_value then
    if vim.wo.relativenumber then
      vim.wo.relativenumber = false
    end
  end
  vim.wo.number = not current_value
end

local function toggle_relative_line_number()
  local current_value = vim.wo.relativenumber
  vim.wo.relativenumber = not current_value
end

local function yank_py_import_for_current_file_path()
  local filepath = util.current_file_path()
  if not util.endswith(filepath, ".py") then
    return
  end

  local import_st = "from " .. filepath:gsub("/", "."):sub(0, #filepath - 3) .. " import "
  util.set_clipboard(import_st)
end

local M = {}

function M.telescope_find_directories()
  require("telescope.builtin").find_files({
    find_command = { "find", ".", "-type", "d" },
    prompt_title = "Find Directories",
  })
end

function M.telescope_lsp_refs()
  require("telescope.builtin").lsp_references({
    layout_strategy = "vertical",
    layout_config = { width = 0.8 },
    path_display = { "tail" },
  })
end

function M.make_telescope_grep_in_dir_picker()
  return function(prompt_bufnr)
    local selection = require("telescope.actions.state").get_selected_entry()
    require("telescope.actions").close(prompt_bufnr)
    require("telescope.builtin").live_grep({
      search_dirs = { selection[1] },
      prompt_title = string.format("Grep in [%s]", selection[1]),
      -- TODO: fix, doesn't work as it works for live_grep and grep_string builtins
      --vimgrep_arguments = { "--hidden" },
    })
  end
end

local sessions = require("sessions")
local function make_telescope_sessions_picker()
  return function(opts)
    opts = opts or {}

    local entry_maker = function(session_name)
      return {
        value = session_name,
        display = session_name,
        ordinal = session_name,
        cb = function()
          sessions.restore_session(session_name)
        end,
      }
    end

    M.pick(
      opts,
      sessions.get_saved_sessions(),
      entry_maker,
      0.2,
      0.2,
      "Hint",
      "Sessions",
      "vertical"
    )
  end
end

function M.pick(
  opts,
  results,
  entry_maker,
  width,
  height,
  prompt_title,
  results_title,
  layout_strategy
)
  local actions = require("telescope.actions")
  require("telescope.pickers")
    .new(opts, {
      prompt_title = prompt_title,
      results_title = results_title,
      finder = require("telescope.finders").new_table({
        results = results,
        entry_maker = entry_maker,
      }),
      sorter = require("telescope.config").values.generic_sorter(opts),
      layout_strategy = layout_strategy,
      layout_config = { width = width, height = height },
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local state = require("telescope.actions.state")
          -- before closing the prompt, pick up the prompt text to be able to insert later,
          -- in case no entry matches...
          local prompt_text = state.get_current_picker(prompt_bufnr):_get_prompt()
          actions.close(prompt_bufnr)

          local selection = state.get_selected_entry()
          if selection ~= nil then
            selection.cb()
          else
            require("util").feedkeys("a" .. prompt_text)
          end
        end)
        return true
      end,
    })
    :find()
end

local normal_mode_actions = {
  { "yank current file path", util.yank_current_file_path },
  {
    "yank current file path as python import",
    yank_py_import_for_current_file_path,
  },
  { "show mappings", telescope_show_mappings },
  { "launch mason", launch_mason },
  { "update plugins", update_plugins },
  { "save session", sessions.save_session },
  { "restore session ...", make_telescope_sessions_picker() },
  { "replace word under cursor in file", util.replace_word_under_cursor_in_current_buffer },
  { "open word under cursor ...", util.open_cword_in_external },
  { "toggle line numbers", toggle_line_number },
  { "toggle relative line numbers", toggle_relative_line_number },
  { "yank word to register", util.make_yank_word_to_reg() },
  { "yank WORD to register", util.make_yank_WORD_to_reg() },
}

local visual_mode_actions = {
  -- todo: add "join multiline into single line with user-requested delimiter"
  { "yank selection to register", util.make_yank_selection_to_reg() },
  {
    "batch execute",
    function()
      require("util").feedkeys("gv:norm")
    end,
  },
}

function M.make_telescope_actions_picker(mode)
  assert(util.item_in(mode, { "n", "v" }))
  local mode_actions = mode == "n" and normal_mode_actions or visual_mode_actions

  return function(opts)
    opts = opts or {}

    local entry_maker = function(entry)
      return {
        value = entry,
        display = entry[1],
        ordinal = entry[1],
        cb = entry[2],
      }
    end
    M.pick(opts, mode_actions, entry_maker, 0.2, 0.2, "Hint", "Actions", "vertical")
  end
end

return M
