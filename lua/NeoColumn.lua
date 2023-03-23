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
local NeoColumn = {}

local fn = vim.fn
local cmd = vim.cmd
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local user_cmd = vim.api.nvim_create_user_command

local config = {
  notify = true,
  excluded_ft = {},
  NeoColumn = '80',
  custom_NeoColumn = {},
  fg_color = '#1a1b26',
  bg_color = '#ff9e64',
}

local ENABLED_BUFS_FILE = vim.fn.stdpath('cache') .. "/neocolumn_enabled_bufs.json"

local function create_config_dir()
  local cache_dir = vim.fn.stdpath('cache')
  if vim.fn.isdirectory(cache_dir) == 0 then
    vim.fn.mkdir(cache_dir, 'p')
  end
end

local function load_enabled_bufs()
  if vim.fn.filereadable(ENABLED_BUFS_FILE) == 1 then
    local file_content = table.concat(vim.fn.readfile(ENABLED_BUFS_FILE))
    local decoded_data = vim.fn.json_decode(file_content)
    local enabled = {}
    for _, filename in ipairs(decoded_data) do
      enabled[filename] = true
    end
    return enabled
  else
    return {}
  end
end

local enabled_bufs = load_enabled_bufs()

NeoColumn.setup = function(user_settings)
  -- Merge user settings with default settings
  for k, v in pairs(user_settings) do
    config[k] = v
  end

  -- Toggle-NeoColumn
  user_cmd("ToggleNeoColumn", "lua require('NeoColumn').toggle_NeoColumn()", {})

  -- Clear-NeoColumnList
  user_cmd("ClearNeoColumn", "lua require('NeoColumn').clear_enabled_list()", {})

  -- Apply-NeoColumn
  autocmd({ "BufEnter", "BufWinEnter" }, {
    group = augroup("apply-NeoColumn", { clear = true }),
    callback = function()
      vim.schedule(function()
        NeoColumn.apply_NeoColumn()
      end)
    end
  })
end

-- Toggle-NeoColumn
function NeoColumn.toggle_NeoColumn()
  if NeoColumn.excluded_bufs() then return end
  local file_path = fn.expand('%:p')
  enabled_bufs[file_path] = not enabled_bufs[file_path]
  NeoColumn.save_enabled_bufs()
  if config.notify then
    NeoColumn.notify_NeoColumn()
  end
  NeoColumn.apply_NeoColumn()
end

-- Excluded-Buf
function NeoColumn.excluded_bufs()
  local excluded_ft = config.excluded_ft
  return vim.tbl_contains(excluded_ft, vim.bo.filetype) or not vim.bo.modifiable
end

-- Notify-NeoColumn
function NeoColumn.notify_NeoColumn()
  vim.notify("NeoColumn " .. (enabled_bufs[fn.expand('%:p')] and "Enabled" or "Disabled"))
end

-- Apply-NeoColumn
function NeoColumn.apply_NeoColumn()
  local NeoColumn_value = config.NeoColumn
  local fg_color = config.fg_color
  local bg_color = config.bg_color
  local current_ft = vim.bo.filetype
  local file_path = fn.expand('%:p')

  if config.custom_NeoColumn[current_ft] then
    NeoColumn_value = config.custom_NeoColumn[current_ft]
  end

  cmd("silent! highlight ColorColumn guifg=" .. fg_color .. " guibg=" .. bg_color .. " | call clearmatches()")
  if not NeoColumn.excluded_bufs() and enabled_bufs[file_path] then
    fn.matchadd("ColorColumn", "\\%" .. NeoColumn_value .. "v.", 100)
  end
end

-- Save-Enabled_Bufs
function NeoColumn.save_enabled_bufs()
  create_config_dir()
  local items = {}
  for k, v in pairs(enabled_bufs) do
    if v then
      table.insert(items, k)
    end
  end
  local json_data = vim.fn.json_encode(items)
  vim.fn.writefile({ json_data }, ENABLED_BUFS_FILE)
end

-- Clear-List
function NeoColumn.clear_enabled_list()
  enabled_bufs = {}
  NeoColumn.save_enabled_bufs()
end

return NeoColumn
