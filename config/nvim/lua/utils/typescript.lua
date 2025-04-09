local M = {}

function string:startswith(start) return self:sub(1, #start) == start end

local get_tsserver_client = function()
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client.name == "typescript-tools" then return client end
  end
end

M.rename_directory = function()
  local a = require("plenary.async")
  local uv = require("plenary.async.uv_async")
  local au = require("plenary.async.util")

  local ui_input = a.wrap(vim.ui.input, 2)

  a.void(function()
    local client = get_tsserver_client()
    local current_dir = vim.fn.expand("%:h")

    local from = ui_input({ prompt = "From directory: ", default = current_dir })
    local to = ui_input({ prompt = "To directory: ", default = current_dir })
    from = vim.fn.fnamemodify(from, ":p")
    to = vim.fn.fnamemodify(to, ":p")

    local fs_err = uv.fs_rename(from, to)
    assert(not fs_err, fs_err)

    au.scheduler()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      local filepath = vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr)
      if filepath and filepath:startswith(from) then
        local tail = filepath:sub(#from + 1)
        local new_filepath = to .. "/" .. tail

        vim.api.nvim_buf_set_name(bufnr, new_filepath)

        -- sync to lsp
        local result, err = vim.lsp.buf_request_sync(bufnr, "workspace/willRenameFiles", {
          files = {
            {
              oldUri = vim.uri_from_fname(filepath),
              newUri = vim.uri_from_fname(new_filepath),
            },
          },
        }, 1000)
        if err or not result then return end
        result = result[client.id].result
        vim.lsp.util.apply_workspace_edit(result, "utf-8")
      end
    end
  end)()
end

return M
