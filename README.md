<h1 align="center"> pinbuff.nvim </h1>
<p align="center"><sup>✨ Buff your buffers navigation with pins 📌</sup></p>

<p align="center">
  <img src="https://github.com/neutrie/pinbuff.nvim/assets/52288594/f7c1e5c2-2243-4cb8-9369-2f404d5597f9" width="49%">
  <img src="https://github.com/neutrie/pinbuff.nvim/assets/52288594/91f16267-8416-40db-96e1-8a38e3ed2220" width="49%">
</p>

**pinbuff.nvim** is a lightweight plugin tailored for quick buffer navigation, leveraging the intuitive concept of *pinning*.

## ✨ Features
Essentially, the plugin provides a straightforward method for storing buffer handles (bufnr) in *slots* (inside lua table) and a method for jumping to bufnr stored in a slot. These actions are just wrappers for Neovim's API. <BR>
To put it simply, I press F1 - F4 for pinning the buffer in slots 1 - 4, and then I press Alt+1 - Alt+4 for jumping to those buffers.

## 📦 Installation
- With [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  "neutrie/pinbuff.nvim",
  config = function()
    require("pinbuff").setup()
  end
}
```

## 🚀 Usage
For getting the described keymaps
```lua
-- Slot can also be a string. I use integers 1 - 4 in this example.
vim.keymap.set("n", "<F1>", require("pinbuff").setter(1))
vim.keymap.set("n", "<F2>", require("pinbuff").setter(2))
vim.keymap.set("n", "<F3>", require("pinbuff").setter(3))
vim.keymap.set("n", "<F4>", require("pinbuff").setter(4))
vim.keymap.set("n", "<M-1>", require("pinbuff").jumper(1))
vim.keymap.set("n", "<M-2>", require("pinbuff").jumper(2))
vim.keymap.set("n", "<M-3>", require("pinbuff").jumper(3))
vim.keymap.set("n", "<M-4>", require("pinbuff").jumper(4))
```
Additionally, for getting the interactive floating window
```lua
vim.keymap.set("n", "<F5>", require("pinbuff").open_float)
```
### [Telescope](https://github.com/nvim-telescope/telescope.nvim) integration example
As you can see in the second gif, the buffers are pinned directly from [Telescope's](https://github.com/nvim-telescope/telescope.nvim) pickers. It is possible, because `require("pinbuff").setter()` has an optional second parameter, function `get_bufnr`. The default value is function `vim.api.nvim_get_current_buf`, which returns current buffer's bufnr. <BR>
Here is an example for Telescope's builtin pickers `Find Files` and `Buffers`
```lua
local function ff_bufload()
  local fname = require("telescope.actions.state").get_selected_entry()[1]
  local bufnr = vim.fn.bufadd(fname)
  vim.fn.bufload(bufnr)
  vim.api.nvim_set_option_value("buflisted", true, { buf = bufnr })
  return bufnr
end

local function bufs_get_bufnr()
  return require("telescope.actions.state").get_selected_entry().bufnr
end

require("telescope").setup({
  pickers = {
    find_files = {
      mappings = {
        i = {
          ["<F1>"] = require("pinbuff").setter(1, ff_bufload),
          ["<F2>"] = require("pinbuff").setter(2, ff_bufload),
          ["<F3>"] = require("pinbuff").setter(3, ff_bufload),
          ["<F4>"] = require("pinbuff").setter(4, ff_bufload),
        },
        n = {
          ["<F1>"] = require("pinbuff").setter(1, ff_bufload),
          ["<F2>"] = require("pinbuff").setter(2, ff_bufload),
          ["<F3>"] = require("pinbuff").setter(3, ff_bufload),
          ["<F4>"] = require("pinbuff").setter(4, ff_bufload),
        },
      },
    },
    buffers = {
      mappings = {
        i = {
          ["<F1>"] = require("pinbuff").setter(1, bufs_get_bufnr),
          ["<F2>"] = require("pinbuff").setter(2, bufs_get_bufnr),
          ["<F3>"] = require("pinbuff").setter(3, bufs_get_bufnr),
          ["<F4>"] = require("pinbuff").setter(4, bufs_get_bufnr),
        },
        n = {
          ["<F1>"] = require("pinbuff").setter(1, bufs_get_bufnr),
          ["<F2>"] = require("pinbuff").setter(2, bufs_get_bufnr),
          ["<F3>"] = require("pinbuff").setter(3, bufs_get_bufnr),
          ["<F4>"] = require("pinbuff").setter(4, bufs_get_bufnr),
        },
      },
    },
  },
})
```

Example for [File Browser](https://github.com/nvim-telescope/telescope-file-browser.nvim) extension
```lua
local function fb_bufload()
  local entry = require("telescope.actions.state").get_selected_entry()
  if entry.is_dir then
    return nil
  end
  local fname = entry[1]
  local bufnr = vim.fn.bufadd(fname)
  vim.fn.bufload(bufnr)
  vim.api.nvim_set_option_value("buflisted", true, { buf = bufnr })
  return bufnr
end

require("telescope").setup({
  extensions = {
    file_browser = {
      mappings = {
        i = {
          ["<F1>"] = require("pinbuff").setter(1, fb_bufload),
          ["<F2>"] = require("pinbuff").setter(2, fb_bufload),
          ["<F3>"] = require("pinbuff").setter(3, fb_bufload),
          ["<F4>"] = require("pinbuff").setter(4, fb_bufload),
        },
        n = {
          ["<F1>"] = require("pinbuff").setter(1, fb_bufload),
          ["<F2>"] = require("pinbuff").setter(2, fb_bufload),
          ["<F3>"] = require("pinbuff").setter(3, fb_bufload),
          ["<F4>"] = require("pinbuff").setter(4, fb_bufload),
        },
      },
    },
  },
})
```

### [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) integration example
As you can see in the gifs, pinned buffer's corresponding slot is displayed in the status line. It is achieved with `require("pinbuff").get_slot()` function. Here is an example
```lua
local function get_pinned_slot()
  local slot = require("pinbuff").get_slot(vim.api.nvim_get_current_buf())
  return slot and slot or ""
end

require("lualine").setup({
  sections = {
    -- ...
    lualine_c = {
      {
        "filename",
        padding = { left = 1, right = 0 },
      },
      {
        get_pinned_slot,
        color = "StatusLineNC",
        icon = "",
        padding = { left = 3, right = 1 },
      },
    },
    -- ...
})
```

## ⚙️ API
| Function                  | Description                                                                   |
|---------------------------|-------------------------------------------------------------------------------|
| `setter(slot, get_bufnr)` | Returns a function that calls `get_bufnr` and sets its value into the `slot`. |
| `jumper(slot)`            | Returns a function that jumps to the bufnr in the `slot`.                     |
| `open_float()`            | Opens an interactive floating window containing currently pinned buffers.     |
| `get_slot(bufnr)`         | Returns the `slot` of the `bufnr`. Ignores unloaded buffers.                  |
| `get_bufnr(slot)`         | Returns the `bufnr` in the `slot`. Ignores unloaded buffers.                  |

### Floating window actions
| Action          | Description                                                                                    |
|-----------------|------------------------------------------------------------------------------------------------|
| `close`         | Closes the window.                                                                             |
| `select`        | Jumps to the pinned buffer in the current line's slot.                                         |
| `clear_current` | Clears current line's slot.                                                                    |
| `clear_all`     | Clears all the slots.                                                                          |
| `swap_prev`     | Swaps pinned buffer in the current line's slot with pinned buffer in the previous line's slot. |
| `swap_next`     | Swaps pinned buffer in the current line's slot with pinned buffer in the next line's slot.     |

## 🔧 Configuration
**pinbuff.nvim** comes with the following defaults
```lua
{
  -- Returns a table of pairs `{str, hl}` to be displayed for the entry in the floating window.
  entry_line = function(slot, bufnr)
    local path_full = vim.api.nvim_buf_get_name(bufnr)
    local path_short = vim.fn.pathshorten(path_full, 2)
    local path_base = vim.fs.basename(path_full)
    local line = {
      { str = tostring(slot), hl = "PinBuffSlot" },
      { str = " -> ", hl = "PinBuffNonText" },
      { str = ("%3d: "):format(bufnr), hl = "PinBuffBufnr" },
      { str = ("%s "):format(path_base), hl = "PinBuffNormalFloat" },
      { str = ("(%s)"):format(path_short), hl = "PinBuffNonText" },
    }
    return line
  end,

  -- Returns a `{config}` map for `nvim_open_win()`
  float_config = function(entries_count)
    local min_width = 40
    local min_height = 5
    local c = {}
    c.width = vim.fn.max({ vim.fn.round(vim.o.columns / 2), min_width })
    c.height = vim.fn.max({ entries_count, min_height })
    c.col = (vim.o.columns / 2) - c.width / 2
    c.row = ((vim.o.lines - vim.o.cmdheight) / 2) - c.height / 2
    c.style = "minimal"
    c.border = "rounded"
    c.relative = "editor"
    c.anchor = "NW"
    c.noautocmd = true
    return c
  end,

  -- map of `{name}: {value}` pairs for `nvim_set_option_value()`
  buf_opts = {},

  -- map of `{name}: {value}` pairs for `nvim_set_option_value()`
  win_opts = {
    wrap = false,
    scrolloff = 0,
  },

  -- map of `{key}: {action}` pairs for interactive floating window
  -- Set the keymap to false to disable it, e.g. `["<ESC>"] = false`
  float_keymaps = {
    ["<CR>"] = "select",
    ["q"] = "close",
    ["Q"] = "close",
    ["<ESC>"] = "close",
    ["<C-c>"] = "close",
    ["x"] = "clear_current",
    ["X"] = "clear_all",
    ["K"] = "swap_prev",
    ["<M-k>"] = "swap_prev",
    ["J"] = "swap_next",
    ["<M-j>"] = "swap_next",
  },
}
```

### Custom `entry_line` example
Make floating window pretty with Nerd Fonts
| Before | After |
|--------|-------|
| ![before](https://github.com/neutrie/pinbuff.nvim/assets/52288594/77f476c4-9415-4509-8986-f177cd06fa89) | ![after](https://github.com/neutrie/pinbuff.nvim/assets/52288594/b3946d45-565d-415f-9b9b-0281d048b6b4) |

This example uses [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) and [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
```lua
require("pinbuff").setup({
  win_opts = { winhl = "NormalFloat:Normal" }, -- to match border's bg
  entry_line = function(slot, bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    local filename = vim.fs.basename(path)
    local dir_rel = require("plenary.path")
      :new(vim.fs.dirname(path))
      :make_relative(vim.fn.getcwd()) .. "/"
    local icon, icon_hl = require("nvim-web-devicons").get_icon(path)
    local line = {
      { str = "• ", hl = "PinBuffNonText" },
      { str = (" %s  "):format(tostring(slot)), hl = "PinBuffSlot" },
      { str = ("󰯂 %3d   "):format(bufnr), hl = "PinBuffBufnr" },
      icon and { str = icon .. " ", hl = icon_hl } or {},
      { str = dir_rel, hl = "PinBuffNonText" },
      { str = filename, hl = "PinBuffNormalFloat" },
    }
    return line
  end
})
```

## 🌈 Highlight groups
These groups are used to highlight entries inside the floating window
| Highlight            | Description               |
|----------------------|---------------------------|
| `PinBuffNormalFloat` | Links to `NormalFloat`    |
| `PinBuffNonText`     | Links to `NonText`        |
| `PinBuffSlot`        | Links to `Keyword`        |
| `PinBuffBufnr`       | Links to `PinBuffNonText` |
