local M = {}
local Sorter = require "telescope.sorters".Sorter
local util = require "telescope.utils"
local sorters = require('telescope.sorters')
local fzy_sorter = sorters.get_fzy_sorter()


List = {}
function List.new ()
  return {first = 0, last = -1}
end
function List.pushleft (list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
end

function List.pushright (list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end

function List.popleft (list)
  local first = list.first
  if first > list.last then error("list is empty") end
  local value = list[first]
  list[first] = nil        -- to allow garbage collection
  list.first = first + 1
  return value
end

function List.popright (list)
  local last = list.last
  if list.first > last then error("list is empty") end
  local value = list[last]
  list[last] = nil         -- to allow garbage collection
  list.last = last - 1
  return value
end

function List.find(list, value)
    for i = list.first, list.last do
        if list[i] == value then
            return i
        end
    end
    return false
end


Recent = List.new()

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        local path = vim.fn.expand('%')
        if path ~= "" then
            List.pushright(Recent, path)
            print("add", path, "actual", Recent[Recent.last])
        end
        --print(string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd(), ''))
    end
})







M.sorter = function(opts)
    opts = opts or {}

    local fzy = opts.fzy_mod or require "telescope.algos.fzy"
    local OFFSET = -fzy.get_score_floor()

    return Sorter:new {
        discard = true,
        scoring_function = function(_, prompt, line)
            -- Check for actual matches before running the scoring alogrithm.
            if prompt ~= "" and not fzy.has_match(prompt, line) then
              return -1
            end

            -- print("recent is ", Recent[Recent.last] )

            local boost = 0
            local idx = List.find(Recent, line)
            if idx then
                if line == Recent[Recent.last] then
                    return 2
                end
                boost = -100 - idx
            end

            local fzy_score = fzy.score(prompt, line)

            -- The fzy score is -inf for empty queries and overlong strings.  Since
            -- this function converts all scores into the range (0, 1), we can
            -- convert these to 1 as a suitable "worst score" value.
            if fzy_score == fzy.get_score_min() then
              return 1 + boost
            end

            -- Poor non-empty matches can also have negative values. Offset the score
            -- so that all values are positive, then invert to match the
            -- telescope.Sorter "smaller is better" convention. Note that for exact
            -- matches, fzy returns +inf, which when inverted becomes 0.
            return (1 / (fzy_score + OFFSET)) + boost
        end,
      highlighter = fzy_sorter.highlighter
    }
end

return M











-- local make_cached_tail = function()
--     local os_sep = util.get_separator()
--     local match_string = "[^" .. os_sep .. "]*$"
--     return setmetatable({}, {
--         __index = function(t, k)
--             local tail = string.match(k, match_string)

--             rawset(t, k, tail)
--             return tail
--         end,
--     })
-- end
-- local make_cached_uppers = function()
--     return setmetatable({}, {
--         __index = function(t, k)
--             local obj = {}
--             for i = 1, #k do
--                 local s_byte = k:byte(i, i)
--                 if s_byte <= 90 and s_byte >= 65 then
--                     obj[s_byte] = true
--                 end
--             end

--             rawset(t, k, obj)
--             return obj
--         end,
--     })
-- end
-- local ngram_highlighter = function(ngram_len, prompt, display)
--     local highlights = {}
--     display = display:lower()

--     for disp_index = 1, #display do
--         local char = display:sub(disp_index, disp_index + ngram_len - 1)
--         if prompt:find(char, 1, true) then
--             table.insert(highlights, {
--                 start = disp_index,
--                 finish = disp_index + ngram_len - 1,
--             })
--         end
--     end

--     return highlights
-- end
-- M.sorter = function(opts)
--     opts = opts or {}

--     local ngram_len = opts.ngram_len or 2

--     local cached_ngrams = {}

--     local function overlapping_ngrams(s, n)
--         if cached_ngrams[s] and cached_ngrams[s][n] then
--             return cached_ngrams[s][n]
--         end

--         local R = {}
--         for i = 1, s:len() - n + 1 do
--             R[#R + 1] = s:sub(i, i + n - 1)
--         end

--         if not cached_ngrams[s] then
--             cached_ngrams[s] = {}
--         end

--         cached_ngrams[s][n] = R

--         return R
--     end

--     local cached_tails = make_cached_tail()
--     local cached_uppers = make_cached_uppers()

--     local n = 1
--     return Sorter:new {
--         scoring_function = function(_, prompt, line)
--             if List.contains(recent, line) then
--                 print("found: "..line)
--                 return -99999
--             end

--             n = n + 1
--             local N = #prompt

--             if N == 0 or N < ngram_len then
--                 -- TODO: If the character is in the line,
--                 -- then it should get a point or somethin.
--                 return 1
--             end

--             local prompt_lower = prompt:lower()
--             local line_lower = line:lower()

--             local prompt_lower_ngrams = overlapping_ngrams(prompt_lower, ngram_len)

--             -- Contains the original string
--             local contains_string = line_lower:find(prompt_lower, 1, true)

--             local prompt_uppers = cached_uppers[prompt]
--             local line_uppers = cached_uppers[line]

--             local uppers_matching = 0
--             for k, _ in pairs(prompt_uppers) do
--                 if line_uppers[k] then
--                     uppers_matching = uppers_matching + 1
--                 end
--             end

--             -- TODO: Consider case senstivity
--             local tail = cached_tails[line_lower]
--             local contains_tail = tail:find(prompt, 1, true)

--             local consecutive_matches = 0
--             local previous_match_index = 0
--             local match_count = 0

--             for i = 1, #prompt_lower_ngrams do
--                 local match_start = line_lower:find(prompt_lower_ngrams[i], 1, true)
--                 if match_start then
--                     match_count = match_count + 1
--                     if match_start > previous_match_index then
--                         consecutive_matches = consecutive_matches + 1
--                     end

--                     previous_match_index = match_start
--                 end
--             end

--             local tail_modifier = 1
--             if contains_tail then
--                 tail_modifier = 2
--             end

--             local denominator = (
--                 (10 * match_count / #prompt_lower_ngrams)
--                 -- biases for shorter strings
--                 + 3 * match_count * ngram_len / #line
--                 + consecutive_matches
--                 + N / (contains_string or (2 * #line))
--                 -- + 30/(c1 or 2*N)
--                 -- TODO: It might be possible that this too strongly correlates,
--                 --          but it's unlikely for people to type capital letters without actually
--                 --          wanting to do something with a capital letter in it.
--                 + uppers_matching
--             ) * tail_modifier

--             if denominator == 0 or denominator ~= denominator then
--                 return -1
--             end

--             if #prompt > 2 and denominator < 0.5 then
--                 return -1
--             end

--             return 1 / denominator + math.sqrt(n) * 0.06
--         end,

--         highlighter = opts.highlighter or function(_, prompt, display)
--             return ngram_highlighter(ngram_len, prompt, display)
--         end,
--     }
-- end

-- return M
