return function()
  vim.ui.input({ prompt = "Diff with: " }, function(input)
    if input and input ~= "" then
      require("diffview").open({ input })
    end
  end)
end
