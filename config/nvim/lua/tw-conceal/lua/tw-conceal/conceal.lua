local api = vim.api

local M = {}

function M.conceal_class(bufnr, config)
	vim.opt_local.conceallevel = 2

	local ft = "html"
	if not vim.tbl_contains(config.ft, vim.bo.ft) then
		ft = "tsx"
	end

	local namespace = api.nvim_create_namespace("ConcealClassName")
	local language_tree = vim.treesitter.get_parser(bufnr, ft)
	local syntax_tree = language_tree:parse()
	local root = syntax_tree[1]:root()

	local query = [[
    ((attribute
      (attribute_name) @att_name (#eq? @att_name "class")
      (quoted_attribute_value (attribute_value) @class_value) (#set! @class_value conceal "…")))
    ]]

	if ft == "tsx" then
		query = [[
      ((jsx_attribute
        (property_identifier) @att_name (#any-of? @att_name "className" "class")
	[
          ((string (string_fragment) @class_value))
          (_ (_ (_ (string (string_fragment) @class_value))))
	]
      ))
      ]]
	end

	local ts_query = vim.treesitter.query.parse(ft, query)

	for _, captures, metadata in ts_query:iter_matches(root, bufnr, root:start(), root:end_(), {}) do
		if #captures == 2 then
			local start_row, start_col, end_row, end_col = captures[2]:range()
			local row_diff = end_row - start_row
			local col_diff = end_col - start_col
			if row_diff == 0 and col_diff > config.min_chars then
				api.nvim_buf_set_extmark(bufnr, namespace, start_row, start_col, {
					end_line = end_row,
					end_col = end_col,
					conceal = "…",
				})
			end
		end
	end
end

return M
