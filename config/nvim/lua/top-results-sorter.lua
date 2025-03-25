local M = {}
local Sorter = require("telescope.sorters").Sorter

local dirname = function(str) return str:match("(.*/)") end

HistMap = {}
function HistMap:new(from)
  local o = from or {}
  setmetatable(o, self)
  self.__index = self
  if o.map == nil or o.len == nil then
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
    if self.latest == path then return end
    -- increment everyone before us
    for k, v in pairs(self.map) do
      if v < self.map[path] then self.map[k] = v + 1 end
    end
    self.map[path] = 0
  end
  self.latest = path
end

-- returns a score of [0..1], 0 being the best
function HistMap:get_recency(path)
  if self.len == 0 then return nil end
  if self.map[path] == nil then return nil end
  if self.len == 1 then return 0 end
  return self.map[path] / (self.len - 1)
end

M.Recent = {}

local get_cwd_hash = function()
  local cwd = vim.fn.getcwd()
  if cwd == nil then return nil end
  local hash = cwd:gsub("^/", ""):gsub("/", "--")
  local data_dir = os.getenv("XDG_DATA_HOME")
  if data_dir == nil then return nil end
  data_dir = data_dir .. "/nvim/recent-files"
  return data_dir .. "/" .. hash
end

function M.save_history(name)
  if M.Recent[name] == nil then return end

  local hash = get_cwd_hash()
  if hash == nil then return end

  -- ensure the data dir exists
  local data_dir = dirname(hash)
  os.execute('mkdir -p "' .. data_dir .. '"')

  local fd = io.open(hash .. "__" .. name, "w")
  if fd == nil then return end
  local raw = vim.json.encode(M.Recent[name])
  fd:write(raw)
  fd:close()
end

function M.PushRecent(name, value)
  if M.Recent[name] == nil then M.Recent[name] = HistMap:new() end
  M.Recent[name]:push(value)
end

function M.load_history(name)
  M.Recent[name] = HistMap:new()

  local cwd_hash = get_cwd_hash()
  if cwd_hash == nil then return end
  local fd = io.open(cwd_hash .. "__" .. name, "r")
  if fd == nil then return end
  local raw = fd:read("*a")
  if raw == nil then return end
  fd:close()

  local json = HistMap:new(vim.json.decode(raw, { luanil = { object = true } }))
  if json == nil then return end
  M.Recent[name] = json
end

M.sorter = function(opts)
  if opts.name == nil then error("'name' option is required") end
  opts = vim.tbl_extend("keep", opts, { most_recent_is_last = false })

  local RECENCY_RATIO = 0.2
  local sorter = require("telescope._extensions").manager["zf-native"].native_zf_scorer()

  return Sorter:new({
    discard = true,
    scoring_function = function(self, prompt, line)
      if M.Recent[opts.name] == nil then M.load_history(opts.name) end

      local recency = M.Recent[opts.name]:get_recency(line)
      if recency ~= nil then
        -- make the currently open buffer the last result
        if recency == 0 and opts.most_recent_is_last then return 10 end
        -- make sure worst recency is still better than none
        recency = recency * 0.99
      else
        -- fallback to "worst case"
        recency = 1
      end

      local score = 1

      if prompt ~= "" then
        score = sorter.scoring_function(self, prompt, line)
        if score == -1 then return -1 end
      end

      return score * (1 - RECENCY_RATIO) + recency * RECENCY_RATIO
    end,
    start = sorter.start,
    highlighter = sorter.highlighter,
  })
end

return M
