# micro-motion.nvim

A lightweight Neovim plugin that replicates the **word navigation behavior** of the [Micro Editor](https://micro-editor.github.io/).

This plugin redefines `<C-Left>` and `<C-Right>` to move through words in a way that matches Micro’s intuitive word-jumping logic — including support for underscores, punctuation, and whitespace handling similar to Micro.

---

## Features

- Lightweight and dependency-free  
- Micro-style word navigation in all modes (Normal, Insert, Visual)  
- Key mappings for both movement and selection (`<C-S-Left>` / `<C-S-Right>`)  
- Clean Lua implementation with no external dependencies

---

## Installation

### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "hashylog/micro-motion.nvim",
  config = function()
    require("micro_motion").setup()
  end
}
```

### Using [Packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "hashylog/micro-motion.nvim",
  config = function()
    require("micro_motion").setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'hashylog/micro-motion.nvim'
```

Then in your `init.lua` or `init.vim`:

```lua
require("micro_motion").setup()
```

---

## Default Keymaps

| Mode   | Shortcut      | Action                        |
| ------ | ------------- | ----------------------------- |
| Normal | `<C-Right>`   | Move word right (Micro-style) |
| Normal | `<C-Left>`    | Move word left (Micro-style)  |
| Insert | `<C-Right>`   | Move word right (Micro-style) |
| Insert | `<C-Left>`    | Move word left (Micro-style)  |
| Visual | `<C-Right>`   | Extend selection right        |
| Visual | `<C-Left>`    | Extend selection left         |
| Normal | `<C-S-Right>` | Select word right             |
| Normal | `<C-S-Left>`  | Select word left              |

---

## Customization

All mappings are defined inside `setup()`.
If you want to disable or remap them, you can override the mappings in your config file **after** calling `setup()`:

```lua
require("micro_motion").setup()

-- Example: remap Ctrl+Arrow keys
vim.keymap.set("n", "<A-Right>", require("micro_motion").word_right)
vim.keymap.set("n", "<A-Left>",  require("micro_motion").word_left)
```

---

## How It Works

`micro-motion.nvim` reproduces Micro’s logic for word motion:

* Words include letters, digits, and underscores (`[A-Za-z0-9_]`).
* Non-word symbols are handled as separate navigation blocks.
* Whitespace and punctuation boundaries are treated distinctly — just like in Micro.
