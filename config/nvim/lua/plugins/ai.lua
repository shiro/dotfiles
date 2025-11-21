local M = {
  -- TODO also try https://github.com/olimorris/codecompanion.nvim
  {
    "yetone/avante.nvim",
    -- event = "VeryLazy",
    lazy = true,
    version = false,
    branch = "main",
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      provider = "openai",
      -- provider = "bedrock",
      -- cursor_applying_provider = "openai",
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4o",
          extra_request_body = {
            -- timeout = 30000,
            temperature = 0.75,
            max_completion_tokens = 16384, -- increase this to include reasoning tokens (for reasoning models)
            reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
          },
        },
        bedrock = {
          model = "apac.anthropic.claude-sonnet-4-20250514-v1:0",
          -- model = "apac.anthropic.claude-3-haiku-20240307-v1:0",
          -- model = "apac.anthropic.claude-3-5-sonnet-20241022-v2:0",
          aws_profile = "bedrock",
          aws_region = "ap-northeast-1",
        },
      },
      selector = { provider = "telescope" },
      behaviour = {
        enable_cursor_planning_mode = true,
        auto_apply_diff_after_generation = true,
        -- auto-approve specific tools only
        auto_approve_tool_permissions = true,
      },
      selection = {
        enabled = false,
      },
      mappings = {
        sidebar = {
          close_from_input = { normal = "<esc>" },
        },
        focus = "<leader>aa",
      },
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "echasnovski/mini.pick",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
      "ibhagwan/fzf-lua",
      "nvim-tree/nvim-web-devicons",
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
    },
  },
}

-- TODO add recents integration
-- local filepath = node.absolute_path
-- Api.add_selected_file(filepath)

return M
