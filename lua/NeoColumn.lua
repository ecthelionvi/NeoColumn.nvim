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
  fg_color = "",
  bg_color = "",
  NeoColumn = "80",
  always_on = false,
  custom_NeoColumn = {},
  excluded_ft = { "text", "markdown" },
}

local NEOCOLUMN_DIR = fn.stdpath("cache") .. "/NeoColumn"
local BUFS_FILE = NEOCOLUMN_DIR .. "/neocolumn_bufs.json"
fn.mkdir(NEOCOLUMN_DIR, "p")

local function load_neocolumn()
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

local neocolumn_bufs = load_neocolumn()

NeoColumn.setup = function(user_settings)
  if vim.g.neocolumn_setup then
    return
  end

  vim.g.neocolumn_setup = true
  user_settings = user_settings or {}
  for k, v in pairs(user_settings) do
    config[k] = v
  end

  autocmd({ "Filetype", "BufEnter", "BufWinEnter" }, {
    group = augroup("apply-NeoColumn", { clear = true }),
    callback = function()
      pcall(function() NeoColumn.apply_neocolumn() end)
    end
  })

  user_cmd("ClearNeoColumn", "lua require('NeoColumn').clear_neocolumn()", {})

  user_cmd("ToggleNeoColumn", "lua require('NeoColumn').toggle_neocolumn()", {})
end

function NeoColumn.clear_neocolumn()
  fn.clearmatches()
  neocolumn_bufs = {}
  if fn.filereadable(BUFS_FILE) == 1 then
    fn.delete(BUFS_FILE)
  end

  NeoColumn.notify_neocolumn(true)
end

function NeoColumn.save_neocolumn()
  local items = {}
  for k, v in pairs(neocolumn_bufs) do
    if v then
      table.insert(items, k)
    end
  end
  local json_data = fn.json_encode(items)
  fn.writefile({ json_data }, BUFS_FILE)
end

function NeoColumn.valid_buffer()
  local buftype = vim.bo.buftype
  local disabled = { "help", "prompt", "nofile", "terminal" }
  if not vim.tbl_contains(disabled, buftype) then return true end
end

function NeoColumn.toggle_neocolumn()
  local filetype = vim.bo.filetype
  local file_path = fn.expand('%:p')
  local excluded_ft = config.excluded_ft
  if vim.tbl_contains(excluded_ft, filetype) or not NeoColumn.valid_buffer() then return end
  neocolumn_bufs[file_path] = not neocolumn_bufs[file_path]
  NeoColumn.save_neocolumn()
  NeoColumn.notify_neocolumn()
  NeoColumn.apply_neocolumn()
end

function NeoColumn.apply_neocolumn()
  local filetype = vim.bo.filetype
  local file_path = fn.expand("%:p")
  local always_on = config.always_on
  local excluded_ft = config.excluded_ft
  local NeoColumn_value = type(config.NeoColumn) == "string" and { config.NeoColumn } or config.NeoColumn
  local fg_color = (config.fg_color ~= "" and config.fg_color) or fn.synIDattr(fn.hlID("IncSearch"), "fg#")
  local bg_color = (config.bg_color ~= "" and config.bg_color) or fn.synIDattr(fn.hlID("IncSearch"), "bg#")

  fn.clearmatches()

  if not NeoColumn.valid_buffer() then return end

  if not vim.tbl_contains(excluded_ft, filetype) then
    if (always_on and not neocolumn_bufs[file_path]) or (not always_on and neocolumn_bufs[file_path]) then
      cmd("silent! highlight ColorColumn guifg=" .. fg_color .. " guibg=" .. bg_color)
      if config.custom_NeoColumn[filetype] then
        for _, v in ipairs(config.custom_NeoColumn[filetype]) do
          fn.matchadd("ColorColumn", "\\%" .. v .. "v.", 100)
        end
      else
        for _, v in ipairs(NeoColumn_value) do
          fn.matchadd("ColorColumn", "\\%" .. v .. "v.", 100)
        end
      end
    end
  end
end

function NeoColumn.notify_neocolumn(clear)
  local timer = vim.loop.new_timer()
  local always_on = config.always_on
  if clear then
    vim.notify("NeoColumn Data Cleared")
  else
    vim.notify("NeoColumn " .. ((always_on ~= neocolumn_bufs[fn.expand('%:p')]) and "Enabled" or "Disabled"))
  end

  if timer then
    timer:start(3000, 0, vim.schedule_wrap(function()
      vim.cmd("echo ''")

      timer:stop()
      timer:close()
    end))
  end
end

return NeoColumn
