-- Workaround for typescript-tools semantic tokens not being applied by Neovim's built-in processor
local M = {}

-- Apply semantic tokens manually with proper priority
local function apply_semantic_tokens_manually(client, bufnr, result)
  if not result or not result.data or #result.data == 0 then return end

  local ns = vim.api.nvim_create_namespace("typescript_tools_semantic_tokens")
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local legend = client.server_capabilities.semanticTokensProvider.legend
  local token_types = legend.tokenTypes
  local token_modifiers = legend.tokenModifiers

  -- Get the buffer filetype for filetype-specific highlight groups
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

  local data = result.data
  local current_line = 0
  local current_col = 0

  -- Get buffer line count for bounds checking
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  local i = 1
  while i <= #data do
    local delta_line = data[i]
    local delta_col = data[i + 1]
    local length = data[i + 2]
    local token_type_idx = data[i + 3]
    local token_modifiers_bits = data[i + 4]

    -- Apply deltas according to LSP spec
    current_line = current_line + delta_line
    if delta_line > 0 then
      -- New line: column is absolute
      current_col = delta_col
    else
      -- Same line: column is relative to previous token
      current_col = current_col + delta_col
    end

    -- Bounds checking
    if current_line >= 0 and current_line < line_count and current_col >= 0 and length > 0 then
      -- Fix: token_type_idx is 0-based, but Lua arrays are 1-based
      -- Also need to check bounds properly
      if token_type_idx >= 0 and token_type_idx < #token_types then
        local token_type = token_types[token_type_idx + 1]

        -- Get the line content to validate column bounds
        local line_content = vim.api.nvim_buf_get_lines(bufnr, current_line, current_line + 1, false)[1] or ""
        local line_length = #line_content

        -- Ensure we don't exceed line boundaries
        local end_col = math.min(current_col + length, line_length)

        if current_col < line_length then
          -- Create base type highlight group with filetype suffix
          local base_hl_group = "@lsp.type." .. token_type .. "." .. filetype

          -- Create extmark for base type with priority 125 (matching expected)
          pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, current_line, current_col, {
            end_col = end_col,
            hl_group = base_hl_group,
            priority = 125,
          })

          -- Apply modifiers as separate highlight groups
          local active_modifiers = {}
          if token_modifiers_bits > 0 then
            for j, modifier in ipairs(token_modifiers) do
              local bit_mask = 2 ^ (j - 1)
              -- Use modulo operation for bit checking (compatible with all Lua versions)
              if math.floor(token_modifiers_bits / bit_mask) % 2 == 1 then
                table.insert(active_modifiers, modifier)

                -- Create separate highlight group for each modifier with filetype suffix
                local mod_hl_group = "@lsp.mod." .. modifier .. "." .. filetype

                -- Create extmark for modifier with priority 126 (matching expected)
                pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, current_line, current_col, {
                  end_col = end_col,
                  hl_group = mod_hl_group,
                  priority = 126,
                })
              end
            end
          end

          -- Create combined typemod highlight group if there are modifiers
          if #active_modifiers > 0 then
            local typemod_hl_group = "@lsp.typemod."
              .. token_type
              .. "."
              .. table.concat(active_modifiers, ".")
              .. "."
              .. filetype

            -- Create extmark for combined type+modifier with priority 127 (matching expected)
            pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, current_line, current_col, {
              end_col = end_col,
              hl_group = typemod_hl_group,
              priority = 127,
            })
          end
        end
      end
    end

    i = i + 5
  end
end

-- Main workaround function for typescript-tools semantic tokens
---@param client table LSP client object
---@param bufnr number Buffer number
function M.setup_typescript_tools_semantic_tokens_fix(client, bufnr)
  if not client.server_capabilities.semanticTokensProvider then return end

  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  vim.lsp.buf_request(bufnr, "textDocument/semanticTokens/full", params, function(err, result)
    if err then return end

    if not result or not result.data or #result.data == 0 then return end

    -- Validate that we have the required legend
    local legend = client.server_capabilities.semanticTokensProvider.legend
    if not legend or not legend.tokenTypes or not legend.tokenModifiers then
      vim.notify("Invalid semantic tokens legend", vim.log.levels.WARN)
      return
    end

    apply_semantic_tokens_manually(client, bufnr, result)
  end)
end

return M
