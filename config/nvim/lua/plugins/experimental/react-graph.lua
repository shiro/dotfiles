local M = {
  -- init = function()
  --   --
  --   print("hello world")
  -- end,
}

-- Promisified version of vim.lsp.buf.references
local function get_references_async()
  local co = coroutine.running()

  local on_list = function(results)
    local items = {}
    for _, item in ipairs(results.items) do
      table.insert(items, {
        filepath = item.filename,
        col_start = item.col,
        col_end = item.end_col,
        row_start = item.lnum,
        row_end = item.end_lnum,
      })
    end

    -- Resume the coroutine with the results
    coroutine.resume(co, items)
  end

  vim.lsp.buf.references(nil, { on_list = on_list })

  -- Yield until the callback is called
  return coroutine.yield()
end

-- Helper function to get treesitter parser for a file
local function get_parser_for_file(filepath)
  -- Get the filetype based on the file extension
  local filetype = vim.filetype.match({ filename = filepath })

  -- Map vim filetypes to treesitter languages
  local filetype_to_lang = {
    typescriptreact = "tsx",
    javascriptreact = "jsx",
    typescript = "typescript",
    javascript = "javascript",
  }

  -- Get the treesitter language name
  local lang = filetype_to_lang[filetype] or filetype

  -- Check if treesitter parser exists for this language
  local has_parser = pcall(vim.treesitter.language.get_lang, lang)
  if not has_parser then
    return nil,
      "No treesitter parser for language: " .. (lang or "unknown") .. " (filetype: " .. (filetype or "unknown") .. ")"
  end

  return lang, nil
end

-- Helper function to find the node at a specific position
local function find_node_at_position(parser, row, col)
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Convert to 0-based indexing (treesitter uses 0-based)
  local target_row = row - 1
  local target_col = col - 1

  return root:descendant_for_range(target_row, target_col, target_row, target_col)
end

-- Helper function to traverse up and find function declaration variable name
local function find_function_declaration_name(node, file_content)
  local current = node
  local variable_name = nil

  while current do
    local node_type = current:type()

    -- Handle different types of function declarations
    if node_type == "variable_declarator" then
      -- For: const component = () => {...}
      local identifier = current:child(0)
      if identifier and identifier:type() == "identifier" then
        variable_name = vim.treesitter.get_node_text(identifier, file_content)
      end
    elseif node_type == "function_declaration" then
      -- For: function component() {...}
      local identifier = current:child(1)
      if identifier and identifier:type() == "identifier" then
        variable_name = vim.treesitter.get_node_text(identifier, file_content)
      end
    elseif node_type == "export_statement" then
      -- For: export default function component() {...}
      local declaration = current:child(2) -- Skip 'export' and 'default'
      if declaration and declaration:type() == "function_declaration" then
        local identifier = declaration:child(1)
        if identifier and identifier:type() == "identifier" then
          variable_name = vim.treesitter.get_node_text(identifier, file_content)
        end
      end
    end

    current = current:parent()
  end

  return variable_name
end

vim.keymap.set(
  "n",
  "<leader>ii",
  coroutine.wrap(function()
    local ok, result = pcall(function()
      local items = get_references_async()

      if not items or #items == 0 then
        print("No references found")
        return
      end

      local first_item = items[2]
      local raw_file_lines = vim.fn.readfile(first_item.filepath)

      -- Join lines into a single string for treesitter parsing
      local file_content = table.concat(raw_file_lines, "\n")

      -- Get parser for the file
      local filetype, err = get_parser_for_file(first_item.filepath)
      if not filetype then
        print("Error: " .. err)
        return
      end

      -- Create a treesitter parser
      local parser = vim.treesitter.get_string_parser(file_content, filetype)

      -- Find the node at the reference position
      local node = find_node_at_position(parser, first_item.row_start, first_item.col_start)

      if not node then
        print("No node found at position")
        return
      end

      -- Find the function declaration variable name
      local var_name = find_function_declaration_name(node, file_content)
      if not var_name then return end

      print("variable name: " .. var_name)
    end)

    if not ok then print("Error in coroutine: " .. tostring(result)) end
  end),
  { desc = "Print function declaration variable name from references" }
)

return M
