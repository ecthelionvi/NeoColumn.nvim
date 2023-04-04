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
local api = vim.api
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local user_cmd = vim.api.nvim_create_user_command

local config = {
  fg_color = '',
  bg_color = '',
  NeoColumn = '80',
  excluded_ft = {},
  always_on = false,
}

local BUFS_FILE = fn.stdpath('cache') .. "/neocolumn_bufs.json"

local function load_neocolumn_bufs()
  if fn.filereadable(BUFS_FILE) == 1 then
    local file_content = table.concat(fn.readfile(BUFS_FILE))
    local decoded_data = fn.json_decode(file_content)
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

local neocolumn_bufs = load_neocolumn_bufs()

NeoColumn.setup = function(user_settings)
  -- Merge user settings with default settings
  for k, v in pairs(user_settings) do
    config[k] = v
  end

  -- Toggle-NeoColumn
  user_cmd("ToggleNeoColumn", "lua require('NeoColumn').toggle_NeoColumn()", {})

  -- Clear-NeoColumnList
  user_cmd("ClearNeoColumn", "lua require('NeoColumn').clear_buf_list()", {})

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
  neocolumn_bufs[file_path] = not neocolumn_bufs[file_path]
  NeoColumn.save_neocolumn_bufs()
  NeoColumn.notify_NeoColumn()
  NeoColumn.apply_NeoColumn()
end

-- Notify-NeoColumn
function NeoColumn.notify_NeoColumn()
  if config.always_on then
    vim.notify("NeoColumn " .. (neocolumn_bufs[fn.expand('%:p')] and "Disabled" or "Enabled"))
  else
    vim.notify("NeoColumn " .. (neocolumn_bufs[fn.expand('%:p')] and "Enabled" or "Disabled"))
  end

  -- Clear the message area after 3 seconds (3000 milliseconds)
  vim.defer_fn(function()
    api.nvim_echo({ { '' } }, false, {})
  end, 3000)
end

-- Apply-NeoColumn
function NeoColumn.apply_NeoColumn()
  local ft = vim.bo.filetype
  local file_path = fn.expand('%:p')
  local NeoColumn_value = config.NeoColumn
  local match_id = pcall(api.nvim_buf_get_var(0, "NeoColumn_match_id"))
  local fg_color = (config.fg_color ~= '' and config.fg_color) or fn.synIDattr(fn.hlID("IncSearch"), "fg#")
  local bg_color = (config.bg_color ~= '' and config.bg_color) or fn.synIDattr(fn.hlID("IncSearch"), "bg#")

  if vim.bo.buftype == "terminal" or not vim.bo.modifiable then return end

  cmd("silent! highlight ColorColumn guifg=" .. fg_color .. " guibg=" .. bg_color)

  -- Get the match ID from the buffer variable
  if match_id then fn.matchdelete(match_id) end

  if not vim.tbl_contains(config.excluded_ft, ft) then
    if (config.always_on and not neocolumn_bufs[file_path]) or (not config.always_on and neocolumn_bufs[file_path]) then
      local new_match_id = fn.matchadd("ColorColumn", "\\%" .. NeoColumn_value .. "v.", 100)
      api.nvim_buf_set_var(0, "NeoColumn_match_id", new_match_id)
    end
  end
end

-- Save-neocolumn_bufs
function NeoColumn.save_neocolumn_bufs()
  local cache_dir = fn.stdpath('cache')
  if fn.isdirectory(cache_dir) == 0 then
    fn.mkdir(cache_dir, 'p')
  end

  local items = {}
  for k, v in pairs(neocolumn_bufs) do
    if v then
      table.insert(items, k)
    end
  end
  local json_data = fn.json_encode(items)
  fn.writefile({ json_data }, BUFS_FILE)
end

-- Clear-List
function NeoColumn.clear_buf_list()
  neocolumn_bufs = {}
  fn.clearmatches()
  NeoColumn.save_neocolumn_bufs()
end

return NeoColumn
