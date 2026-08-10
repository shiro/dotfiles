local M = {}

M.is_supported = function(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  return vim.bo[bufnr].filetype == "octo", nil
end

local function generate_octo_symbols(bufnr)
  if not octo_buffers or not octo_buffers[bufnr] then
    return {}
  end

  local buffer = octo_buffers[bufnr]
  local symbols = {}
  local constants = require("octo.constants")
  local max_line = vim.api.nvim_buf_line_count(bufnr)

  local reviews_map = {}
  if buffer.node and buffer.node.reviewThreads then
    for _, thread in ipairs(buffer.node.reviewThreads.nodes or {}) do
      if thread.comments and thread.comments.nodes and #thread.comments.nodes > 0 then
        local first_comment = thread.comments.nodes[1]
        local review_id = first_comment.pullRequestReview and first_comment.pullRequestReview.id
        if review_id then
          if not reviews_map[review_id] then
            reviews_map[review_id] = {
              author = first_comment.author and first_comment.author.login or "unknown",
              state = first_comment.pullRequestReview.state or "PENDING",
              threads = {},
              min_line = math.huge,
              created_at = first_comment.createdAt or "",
            }
          end
          table.insert(reviews_map[review_id].threads, thread)
          if buffer.threadsMetadata then
            for meta_key, meta in pairs(buffer.threadsMetadata) do
              if meta.reviewId == review_id and meta.line then
                reviews_map[review_id].min_line = math.min(reviews_map[review_id].min_line, meta.line)
              end
            end
          end
        end
      end
    end
  end

  local reviews_with_lines = {}
  for review_id, review_data in pairs(reviews_map) do
    table.insert(reviews_with_lines, {review_id, review_data})
  end
  table.sort(reviews_with_lines, function(a, b)
    return (a[2].created_at or "") < (b[2].created_at or "")
  end)

  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, constants.OCTO_COMMENT_NS, 0, -1, {details = true})
  local thread_extmarks = vim.api.nvim_buf_get_extmarks(bufnr, constants.OCTO_THREAD_NS, 0, -1, {details = true})

  local extmark_map = {}
  for _, mark in ipairs(extmarks) do
    local mark_id = mark[1]
    local line = mark[2] + 1
    local col = mark[3] or 0
    extmark_map[mark_id] = {line = line, col = col}
  end

  local thread_mark_positions = {}
  for _, mark in ipairs(thread_extmarks) do
    local mark_id = mark[1]
    local line = mark[2] + 1
    local col = mark[3] or 0
    thread_mark_positions[tostring(mark_id)] = {line = line, col = col}
  end

  local review_symbols = {}
  local thread_symbols = {}

   for _, review_pair in ipairs(reviews_with_lines) do
     local review_id = review_pair[1]
     local review_data = review_pair[2]

     -- Find the review comment (kind == "PullRequestReview") for this review_id
     local review_lnum = nil
     local review_col = 0
     
     for i, meta in ipairs(buffer.commentsMetadata or {}) do
       if meta.kind == "PullRequestReview" then
         -- For PullRequestReview kind, we need to check if it belongs to this review
         -- by checking if the first thread comment references it
         local belongs_to_review = false
         if review_data.threads and #review_data.threads > 0 then
           local first_thread = review_data.threads[1]
           if first_thread.comments and first_thread.comments.nodes and #first_thread.comments.nodes > 0 then
             local thread_first_comment = first_thread.comments.nodes[1]
             if thread_first_comment.pullRequestReview and thread_first_comment.pullRequestReview.id == review_id then
               belongs_to_review = true
             end
           end
         end
         
         if belongs_to_review and meta.extmark then
           local pos = extmark_map[meta.extmark]
           if pos then
             review_lnum = pos.line
             review_col = pos.col
             break
           end
         end
       end
     end

     -- Fallback to first thread line if review comment not found
     if not review_lnum then
       review_lnum = review_data.min_line
     end
    for _, thread in ipairs(review_data.threads) do
      for mark_id_str, pos in pairs(thread_mark_positions) do
        for meta_mark_id_str, thread_meta in pairs(buffer.threadsMetadata or {}) do
          if meta_mark_id_str == mark_id_str and thread_meta.threadId == thread.id then
            review_lnum = math.min(review_lnum, pos.line)
            if review_lnum == pos.line then
              review_col = pos.col
            end
            break
          end
        end
      end
    end

    if review_lnum == math.huge then
      review_lnum = review_data.min_line
    end

    if review_lnum and review_lnum ~= math.huge and review_lnum <= max_line then
      local review_symbol = {
        name = string.format("Review by %s (%s)", review_data.author, review_data.state),
        kind = "Class",
        lnum = review_lnum,
        end_lnum = math.min(review_lnum + 20, max_line),
        col = review_col,
        end_col = review_col,
        level = 0,
        children = {},
      }
      table.insert(symbols, review_symbol)
      review_symbols[review_id] = review_symbol

      for _, thread in ipairs(review_data.threads) do
        local thread_lnum = nil
        local thread_col = nil

        for mark_id_str, pos in pairs(thread_mark_positions) do
          for meta_mark_id_str, thread_meta in pairs(buffer.threadsMetadata or {}) do
            if meta_mark_id_str == mark_id_str and thread_meta.threadId == thread.id then
              thread_lnum = pos.line
              thread_col = pos.col
              break
            end
          end
          if thread_lnum then break end
        end

        if thread_lnum and thread_lnum <= max_line then
          local prefix = thread.isResolved and "✓ " or "📖 "
          local thread_symbol = {
            name = string.format("%sThread (%s)", prefix, thread.path or "general"),
            kind = "Interface",
            lnum = thread_lnum,
            end_lnum = math.min(thread_lnum + 10, max_line),
            col = thread_col or 0,
            end_col = thread_col or 0,
            level = 1,
            parent = review_symbol,
            children = {},
          }
          table.insert(review_symbol.children, thread_symbol)
          thread_symbols[thread.id] = thread_symbol
          thread_symbols[thread.id]._is_resolved = thread.isResolved
        end
      end
    end
  end

  if buffer.node and buffer.node.reviewThreads then
    for _, thread in ipairs(buffer.node.reviewThreads.nodes or {}) do
      local thread_symbol = thread_symbols[thread.id]
      if thread_symbol and thread.comments and thread.comments.nodes then
        local comments_with_meta = {}
        for _, thread_comment in ipairs(thread.comments.nodes) do
          local comment_meta = nil
          for i, meta in ipairs(buffer.commentsMetadata or {}) do
            if meta.id == thread_comment.id then
              comment_meta = meta
              break
            end
          end
          table.insert(comments_with_meta, {thread_comment, comment_meta})
        end

        table.sort(comments_with_meta, function(a, b)
          return (a[1].createdAt or "") < (b[1].createdAt or "")
        end)

        for _, comment_pair in ipairs(comments_with_meta) do
          local thread_comment = comment_pair[1]
          local comment_meta = comment_pair[2]

          local comment_lnum = nil
          local comment_col = nil
          if comment_meta and comment_meta.extmark then
            local pos = extmark_map[comment_meta.extmark]
            if pos then
              comment_lnum = pos.line
              comment_col = pos.col
            end
          end

          if comment_lnum and comment_lnum <= max_line then
            local prefix = thread_symbol._is_resolved and "✓ " or "📖 "
            local comment_symbol = {
              name = string.format("%sComment by %s", prefix, thread_comment.author and thread_comment.author.login or "unknown"),
              kind = "Variable",
              lnum = comment_lnum,
              end_lnum = math.min(comment_lnum + 3, max_line),
              col = comment_col or 0,
              end_col = comment_col or 0,
              level = 2,
              parent = thread_symbol,
            }
            table.insert(thread_symbol.children, comment_symbol)
          end
        end
      end
    end
  end

  return symbols
end

M.fetch_symbols_sync = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.is_supported(bufnr) then
    return
  end
  local symbols = generate_octo_symbols(bufnr)
  require("aerial.backends").set_symbols(bufnr, symbols, {
    backend_name = "octo",
    lang = "octo",
  })
end

M.fetch_symbols = M.fetch_symbols_sync
M.attach = function(bufnr) end
M.detach = function(bufnr) end

return M
