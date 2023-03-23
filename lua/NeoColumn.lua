--[[

 /$$   /$$                      /$$$$$$            /$$
| $$$ | $$                     /$$__  $$          | $$
| $$$$| $$  /$$$$$$   /$$$$$$ | $$  \__/  /$$$$$$ | $$ /$$   /$$ /$$$$$$/$$$$  /$$$$$$$
| $$ $$ $$ /$$__  $$ /$$__  $$| $$       /$$__  $$| $$| $$  | $$| $$_  $$_  $$| $$__  $$
| $$  $$$$| $$$$$$$$| $$  \ $$| $$      | $$  \ $$| $$| $$  | $$| $$ \ $$ \ $$| $$  \ $$
| $$\  $$$| $$_____/| $$  | $$| $$    $$| $$  | $$| $$| $$  | $$| $$ | $$ | $$| $$  | $$
| $$ \  $$|  $$$$$$$|  $$$$$$/|  $$$$$$/|  $$$$$$/| $$|  $$$$$$/| $$ | $$ | $$| $$  | $$
|__/  \__/ \_______/ \______/  \______/  \______/ |__/ \______/ |__/ |__/ |__/|__/  |__/

--]]
local M = {}
local fn = vim.fn
local cmd = vim.cmd
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local user_cmd = vim.api.nvim_create_user_command

local function load_enabled_bufs()
  local qflist = vim.fn.getqflist({title = 1})
  if qflist.title == "NeoColumnEnabledBufs" then
    return vim.fn.getqflist({items = 1}).items
  else
    return {}
  end
end

local enabled_bufs = load_enabled_bufs()

M.config = {
  notify = true,
  excluded_ft = {},
  NeoColumn = '80',
  custom_NeoColumn = {},
  fg_color = '#1a1b26',
  bg_color = '#ff9e64',
}

M.setup = function(user_settings)
  -- Merge user settings with default settings
  for k, v in pairs(user_settings) do
    M.config[k] = v
  end

  -- Toggle-NeoColumn
  user_cmd("ToggleNeoColumn", "lua require('NeoColumn').toggle_NeoColumn()", {})

  -- Clear-NeoColumnList
  user_cmd("ClearNeoColumnList", "lua require('NeoColumn').clear_enabled_list()", {})

  -- Apply-NeoColumn
  autocmd({ "BufEnter", "BufWinEnter" }, {
    group = augroup("apply-NeoColumn", { clear = true }),
    callback = function()
      vim.schedule(function()
        require("NeoColumn").apply_NeoColumn()
      end)
    end
  })
end

-- Toggle-NeoColumn
function M.toggle_NeoColumn()
  if M.excluded_bufs() then return end
  local file_path = fn.expand('%:p')
  enabled_bufs[file_path] = not enabled_bufs[file_path]
  M.save_enabled_bufs()
  if M.config.notify then
    M.notify_NeoColumn()
  end
  M.apply_NeoColumn()
end

-- Clear-Enabled-List
function M.clear_enabled_list()
  vim.fn.setqflist({}, 'r', {title = 'NeoColumnEnabledBufs'})
  enabled_bufs = {}
  if M.config.notify then
    vim.notify("NeoColumn enabled list cleared")
  end
end

-- Excluded-Buf
function M.excluded_bufs()
  local excluded_ft = M.config.excluded_ft
  return vim.tbl_contains(excluded_ft, vim.bo.filetype) or not vim.bo.modifiable
end

-- Notify-NeoColumn
function M.notify_NeoColumn()
  vim.notify("NeoColumn " .. (enabled_bufs[fn.expand('%:p')] and "Enabled" or "Disabled"))
end

-- Apply-NeoColumn
function M.apply_NeoColumn()
  local NeoColumn = M.config.NeoColumn
  local fg_color = M.config.fg_color
  local bg_color = M.config.bg_color
  local current_ft = vim.bo.filetype
  local file_path = fn.expand('%:p')

  if M.config.custom_NeoColumn[current_ft] then
    NeoColumn = M.config.custom_NeoColumn[current_ft]
  end

  cmd("silent! highlight ColorColumn guifg=" .. fg_color .. " guibg=" .. bg_color .. " | call clearmatches()")
  if not M.excluded_bufs() and enabled_bufs[file_path] then
    fn.matchadd("ColorColumn", "\\%" .. NeoColumn .. "v.", 100)
  end
end

-- Save-Enabled-Bufs
function M.save_enabled_bufs()
  local items = {}
  for k, v in pairs(enabled_bufs) do
    if v then
      table.insert(items, {filename = k})
    end
  end
  vim.fn.setqflist(items, 'r', {title = 'NeoColumnEnabledBufs'})
end

return M