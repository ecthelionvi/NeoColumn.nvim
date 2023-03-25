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
  NeoColumn = '80',
}

local ENABLED_BUFS_FILE = vim.fn.stdpath('cache') .. "/neocolumn_enabled_bufs.json"

local function load_enabled_bufs()
  if vim.fn.filereadable(ENABLED_BUFS_FILE) == 1 then
    local file_content = table.concat(vim.fn.readfile(ENABLED_BUFS_FILE))
    local decoded_data = vim.fn.json_decode(file_content)
    local enabled = {}
    if decoded_data ~= nil then
      for _, filename in ipairs(decoded_data) do
        enabled[filename] = true
      end
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
  local file_path = fn.expand('%:p')
  enabled_bufs[file_path] = not enabled_bufs[file_path]
  NeoColumn.save_enabled_bufs()
  NeoColumn.notify_NeoColumn()
  NeoColumn.apply_NeoColumn()
end

-- Notify-NeoColumn
function NeoColumn.notify_NeoColumn()
  vim.notify("NeoColumn " .. (enabled_bufs[fn.expand('%:p')] and "Enabled" or "Disabled"))

  -- Clear the message area after 3 seconds (3000 milliseconds)
  vim.defer_fn(function()
    api.nvim_echo({ { '' } }, false, {})
  end, 3000)
end

-- Apply-NeoColumn
function NeoColumn.apply_NeoColumn()
  local file_path = fn.expand('%:p')
  local NeoColumn_value = config.NeoColumn
  local fg_color = vim.fn.synIDattr(vim.fn.hlID("IncSearch"), "fg#")
  local bg_color = vim.fn.synIDattr(vim.fn.hlID("IncSearch"), "bg#")

  cmd("silent! highlight ColorColumn guifg=" .. fg_color .. " guibg=" .. bg_color .. " | call clearmatches()")
  if enabled_bufs[file_path] then
    fn.matchadd("ColorColumn", "\\%" .. NeoColumn_value .. "v.", 100)
  end
end

-- Save-Enabled_Bufs
function NeoColumn.save_enabled_bufs()
  local cache_dir = vim.fn.stdpath('cache')
  if vim.fn.isdirectory(cache_dir) == 0 then
    vim.fn.mkdir(cache_dir, 'p')
  end

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
  vim.fn.clearmatches()
  NeoColumn.save_enabled_bufs()
end

return NeoColumn
