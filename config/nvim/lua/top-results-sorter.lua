local M = {}
local Sorter = require "telescope.sorters".Sorter
local sorters = require('telescope.sorters')
local fzy_sorter = sorters.get_fzy_sorter()

HistMap = {}
function HistMap:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.len = 0
    o.map = {}
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
            if v < self.map[path] then self.map[k] = v + 1 end
        end
        self.map[path] = 0
    end
end

-- returns a score of [0..1], 0 being the best
function HistMap:get_recency(path)
    if self.len == 0 then return nil end
    if self.map[path] == nil then return nil end
    if self.len == 1 then return 0 end
    return self.map[path] / (self.len - 1)
end

Recent = HistMap:new()

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        local path = vim.fn.expand('%')
        if path ~= "" then
            Recent:push(path)
        end
    end
})


M.sorter = function(opts)
    opts = opts or {}

    local fzy = opts.fzy_mod or require "telescope.algos.fzy"
    local OFFSET = -fzy.get_score_floor()
    local RATIO = 0.7

    return Sorter:new {
        discard = true,
        scoring_function = function(_, prompt, line)
            -- Check for actual matches before running the scoring alogrithm.
            if prompt ~= "" and not fzy.has_match(prompt, line) then
                return -1
            end

            local recency = Recent:get_recency(line)
            if recency ~= nil then
                print(line, recency)
                -- remove currently open buffer
                if recency == 0 then return 10 end
                -- make sure worst recency is still better than none
                recency = recency * 0.99
            else
                -- fallback to "worst case"
                recency = 1
            end

            local fzy_score = 1
            if prompt ~= "" then
                fzy_score = fzy.score(prompt, line)

                if fzy_score == fzy.get_score_min() then
                    -- return "worst case"
                    fzy_score = 1
                else
                    -- map to [0..1] (lower is better)
                    fzy_score = (1 / (fzy_score + OFFSET))
                end
            end

            return fzy_score * RATIO + recency * (1 - RATIO)
        end,
        highlighter = fzy_sorter.highlighter
    }
end

return M
