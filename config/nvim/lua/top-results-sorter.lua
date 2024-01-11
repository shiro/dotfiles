local M = {}
local Sorter = require("telescope.sorters").Sorter

function basename(str)
	local name = string.gsub(str, "(.*/)(.*)", "%2")
	return name
end

function dirname(str)
	return str:match("(.*/)")
end

HistMap = {}
function HistMap:new(from)
	local o = from or {}
	setmetatable(o, self)
	self.__index = self
	if from == nil then
		o.len = 0
		o.map = {}
	end
	return o
end

function HistMap:push(path)
	if self.map[path] == nil then
		-- increment everyone
		for k, v in pairs(self.map) do
			self.map[k] = v + 1
		end
		self.map[path] = 0
		self.len = self.len + 1
	else
		-- increment everyone before us
		for k, v in pairs(self.map) do
			if v < self.map[path] then
				self.map[k] = v + 1
			end
		end
		self.map[path] = 0
	end
end

-- returns a score of [0..1], 0 being the best
function HistMap:get_recency(path)
	if self.len == 0 then
		return nil
	end
	if self.map[path] == nil then
		return nil
	end
	if self.len == 1 then
		return 0
	end
	return self.map[path] / (self.len - 1)
end

M.Recent = HistMap:new()

function push_current_path()
	local path = vim.fn.expand("%:.")
	if path ~= "" then
		M.Recent:push(path)
	end
end

function get_cwd_hash()
	local cwd = vim.fn.getcwd()
	if cwd == nil then
		return nil
	end
	local hash = cwd:gsub("^/", ""):gsub("/", "--")
	local data_dir = os.getenv("XDG_DATA_HOME")
	if data_dir == nil then
		return nil
	end
	data_dir = data_dir .. "/nvim/recent-files"
	return data_dir .. "/" .. hash
end

function save_history()
	local hash = get_cwd_hash()
	if hash == nil then
		return
	end

	-- ensure the data dir exists
	local data_dir = dirname(hash)
	os.execute('mkdir -p "' .. data_dir .. '"')

	local fd = io.open(hash, "w")
	if fd == nil then
		return
	end
	raw = vim.json.encode(M.Recent)
	fd:write(raw)
	fd:close()
end

function load_history()
	local hash = get_cwd_hash()
	if hash == nil then
		return
	end
	local fd = io.open(hash, "r")
	if fd == nil then
		return
	end
	local raw = fd:read("*a")
	M.Recent = HistMap:new(vim.json.decode(raw, {}))
	fd:close()
	push_current_path()
end

vim.api.nvim_create_autocmd({ "FocusGained" }, {
	callback = load_history,
})

vim.api.nvim_create_autocmd({ "VimLeave", "FocusLost" }, {
	callback = save_history,
})

M.first_run = true

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if M.first_run then
			M.first_run = false
			load_history()
			return
		end
		push_current_path()
	end,
})

-- M.sorter = function(opts)
--     opts = opts or {}
--
--     local fzy = opts.fzy_mod or require("telescope.algos.fzy")
--     local OFFSET = -fzy.get_score_floor()
--     local RECENCY_RATIO = 0.5
--
--     return Sorter:new {
--         discard = true,
--         scoring_function = function(_, prompt, line)
--             -- Check for actual matches before running the scoring alogrithm.
--             if prompt ~= "" and not fzy.has_match(prompt, line) then
--                 return -1
--             end
--
--             local recency = M.Recent:get_recency(line)
--             if recency ~= nil then
--                 -- remove currently open buffer
--                 if recency == 0 then return 10 end
--                 -- make sure worst recency is still better than none
--                 recency = recency * 0.99
--             else
--                 -- fallback to "worst case"
--                 recency = 1
--             end
--
--             local fzy_score = 1
--             local fzy_filename_score = 1
--             if prompt ~= "" then
--                 fzy_score = fzy.score(prompt, line)
--                 fzy_filename_score = fzy.score(prompt, basename(line))
--
--                 if fzy_score == fzy.get_score_min() then
--                     -- return "worst case"
--                     fzy_score = 1
--                 else
--                     -- map to [0..1] (lower is better)
--                     fzy_score = (1 / (fzy_score + OFFSET))
--                 end
--
--                 if fzy_filename_score == fzy.get_score_min() then
--                     -- return "worst case"
--                     fzy_filename_score = 1
--                 else
--                     -- map to [0..1] (lower is better)
--                     fzy_filename_score = (1 / (fzy_filename_score + OFFSET))
--                 end
--             end
--
--             return (fzy_score * 0.7 + fzy_filename_score * 0.3) * (1 - RECENCY_RATIO)
--                 + recency * RECENCY_RATIO
--         end,
--         highlighter = fzy_sorter.highlighter
--     }
-- end

M.sorter = function(opts)
	opts = opts or {}

	local RECENCY_RATIO = 0.2
	local sorter = require("telescope._extensions").manager["zf-native"].native_zf_scorer()

	return Sorter:new({
		discard = true,
		scoring_function = function(self, prompt, line)
			local recency = M.Recent:get_recency(line)
			if recency ~= nil then
				-- make the currently open buffer the last result
				if recency == 0 then
					return 10
				end
				-- make sure worst recency is still better than none
				recency = recency * 0.99
			else
				-- fallback to "worst case"
				recency = 1
			end

			local score = 1

			if prompt ~= "" then
				score = sorter.scoring_function(self, prompt, line)
				if score == -1 then
					return -1
				end
			end

			return score * (1 - RECENCY_RATIO) + recency * RECENCY_RATIO
		end,
		start = sorter.start,
		highlighter = sorter.highlighter,
	})
end

return M
