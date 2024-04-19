local M = {}

function M.setup()
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = function()
			local errorMsg = vim.api.nvim_get_hl_by_name("ErrorMsg", true)
			errorMsg.underline = false
			vim.api.nvim_set_hl(0, "DapiErrorMsg", errorMsg)
			local normal = vim.api.nvim_get_hl_by_name("Normal", true)
			normal.underline = false
			vim.api.nvim_set_hl(0, "DapiNormal", normal)
		end
	})
end

local border_hl_groups = {
	error = "DapiErrorMsg",
	info = "DapiNormal",
}

local hl_groups = {
	error = "ErrorMsg",
	info = "Normal",
}

function M.notification(messages, level)
	level = level or "info"

	local win_height = #messages
	if win_height <= 0 then
		return
	end
	local max_width = 0
	for _, line in ipairs(messages) do
		max_width = math.max(max_width, #line)
	end
	local win_width = max_width
	if win_width <= 0 then
		return
	end

	local border_hl_group = border_hl_groups[level]
	local opts = {
		anchor = "SE",
		relative = "editor",
		style = "minimal",
		width = win_width,
		height = win_height,
		row = vim.api.nvim_get_option("lines") - 2,
		col = vim.api.nvim_get_option("columns") - 4,
		border = {
			{"╭", border_hl_group},
			{"─", border_hl_group},
			{"╮", border_hl_group},
			{"│", border_hl_group},
			{"╯", border_hl_group},
			{"─", border_hl_group},
			{"╰", border_hl_group},
			{"│", border_hl_group}
		},
	}

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, messages)
	for i, _ in ipairs(messages) do
		vim.api.nvim_buf_add_highlight(buf, -1, hl_groups[level], i-1, 0, -1)
	end
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)

	local win = vim.api.nvim_open_win(buf, false, opts)

	vim.defer_fn(function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end, 3000)
	return buf, win
end

return M
