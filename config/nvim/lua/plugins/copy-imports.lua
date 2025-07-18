local ts_util = require("utils.treesitter")

function string:startswith(start) return self:sub(1, #start) == start end

local M = {
  --
}

local import_query = [[
((import_statement) @node) 
]]

local ident_query = [[
([
  ((identifier) @match)
  ((type_identifier) @match)
])
]]

function GetClipboard() return vim.fn.getreg("+") end

function GetIdentsInSelection(buf, sel)
  local idents = {}

  local language_tree = vim.treesitter.get_parser(buf)
  local root = language_tree:trees()[1]:root()

  local query = vim.treesitter.query.parse(language_tree:lang(), ident_query)
  if query == nil then return end

  for _, node in query:iter_captures(root, buf) do
    local node_start = { node:start() }
    local node_end = { node:end_() }

    if
      (sel[1][1] - 1) > node_start[1]
      or sel[1][2] > node_start[2]
      or (sel[2][1] - 1) < node_end[1]
      -- the node end position is 1 past the last node
      or sel[2][2] < (node_end[2] - 1)
    then
      goto continue
    end

    local ident = vim.treesitter.get_node_text(node, buf)
    table.insert(idents, ident)
    ::continue::
  end

  return idents
end

local function GetImportNodes(buf)
  local imports = {}

  local language_tree = vim.treesitter.get_parser(buf)
  local root = language_tree:trees()[1]:root()

  local query = vim.treesitter.query.parse(language_tree:lang(), import_query)
  if query == nil then return end

  for _, node in query:iter_captures(root, buf) do
    -- skip over ambient imports
    if node:named_child(1) == nil then goto continue end

    local source = vim.treesitter.get_node_text(node:named_child(1):child(1), buf)
    local type_import = false

    local children = ts_util.children(node)

    -- if there's a "type" token, skip it and set a flag
    local n = table.remove(children, 2)
    if n:type() == "type" then
      type_import = true
      n = table.remove(children, 2)
    end

    for n in n:iter_children() do
      if n:type() == "identifier" then
        local ident = vim.treesitter.get_node_text(n, buf)
        imports[ident] = { name = ident, source = source, default = true, type_import = type_import }
      end

      if n:type() == "named_imports" then
        for n in n:iter_children() do
          if n:type() == "import_specifier" then
            local ident = vim.treesitter.get_node_text(n:named_child(0), buf)
            local entry = { name = ident, source = source }

            if type_import or n:child(0):type() == "type" then entry.type_import = true end

            if n:named_child(1) ~= nil then
              entry.alias = vim.treesitter.get_node_text(n:named_child(1), buf)
              imports[entry.alias] = entry
            else
              imports[ident] = entry
            end
          end
        end
      end

      if n:type() == "namespace_import" then
        local text = vim.treesitter.get_node_text(n, buf)
        local ident = text:sub(6)
        imports[ident] = { name = ident, source = source, namespace = true }
      end
    end
    ::continue::
  end
  return imports
end

local function add_import(buf, import)
  local language_tree = vim.treesitter.get_parser(buf)
  local row = 0
  local col = 0
  language_tree:for_each_tree(function(tree, lt)
    local ft = lt:lang()
    local root = tree:root()
    local query = vim.treesitter.query.parse(ft, import_query)
    if query == nil then return end
    for _, node in query:iter_captures(root, buf) do
      row, col, _ = node:end_()
    end
    print(row, col)

    local line
    if import.default then
      if import.type_import then
        line = "import type " .. import.name .. ' from "' .. import.source .. '";'
      else
        line = "import " .. import.name .. ' from "' .. import.source .. '";'
      end
    elseif import.alias ~= nil then
      if import.type_import then
        line = "import { type " .. import.name .. " as " .. import.alias .. ' } from "' .. import.source .. '";'
      else
        line = "import { " .. import.name .. " as " .. import.alias .. ' } from "' .. import.source .. '";'
      end
    elseif import.namespace ~= nil then
      line = "import * as " .. import.name .. ' from "' .. import.source .. '";'
    else
      if import.type_import then
        line = "import { type " .. import.name .. ' } from "' .. import.source .. '";'
      else
        line = "import { " .. import.name .. ' } from "' .. import.source .. '";'
      end
    end
    vim.api.nvim_buf_set_lines(buf, row + 1, row + 1, true, { line })
  end)
end

local Stash = nil

vim.api.nvim_create_autocmd("LspAttach", {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function(ev)
    vim.keymap.set("n", "p", function()
      vim.cmd("normal! p")
      if Stash == nil or Stash.clipboard ~= GetClipboard() then return end

      vim.schedule(function()
        local local_imports = GetImportNodes(ev.buf)

        for _, import in pairs(Stash.imports) do
          if import.alias ~= nil then
            if local_imports[import.alias] == nil then add_import(ev.buf, import) end
          else
            if local_imports[import.name] == nil then add_import(ev.buf, import) end
          end
        end
      end)
    end, { silent = true, buffer = ev.buf })

    vim.api.nvim_create_autocmd("TextYankPost", {
      buffer = ev.buf,
      callback = function(ev)
        local sel = { vim.api.nvim_buf_get_mark(ev.buf, "["), vim.api.nvim_buf_get_mark(ev.buf, "]") }

        local imports = GetImportNodes(ev.buf)
        local idents = GetIdentsInSelection(ev.buf, sel)
        local required_imports = {}

        for _, ident in ipairs(idents) do
          if imports[ident] ~= nil then required_imports[ident] = imports[ident] end
        end

        Stash = { clipboard = GetClipboard(), imports = required_imports }
      end,
    })
  end,
})

return M
