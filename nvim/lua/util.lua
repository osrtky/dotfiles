local M = {}

function M.feedkeys(key_sequence)
  local key_sequence_vim = vim.api.nvim_replace_termcodes(key_sequence, true, false, true)
  vim.api.nvim_feedkeys(key_sequence_vim, "n", false)
end

function M.log(something)
  local file = io.open("/tmp/comppylete.log", "a")
  if file ~= nil then
    file:write(something .. "\n")
    file:flush()
    file:close()
  else
    print("could not open logfile")
  end
end

function M.set_clipboard(text)
  vim.fn.setreg("", text) -- set the default register
  vim.fn.setreg("+", text) -- set clipboard
end

function M.current_file_path()
  return vim.fn.expand("%")
end

function M.yank_current_file_path()
  local curr_buf_path = M.current_file_path() .. "\n"
  M.set_clipboard(curr_buf_path)
end

function M.yank_word_under_cursor_to_register_interactive()
  vim.ui.input({ prompt = "Yank to register: " }, function(reg_name)
    assert(reg_name:len() == 1)
    assert(reg_name:find("%a") ~= nil)
    M.feedkeys("viw" .. '"' .. reg_name .. "y")
  end)
end

function M.get_repo_name()
  local cwd = vim.fn.getcwd()
  return cwd:sub(cwd:match("^.*()/") + 1, -1)
end

function M.replace_string_to_cwd(text, to_replace)
  -- replace "to_replace" to cwd
  if text:sub(1, #to_replace) == to_replace then
    return M.get_repo_name()
  end
  return text
end

function M.endswith(str, suffix)
  return str:sub(-#suffix) == suffix
end

function M.item_in(item, tabl)
  for _, elem in ipairs(tabl) do
    if item == elem then
      return true
    end
  end
  return false
end

function M.replace_word_under_cursor_in_current_buffer()
  M.feedkeys(":%s/<C-R><C-W>//g<Left><Left>")
end

-- LSP
function M.make_lsp_jump_to_symbol_definition_in_split(split_type)
  assert(M.item_in(split_type, { "horizontal", "vertical" }))
  local cmd = split_type == "vertical" and "vs" or "sp"
  return function(o)
    vim.cmd(cmd)
    vim.lsp.buf.definition(o)
  end
end

function M.make_lsp_jump_to_symbol_definition_in_tab()
  return function(o)
    vim.cmd("tab split")
    vim.lsp.buf.definition(o)
  end
end

function M.open_cword_in_external()
  -- not perfect but does the job

  local function has_http(u)
    return (u:find("^http[s]?://.*") ~= nil)
  end

  local function is_url(u)
    -- must start with a letter
    if u:sub(1, 1):find("^[^%a]") then
      return false
    end

    -- Nx(letters.) + (org/com/net) where N >= 1
    for _, ext in ipairs({ "org", "com", "net" }) do
      if u:find("(%a+%.+)" .. ext) ~= nil then
        return true
      end
    end
    return false
  end

  local function is_path(u)
    return u:find("^/%w+/?") ~= nil
  end

  local candidate = vim.fn.expand("<cWORD>")
  if has_http(candidate) or is_url(candidate) then
    os.execute("sensible-browser --incognito " .. candidate)
  elseif is_path(candidate) then
    os.execute("nohup nautilus " .. candidate .. " > /dev/null &")
  else
    vim.print("word under cursor " .. candidate .. " neither a url nor a path")
  end
end

local function uname()
  local handle = io.popen("uname")
  local result = handle:read("*a")
  handle:close()

  -- cache the result for consecutive calls
  uname = function()
    return result
  end

  return result
end

function M.is_macos()
  local os = uname()
  local result = os:match("^Darwin")

  -- cache the result for consecutive calls
  M.is_macos = function()
    return result
  end

  return result
end

function M.is_linux()
  local os = uname()
  local result = os:match("^Linux")

  -- cache the result for consecutive calls
  M.is_linux = function()
    return result
  end

  return result
end

return M
