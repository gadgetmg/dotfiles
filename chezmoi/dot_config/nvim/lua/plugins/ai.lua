return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        ["local"] = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "local",
            env = {
              url = "http://127.0.0.1:8081",
              api_key = "no-key",
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
            },
            schema = {
              model = {
                default = "gemma-3-4b-it-qat",
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "local",
        },
        inline = {
          adapter = "local",
        },
        cmd = {
          adapter = "local",
        },
      },
      opts = {
        show_defaults = false,
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
