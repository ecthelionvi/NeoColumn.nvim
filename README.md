<h1 align="center">
NeoColumn.nvim
</h1>

<p align="center">
  <a href="https://github.com/ecthelionvi/NeoColumn/stargazers">
    <img
      alt="Stargazers"
      src="https://img.shields.io/github/stars/ecthelionvi/NeoColumn?style=for-the-badge&logo=starship&color=fae3b0&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
  <a href="https://github.com/ecthelionvi/NeoColumn/issues">
    <img
      alt="Issues"
      src="https://img.shields.io/github/issues/ecthelionvi/NeoColumn?style=for-the-badge&logo=gitbook&color=ddb6f2&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
  <a href="https://github.com/ecthelionvi/NeoColumn/contributors">
    <img
      alt="Contributors"
      src="https://img.shields.io/github/contributors/ecthelionvi/NeoColumn?style=for-the-badge&logo=opensourceinitiative&color=abe9b3&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
</p>

![demo](https://raw.githubusercontent.com/ecthelionvi/images/main/NeoColumn.gif)

## 📃 Introduction

A Neovim plugin that displays a focused ColorColumn at a specific character position to help users maintain a certain line length. 
Unlike the standard ColorColumn, this plugin highlights individual characters at the specified column, 
reducing visual clutter and making it easier to identify longer lines. 
This approach improves readability and helps adhere to coding standards or preferred line lengths.

## ⚙️ Features

- NeoColumn is hidden by default and appears when a line in the scope exceeds the NeoColumn value you set.
- Set custom NeoColumn value for different file types.
- Hide NeoColumn for specific file types.
- Toggle NeoColumn on and off.

## 🔄 Persistence

NeoColumn saves the state of the buffer and ColorColumn automatically. When you open or close buffers, the plugin will remember the ColorColumn settings, including its visibility and position, for each buffer.

## 🎛️ Usage

To toggle NeoColumn on and off, you can use the `ToggleNeoColumn` command:

```vim
:ToggleNeoColumn
```
This command will turn NeoColumn on if it's currently off, and vice versa.

You can also create a keybinding to toggle NeoColumn more conveniently:

```lua
vim.keymap.set("n", "<leader>h", "<cmd>ToggleNeoColumn<cr>", { noremap = true, silent = true })
```

## 📦 Installation

1. Install via your favorite package manager.

- [lazy.nvim](https://github.com/folke/lazy.nvim)
```Lua
{
  "ecthelionvi/NeoColumn.nvim",
  opts = {}
},
```

- [packer.nvim](https://github.com/wbthomason/packer.nvim)
```Lua
use "ecthelionvi/NeoColumn.nvim"
```

- [vim-plug](https://github.com/junegunn/vim-plug)
```VimL
Plug "ecthelionvi/NeoColumn.nvim"
```

2. Setup the plugin in your `init.lua`. This step is not needed with lazy.nvim if `opts` is set as above.
```Lua
require("NeoColumn").setup()
```

## 🔧 Configuration

You can pass your config table into the `setup()` function or `opts` if you use lazy.nvim.

The available options:

- `NeoColumn` (string) : the character position at which the ColorColumn appears
  - `"80"` (default)
- `excluded_ft` (table of strings) : the ColorColumn will be disabled for the file types in this table
  - `{}` (default)
  - Example:`{ "help", "text", "markdown" }`
- `custom_NeoColumn` (table): custom NeoColumn values for different file types
  - `{}` (default)
  - Example: `{ ruby = "120", java = "180" }`
- `fg_color`(string) : the foreground color of the ColorColumn
  - `'#1a1b26'` (default)
- `bg_color`(string) : the background color of the ColorColumn
  - `'#ff9e64'` (default)
- `notify` (boolean) : whether to show a notification when toggling the ColorColumn
  - `true` (default)

### Default config

```Lua
local config = {
   NeoColumn = "80",
   excluded_ft = {},
   custom_NeoColumn = {},
   fg_color = '#1a1b26',
   bg_color = '#ff9e64',
   notify = true,
}
```
