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
      org_agenda_files = { "~/Documents/Notes/projects/*.org", "~/Documents/Notes/todos.org" },
      org_default_notes_file = "~/Documents/Notes/todos.org",
      org_todo_keywords = { "TODO(t)", "PROJ", "WAIT", "|", "DONE" },
      org_log_repeat = false,
      org_startup_indented = true,
      org_blank_before_new_entry = { heading = false, plain_list_item = false },
      org_capture_templates = {
        t = { description = "Task", target = "~/Documents/Notes/inbox.org", template = "* TODO %?" },
        p = { description = "Task (now)", template = "* TODO [#A] %?\nDEADLINE: %t" },
        j = { description = "Journal", target = "~/Documents/Notes/journal.org", datetree = true, template = "- %U %?" },
      },
      calendar_week_start_day = 0,
      org_agenda_start_on_weekday = false,
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
