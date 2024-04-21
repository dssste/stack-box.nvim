local M = {}

local border_hl_groups = {
	error = "StackBoxBorderError",
	warning = "StackBoxBorderWarning",
	info = "StackBoxBorderNormal",
}

local hl_groups = {
	error = "ErrorMsg",
	warning = "WarningMsg",
	info = "Normal",
}

function M.setup()
	local function refresh_hl_groups()
		for level, hl_group in pairs(hl_groups) do
			local hl = vim.api.nvim_get_hl_by_name(hl_group, true)
			hl.underline = false
			vim.api.nvim_set_hl(0, border_hl_groups[level], hl)
		end
	end

	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = refresh_hl_groups,
	})

	refresh_hl_groups()
end

local windows = {}

local function split_lines(line)
	local result = {}
	for str in string.gmatch(line, "([^\r\n]*)\r?\n?") do
		if str ~= "" then
			table.insert(result, str)
		end
	end
	return result
end

local function prepare_messages(messages)
	if type(messages) == "string" then
		messages = {messages}
	end

	local result = {}
	for _, line in pairs(messages) do
		for _, part in pairs(split_lines(line)) do
			table.insert(result, part)
		end
	end
	return result
end

local function shift_windows()
	local lines = vim.api.nvim_get_option("lines")
	local offset = 0;
	for i = #windows, 1, -1 do
		local box = windows[i]
		if vim.api.nvim_win_is_valid(box.win) then
			local opts = vim.api.nvim_win_get_config(box.win)
			local win_height = opts.height
			opts.row = lines - offset - 2
			vim.api.nvim_win_set_config(box.win, opts)
			offset = offset + win_height + 2
		else
			table.remove(windows, i)
		end
	end
end

function M.notification(messages, level)
	messages = prepare_messages(messages)

	if not hl_groups[level] then
		level = "info"
	end

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
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_name(buf, "stack-box://" .. buf)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, messages)
	for i, _ in ipairs(messages) do
		vim.api.nvim_buf_add_highlight(buf, -1, hl_groups[level], i-1, 0, -1)
	end
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	local win = vim.api.nvim_open_win(buf, false, opts)

	vim.defer_fn(function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end, 3000)

	table.insert(windows, {win = win, buf = buf})
	shift_windows()

	return buf, win
end

function M.close_all_windows()
	for _, win in ipairs(windows) do
		if vim.api.nvim_win_is_valid(win.win) then
			vim.api.nvim_win_close(win.win, true)
		end
	end
	windows = {}
end

return M
