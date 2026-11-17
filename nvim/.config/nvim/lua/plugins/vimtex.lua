return {
  {
    "lervag/vimtex",
    lazy = false, -- Recomendado pelo VimTeX para inicializar hooks e filetypes corretamente
    init = function()
      -- Define o visualizador integrado como o Zathura
      vim.g.vimtex_view_method = "zathura"

      -- Define o motor de compilação contínua como latexmk com xelatex
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        engine = "-xelatex",
      }

      -- Não abre a janela de erros automaticamente se forem apenas warnings
      vim.g.vimtex_quickfix_mode = 0
    end,
    keys = {
      {
        "<leader>cp",
        "<cmd>VimtexCompile<cr>",
        desc = "LaTeX: Live Preview (Toggle)",
        ft = { "tex", "plaintex", "bib" },
      },
      {
        "<leader>cv",
        "<cmd>VimtexView<cr>",
        desc = "LaTeX: SyncTeX Ir para Cursor",
        ft = { "tex", "plaintex", "bib" },
      },
      {
        "<leader>cs",
        "<cmd>VimtexStop<cr>",
        desc = "LaTeX: Parar Compilador",
        ft = { "tex", "plaintex", "bib" },
      },
      {
        "<leader>ce",
        "<cmd>VimtexErrors<cr>",
        desc = "LaTeX: Ver Erros/Logs",
        ft = { "tex", "plaintex", "bib" },
      },
      {
        "<leader>ck",
        "<cmd>VimtexClean<cr>",
        desc = "LaTeX: Limpar Arquivos Auxiliares",
        ft = { "tex", "plaintex", "bib" },
      },
    },
  },
}
