-- vim.g.vimtex_view_general_options = "xdg-open"
vim.g.vimtex_compiler_latexmk = {
    options = {
        '-shell-escape',
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
        }
    }
