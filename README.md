<h1 align="center">
🌈 NeoColumn.nvim
</h1>

<p align="center">
  <a href="http://www.lua.org">
    <img
      alt="Lua"
      src="https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua"
    />
  </a>
  <a href="https://neovim.io/">
    <img
      alt="Neovim"
      src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white"
    />
  </a>
</p>

![demo](https://raw.githubusercontent.com/ecthelionvi/Images/main/NeoColumn.gif)

## 📢 Introduction

NeoColumn is a Neovim plugin that shows a focused ColorColumn at a specific position to manage line length. It highlights individual characters, minimizing clutter and enhancing readability

## ✨ Features

- Displays a focused ColorColumn at the desired position
- Toggle NeoColumn on and off

## 💾 Persistence

NeoColumn maintains the ColorColumn settings for each file, including visibility and position, across sessions.

## 🛠️ Usage

To toggle NeoColumn on and off, you can use the `ToggleNeoColumn` command:

```vim
:ToggleNeoColumn
```
You can also create a keybinding to toggle NeoColumn more conveniently:

```lua
vim.keymap.set("n", "<leader>h", "<cmd>ToggleNeoColumn<cr>", { noremap = true, silent = true })
```

To clear the list of enabled files in NeoColumn, you can use the `ClearNeoColumn` command:

```vim
:ClearNeoColumn
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

2. Setup the plugin in your `init.lua`. This step is not needed with lazy.nvim if `opts` is set as above.
```Lua
require("NeoColumn").setup()
```

## 🔧 Configuration

You can pass your config table into the `setup()` function or `opts` if you use lazy.nvim.

The available options:

- `NeoColumn` (string) : the character position at which the ColorColumn appears
  - `"80"` (default)

### Default Config

```Lua
local config = {
  NeoColumn = "80",
}
```
