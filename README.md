# stack-box.nvim

Popup notification vscode style.

## Installation

<details>
	<summary><a href="https://github.com/wbthomason/packer.nvim">Packer.nvim</a></summary>

```lua
use {
    "dssste/stack-box.nvim",
    config = function()
        require("stack-box").setup()
    end,
}
```

</details>

## Usage

```lua
local stack_box = require('stack-box')
stack_box.notification("this is a normal message")
stack_box.notification({"this is a normal message", "with two lines"})
stack_box.notification("this is an warning message", "warning")
stack_box.notification("this is an error message", "error")
```

For example when you keep pressing the wrong buttons:

```lua
vim.keymap.set("n", "<leader>gg", function ()
    require('stack-box').notification({"git status command remapped to <c-g>"}, 'error')
end)
```


And to close all boxes:

```lua
require("stack-box").close_all_windows()
```
