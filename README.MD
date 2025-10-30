# micro-motion.nvim

Micro Motion is a lightweight NeoVim plugin that replicates the **word navigation behavior** of the [Micro Editor](https://micro-editor.github.io/).

This plugin redefines `<C-Left>` and `<C-Right>` to move through words in a way that matches Micro’s intuitive word-jumping logic.


## Features

- Lightweight and dependency-free  
- Better word navigation in all modes (Normal, Insert, Visual)  
- Clean Lua implementation

---

## Installation

### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "hashylog/micro-motion.nvim",
  config = function()
    require("micro-motion").setup()
  end
}
```

### Using [Packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "hashylog/micro-motion.nvim",
  config = function()
    require("micro-motion").setup()
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

---

## Customization

All mappings are defined inside `setup()`.
If you want to disable or remap them, you can override the mappings in your config file after calling `setup()`:

```lua
require("micro_motion").setup()

-- Example: remap Ctrl+Arrow keys
vim.keymap.set("n", "<A-Right>", require("micro_motion").word_right)
vim.keymap.set("n", "<A-Left>",  require("micro_motion").word_left)
```
