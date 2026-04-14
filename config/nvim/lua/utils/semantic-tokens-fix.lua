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

  local data = result.data
  local line = 0
  local col = 0

  local i = 1
  while i <= #data do
    local delta_line = data[i]
    local delta_col = data[i + 1]
    local length = data[i + 2]
    local token_type_idx = data[i + 3]
    local token_modifiers_bits = data[i + 4]

    line = line + delta_line
    if delta_line > 0 then
      col = delta_col
    else
      col = col + delta_col
    end

    if token_type_idx < #token_types then
      local token_type = token_types[token_type_idx + 1]
      local hl_group = "@lsp.type." .. token_type

      -- Apply modifiers
      if token_modifiers_bits > 0 then
        for j, modifier in ipairs(token_modifiers) do
          if bit.band(token_modifiers_bits, bit.lshift(1, j - 1)) > 0 then hl_group = hl_group .. "." .. modifier end
        end
      end

      -- Create extmark with higher priority than TreeSitter (100)
      pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, line, col, {
        end_col = col + length,
        hl_group = hl_group,
        priority = 200,
      })
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
    if err or not result or not result.data or #result.data == 0 then return end

    apply_semantic_tokens_manually(client, bufnr, result)
  end)
end

return M
