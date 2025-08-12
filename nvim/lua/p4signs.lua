local M = {}

-- Plugin configuration
M.config = {
	signs = {
		add = { text = "▎", hl = "P4SignsAdd" },
		change = { text = "▎", hl = "P4SignsChange" },
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
	-- Define highlight groups with force=true to override colorscheme
	vim.api.nvim_set_hl(0, "P4SignsAdd", vim.tbl_extend("force", M.config.highlights.add, { force = true }))
	vim.api.nvim_set_hl(0, "P4SignsChange", vim.tbl_extend("force", M.config.highlights.change, { force = true }))
	vim.api.nvim_set_hl(0, "P4SignsDelete", vim.tbl_extend("force", M.config.highlights.delete, { force = true }))

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

		if line:match("^%d+[acd]") or line:match("^%d+,%d+[acd]") then
			if line:match("d") then
				-- Deletion: NdM or N,LdM means delete line(s) N(-L) from old file, affects position M in new
				local old_start, old_end, new_pos = line:match("^(%d+),?(%d*)d(%d+)")
				if old_start and new_pos then
					new_pos = tonumber(new_pos)
					table.insert(changes[current_filepath], {
						type = "delete",
						line = new_pos,
					})
				end
			elseif line:match("a") then
				-- Addition: NaM,L or N,LaM,L means add lines M through L after line N in old
				local after_line, start_new, end_new = line:match("^(%d+),?%d*a(%d+),?(%d*)")
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
				-- Change: N,McL,M or NcL means change lines N-M in old to lines L-M in new
				local old_start, old_end, new_start, new_end = line:match("^(%d+),?(%d*)c(%d+),?(%d*)")
				old_start = tonumber(old_start)
				old_end = old_end ~= "" and tonumber(old_end) or old_start
				new_start = tonumber(new_start)
				new_end = new_end ~= "" and tonumber(new_end) or new_start

				-- Calculate how many lines were changed/added/deleted
				local old_count = old_end - old_start + 1
				local new_count = new_end - new_start + 1

				if old_count > new_count then
					-- More old lines than new lines = some deletions + changes
					-- Mark changed lines
					for i = new_start, new_end do
						table.insert(changes[current_filepath], {
							type = "change",
							line = i,
						})
					end
					-- Mark deletion at the position where deleted lines would appear
					table.insert(changes[current_filepath], {
						type = "delete",
						line = new_end + 1,
					})
				elseif old_count < new_count then
					-- More new lines than old lines = changes + additions
					-- Mark first line as change (if there was an old line)
					if old_count > 0 then
						table.insert(changes[current_filepath], {
							type = "change",
							line = new_start,
						})
						-- Mark additional lines as additions
						for i = new_start + 1, new_end do
							table.insert(changes[current_filepath], {
								type = "add",
								line = i,
							})
						end
					else
						-- All new lines are additions
						for i = new_start, new_end do
							table.insert(changes[current_filepath], {
								type = "add",
								line = i,
							})
						end
					end
				else
					-- Same number of lines = pure changes
					for i = new_start, new_end do
						table.insert(changes[current_filepath], {
							type = "change",
							line = i,
						})
					end
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

	-- Always clear existing signs first to handle undo/redo properly
	vim.fn.sign_unplace(sign_group, { buffer = bufnr })

	if not is_p4_file(filepath) then
		buffers[bufnr] = nil
		return
	end

	local diff_output = get_p4_diff(filepath)
	if not diff_output then
		buffers[bufnr] = nil
		return
	end

	local changes = parse_p4_diff(diff_output, filepath)
	local file_changes = changes[filepath]

	if file_changes and #file_changes > 0 then
		apply_signs(bufnr, file_changes)
		buffers[bufnr] = true
	else
		buffers[bufnr] = nil
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

	-- Update on file read/write/undo/redo
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "TextChanged", "TextChangedI" }, {
		group = group,
		callback = function(args)
			if M.config.auto_update then
				if args.event == "BufReadPost" or args.event == "BufWritePost" then
					-- Immediate update for file operations
					update_buffer_signs(args.buf)
				else
					-- Debounced update for text changes
					if buffers[args.buf] then
						debounced_update(args.buf)
					end
				end
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

	-- Re-define highlights after colorscheme changes
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			define_signs()
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
