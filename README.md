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
stack_box.notification({"this is a normal message"})
stack_box.notification({"this is an error message"}, 'error')
```

## List of Unimplemented Features:

- [ ] Stacking boxes automatically (it's stack-box after all!)
- [ ] Command for actively closing boxes
- [ ] Allow string type in args
- [ ] Add level 'warning'
