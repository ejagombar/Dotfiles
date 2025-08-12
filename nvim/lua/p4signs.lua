-- p4signs.nvim - Perforce diff signs for Neovim
-- Place this file in ~/.config/nvim/lua/p4signs.lua or as a plugin

local M = {}

-- Plugin configuration
M.config = {
	signs = {
		add = { text = "┃", hl = "P4SignsAdd" },
		change = { text = "┃", hl = "P4SignsChange" },
		delete = { text = "▁", hl = "P4SignsDelete" },
	},
	highlights = {
		add = { fg = "#587c0c", bold = true },
		change = { fg = "#0c7d9d", bold = true },
		delete = { fg = "#94151b", bold = true },
	},
	auto_update = true,
	update_debounce = 300, -- ms
}

-- Internal state
local ns_id = vim.api.nvim_create_namespace("p4signs")
local sign_group = "p4signs"
local buffers = {}
local timers = {}

-- Sign definitions
local function define_signs()
	-- Define highlight groups
	vim.api.nvim_set_hl(0, "P4SignsAdd", M.config.highlights.add)
	vim.api.nvim_set_hl(0, "P4SignsChange", M.config.highlights.change)
	vim.api.nvim_set_hl(0, "P4SignsDelete", M.config.highlights.delete)

	for sign_type, sign_config in pairs(M.config.signs) do
		vim.fn.sign_define("P4Signs" .. sign_type:gsub("^%l", string.upper), {
			text = sign_config.text,
			texthl = sign_config.hl,
		})
	end
end

-- Parse classic diff format (like your p4 output)
local function parse_classic_diff(diff_output, current_filepath)
	local changes = {}
	changes[current_filepath] = {}

	for line in diff_output:gmatch("[^\r\n]+") do
		-- Skip file headers and content lines
		if line:match("^====") or line:match("^%-%-%-") or line:match("^[<>]") then
			goto continue
		end

		-- Parse different change types
		-- Format examples:
		-- 4d3 - delete line 4 from old, affects line 3 in new
		-- 9a9,10 - add lines 9-10 to new file after line 9 in old
		-- 20c28 - change line 20 in old to line 28 in new
		-- 22,23c30 - change lines 22-23 in old to line 30 in new

		if line:match("^%d+[acd]") then
			if line:match("d") then
				-- Deletion: NdM means delete line N from old file, affects position M in new
				local old_line, new_pos = line:match("^(%d+)d(%d+)")
				if old_line and new_pos then
					new_pos = tonumber(new_pos)
					table.insert(changes[current_filepath], {
						type = "delete",
						line = new_pos,
					})
				end
			elseif line:match("a") then
				-- Addition: NaM,L means add lines M through L after line N in old
				local after_line, start_new, end_new = line:match("^(%d+)a(%d+),?(%d*)")
				start_new = tonumber(start_new)
				end_new = end_new ~= "" and tonumber(end_new) or start_new

				-- Mark all added lines in the new file
				for i = start_new, end_new do
					table.insert(changes[current_filepath], {
						type = "add",
						line = i,
					})
				end
			elseif line:match("c") then
				-- Change: N,McL,M means change lines N-M in old to lines L-M in new
				local old_start, old_end, new_start, new_end = line:match("^(%d+),?(%d*)c(%d+),?(%d*)")
				new_start = tonumber(new_start)
				new_end = new_end ~= "" and tonumber(new_end) or new_start

				-- Mark all changed lines in the new file
				for i = new_start, new_end do
					table.insert(changes[current_filepath], {
						type = "change",
						line = i,
					})
				end
			end
		end

		::continue::
	end

	return changes
end

-- Parse p4 diff output (handles both unified and classic formats)
local function parse_p4_diff(diff_output, current_filepath)
	local changes = {}

	-- Check if this is unified diff format (has @@ headers)
	if diff_output:match("@@") then
		-- Use unified diff parsing
		local old_line, new_line = 1, 1
		local current_file = nil

		for line in diff_output:gmatch("[^\r\n]+") do
			local file_match = line:match("^====.*%- (.+) ====")
			if file_match then
				current_file = vim.fn.fnamemodify(file_match, ":p")
				changes[current_file] = {}
			elseif line:match("^@@") then
				local old_start, new_start = line:match("@@%s*%-(%d+),%d*%s*%+(%d+),%d*%s*@@")
				old_line = tonumber(old_start) or 1
				new_line = tonumber(new_start) or 1
			elseif current_file and line:len() > 0 then
				local first_char = line:sub(1, 1)

				if first_char == "+" and not line:match("^%+%+%+") then
					table.insert(changes[current_file], {
						type = "add",
						line = new_line,
					})
					new_line = new_line + 1
				elseif first_char == "-" and not line:match("^%-%-%-") then
					table.insert(changes[current_file], {
						type = "delete",
						line = new_line,
					})
					old_line = old_line + 1
				elseif first_char == " " then
					old_line = old_line + 1
					new_line = new_line + 1
				end
			end
		end
	else
		-- Use classic diff parsing for your format
		changes = parse_classic_diff(diff_output, current_filepath)
	end

	return changes
end

-- Apply signs to buffer
local function apply_signs(bufnr, changes)
	if not changes then
		return
	end

	vim.fn.sign_unplace(sign_group, { buffer = bufnr })

	for i, change in ipairs(changes) do
		local line_num = change.line
		if change.type == "delete" then
			line_num = math.max(1, change.line)
		end

		if line_num > 0 then
			local sign_name = "P4Signs" .. change.type:gsub("^%l", string.upper)
			vim.fn.sign_place(0, sign_group, sign_name, bufnr, {
				lnum = line_num,
				priority = 10,
			})
		end
	end
end

-- Check if file is under Perforce control
local function is_p4_file(filepath)
	if not filepath or filepath == "" then
		return false
	end

	-- Real p4 check
	local handle = io.popen('p4 fstat "' .. filepath .. '" 2>/dev/null')
	if not handle then
		return false
	end

	local result = handle:read("*a")
	handle:close()

	return result:match("clientFile") ~= nil
end

-- Get p4 diff for file
local function get_p4_diff(filepath)
	if not is_p4_file(filepath) then
		return nil
	end

	-- Use unified diff format with -u flag (falls back to classic if -u not supported)
	local cmd = 'p4 diff -u "' .. filepath .. '" 2>/dev/null'
	local handle = io.popen(cmd)
	if not handle then
		return nil
	end

	local diff_output = handle:read("*a")
	handle:close()

	-- If unified diff failed or returned empty, try classic diff
	if diff_output == "" or not diff_output:match("@@") then
		cmd = 'p4 diff "' .. filepath .. '" 2>/dev/null'
		handle = io.popen(cmd)
		if not handle then
			return nil
		end

		diff_output = handle:read("*a")
		handle:close()
	end

	if diff_output == "" then
		return nil
	end

	return diff_output
end

-- Update signs for buffer
local function update_buffer_signs(bufnr)
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	if not filepath or filepath == "" then
		return
	end

	if not is_p4_file(filepath) then
		return
	end

	local diff_output = get_p4_diff(filepath)
	if not diff_output then
		vim.fn.sign_unplace(sign_group, { buffer = bufnr })
		buffers[bufnr] = nil
		return
	end

	local changes = parse_p4_diff(diff_output, filepath)
	local file_changes = changes[filepath]

	if file_changes and #file_changes > 0 then
		apply_signs(bufnr, file_changes)
		buffers[bufnr] = true
	end
end

-- Debounced update function
local function debounced_update(bufnr)
	if timers[bufnr] then
		vim.fn.timer_stop(timers[bufnr])
	end

	timers[bufnr] = vim.fn.timer_start(M.config.update_debounce, function()
		update_buffer_signs(bufnr)
		timers[bufnr] = nil
	end)
end

-- Setup autocommands
local function setup_autocommands()
	local group = vim.api.nvim_create_augroup("P4Signs", { clear = true })

	-- Update on file read/write
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
		group = group,
		callback = function(args)
			if M.config.auto_update then
				update_buffer_signs(args.buf)
			end
		end,
	})

	-- Update on text change (debounced)
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = group,
		callback = function(args)
			if M.config.auto_update and buffers[args.buf] then
				debounced_update(args.buf)
			end
		end,
	})

	-- Clean up on buffer delete
	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		callback = function(args)
			buffers[args.buf] = nil
			if timers[args.buf] then
				vim.fn.timer_stop(timers[args.buf])
				timers[args.buf] = nil
			end
		end,
	})
end

-- Public API
function M.setup(opts)
	-- Merge config
	if opts then
		M.config = vim.tbl_deep_extend("force", M.config, opts)
	end

	-- Define signs
	define_signs()

	-- Setup autocommands
	setup_autocommands()

	-- Create user commands
	vim.api.nvim_create_user_command("P4SignsRefresh", function()
		local bufnr = vim.api.nvim_get_current_buf()
		update_buffer_signs(bufnr)
	end, { desc = "Refresh P4 signs for current buffer" })

	vim.api.nvim_create_user_command("P4SignsDebug", function()
		local bufnr = vim.api.nvim_get_current_buf()
		local filepath = vim.api.nvim_buf_get_name(bufnr)
		print("P4Signs Debug Info:")
		print("  Buffer: " .. bufnr)
		print("  File: " .. (filepath or "none"))
		print("  Is P4 file: " .. tostring(is_p4_file(filepath)))
		print("  Auto update: " .. tostring(M.config.auto_update))

		local diff = get_p4_diff(filepath)
		if diff then
			print("  Diff output length: " .. #diff)
			print("  First 200 chars: " .. diff:sub(1, 200))
		else
			print("  No diff output")
		end
	end, { desc = "Show P4Signs debug information" })

	vim.api.nvim_create_user_command("P4SignsToggle", function()
		M.config.auto_update = not M.config.auto_update
		if M.config.auto_update then
			local bufnr = vim.api.nvim_get_current_buf()
			update_buffer_signs(bufnr)
			print("P4Signs enabled")
		else
			print("P4Signs disabled")
		end
	end, { desc = "Toggle P4Signs auto-update" })

	vim.api.nvim_create_user_command("P4SignsClear", function()
		local bufnr = vim.api.nvim_get_current_buf()
		vim.fn.sign_unplace(sign_group, { buffer = bufnr })
		buffers[bufnr] = nil
	end, { desc = "Clear P4 signs for current buffer" })
end

-- Manual refresh function
function M.refresh()
	local bufnr = vim.api.nvim_get_current_buf()
	update_buffer_signs(bufnr)
end

-- Enable/disable
function M.enable()
	M.config.auto_update = true
end

function M.disable()
	M.config.auto_update = false
end

-- Get status for statusline
function M.get_status()
	local bufnr = vim.api.nvim_get_current_buf()
	return buffers[bufnr] and "P4" or ""
end

return M
