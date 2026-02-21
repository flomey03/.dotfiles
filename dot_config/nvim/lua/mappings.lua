require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader>ll", ":VimtexCompile<CR>", { desc = "VimTeX: Start/Stop Compiler" })
map("n", "<leader>lv", ":VimtexView<CR>", { desc = "VimTeX: PDF anzeigen" })
map("n", "<leader>le", ":VimtexErrors<CR>", { desc = "VimTeX: Fehlerliste öffnen" })
map("n", "<leader>lc", ":VimtexClean<CR>", { desc = "VimTeX: Temp-Dateien löschen" })
map("n", "<leader>ls", ":VimtexStop<CR>", { desc = "VimTeX: Compiler stoppen" })
map("n", "<leader>li", ":VimtexInfo<CR>", { desc = "VimTeX: Status Info" })
