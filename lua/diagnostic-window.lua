local NuiSplit = require("nui.split")

local M = {}
local windows = {}


local remove_buffer = function(bufnr)
  if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) then
    local success, err = pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
    if not success and err:match("E523") then
      vim.schedule_wrap(function()
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end)()
    end
  end
end

---Determines if the window exists and is valid.
---@param state table The current state of the plugin for the given window.
---@return boolean True if the window exists and is valid, false otherwise.
local window_exists = function(state)
  local window_exists
  local winid = state.winid or 0
  local bufnr = state.bufnr or 0

  if winid < 1 then
    window_exists = false
  else
    window_exists = vim.api.nvim_win_is_valid(winid)
      and vim.api.nvim_win_get_number(winid) > 0
      and vim.api.nvim_win_get_buf(winid) == bufnr
  end

  if not window_exists then
    remove_buffer(bufnr)
    state.winid = nil
    state.bufnr = nil
  end
  return window_exists
end

local function wrap_lines(str, max_line_length)
  local lines = {}
  if not str then
    return lines
  end
  local line
  str:gsub('(%s*)(%S+)',
    function(spc, word)
      if not line or #line + #spc + #word > max_line_length then
        table.insert(lines, line)
        line = word
      else
        line = line..spc..word
      end
    end
  )
  table.insert(lines, line)
  return lines
end

local severity_map = {
  [1] = 'ERROR',
  [2] = 'WARNING',
  [3] = 'INFO',
  [4] = 'HINT',
  [5] = 'DEPRECATION',
}

M.show = function ()
  local source_win = vim.api.nvim_get_current_win()
  windows[source_win] = windows[source_win] or {}
  local state = windows[source_win]
  local _window_exists = window_exists(state)

  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  local diag = vim.diagnostic.get(0, { lnum = linenr - 1 })
  if #diag == 0 then
    if _window_exists then
      vim.api.nvim_win_close(state.winid, true)
      remove_buffer(state.bufnr)
      windows[source_win] = nil
    end
    vim.notify("No diagnostics to show for this line")
    return
  end

  local cols = vim.api.nvim_win_get_width(0) - 4
  local header = "Diagnostics for line "..linenr .. " in " .. vim.fn.expand("%:p:t")
  if #header > cols then
    header = header:sub(1, cols)
  end
  local lines = {
    "┏" .. string.rep("━", cols - 2) .. "┓",
    "┃ " .. header .. string.rep(" ", cols - #header - 4) .. " ┃",
    "┗" .. string.rep("━", cols - 2) .. "┛",
  }
  for i, d in ipairs(diag) do
    table.insert(lines, "")
    local level = severity_map[d.severity] or "UNKNOWN"
    local msg = level .. ": " .. d.message
    local isFirst = true
    for line in msg:gmatch("([^\n]*)\n?") do
      for _, wrapped_line in ipairs(wrap_lines(line, cols - #level - 2)) do
        if isFirst then
          table.insert(lines, "  " .. wrapped_line)
        else
          table.insert(lines, string.rep(" ", #level + 4) .. wrapped_line)
        end
        isFirst = false
      end
    end
  end
  table.insert(lines, "")

  if _window_exists then
    vim.api.nvim_win_set_height(state.winid, #lines)
  else
    local win_options = {
      position = "bottom",
      relative = "win",
      size = #lines,
      win_options = {
        number = false,
        relativenumber = false,
        spell = false,
        list = false,
        signcolumn = "yes:1"
      },
      buf_options = {
        swapfile = false,
        undolevels = -1,
        filetype = "diagmsg"
      },
    }
    local win = NuiSplit(win_options)
    win:mount()
    state.winid = win.winid
    state.bufnr = win.bufnr
  end

  vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, true, lines)
end

return M
