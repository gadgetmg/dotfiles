return {
  {
    "nvim-orgmode/orgmode",
    dependencies = {
      "danilshvalov/org-modern.nvim",
      "tpope/vim-repeat",
    },
    event = "VeryLazy",
    ft = { "org" },
    opts = {
      org_agenda_files = "~/Documents/Notes/**/*",
      org_default_notes_file = "~/Documents/Notes/refile.org",
      org_todo_keywords = { "TODO(t)", "PROJECT", "WAITING", "|", "DONE", "DELEGATED(l)" },
      win_border = "single",
      org_log_into_drawer = "LOGBOOK",
      org_startup_indented = true,
      org_blank_before_new_entry = { heading = false, plain_list_item = false },
      org_capture_templates = {
        t = { description = "Task", template = "* TODO %?\n%u" },
      },
      calendar_week_start_day = 0,
      mappings = {
        org_return_uses_meta_return = true,
      },
      ui = {
        menu = {
          handler = function(data)
            local Menu = require("org-modern.menu")
            Menu:new({
              window = {
                margin = { 1, 0, 1, 0 },
                padding = { 0, 1, 0, 1 },
                title_pos = "center",
                border = "single",
                zindex = 1000,
              },
              icons = {
                separator = "➜",
              },
            }):open(data)
          end,
        },
      },
    },
  },
}
