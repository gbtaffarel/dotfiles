" ==============================================================================
" .vimrc - Inspirado no LazyVim e adaptado para o INF-UFRGS
" ==============================================================================

" --- 1. Tecla Leader ---
let mapleader = " "
let maplocalleader = " "

" --- 2. Interface e Aparência ---
syntax on
filetype plugin indent on

set number
set relativenumber          " Números de linha híbridos/relativos (como no LazyVim)
set cursorline              " Destaca a linha onde o cursor está
set background=dark
silent! colorscheme desert  " Esquema de cores que funciona muito bem em terminais

set showcmd                 " Mostra comandos parciais na barra inferior
set showmode                " Mostra o modo atual (-- INSERT --, etc.)
set laststatus=2            " Sempre mostra a barra de status
set ruler                   " Mostra linha e coluna
set title                   " Define o título da janela

" Linha de status elegante e informativa (sem precisar de plugins externos)
set statusline=%f\ %m%r%h%w\ [%Y]\ [%{&ff}]\ %=[%l/%L,%c]\ [%p%%]

" --- 3. Indentação e Espaçamento (Preferências de options.lua) ---
set noexpandtab             " Usa tabs reais (não converte para espaços)
set tabstop=4               " Largura do tab = 4
set shiftwidth=4            " Largura da indentação = 4
set softtabstop=4
set autoindent              " Mantém indentação da linha anterior
set smartindent             " Indentação inteligente para C/C++

" --- 4. Comportamento e Busca ---
set ignorecase              " Ignora maiúsculas/minúsculas na busca...
set smartcase               " ...a menos que tenha uma letra maiúscula na query
set incsearch               " Busca incremental ao digitar
set hlsearch                " Destaca resultados da busca
set scrolloff=4             " Mantém 4 linhas acima/abaixo ao rolar
set sidescrolloff=8         " Mantém 8 colunas à esquerda/direita
set splitbelow              " Splits horizontais abrem abaixo
set splitright              " Splits verticais abrem à direita
set mouse=a                 " Habilita mouse para clique e rolagem
set backspace=indent,eol,start " Backspace normal no insert mode
set hidden                  " Permite trocar de buffer sem salvar antes
set autoread                " Recarrega se o arquivo for alterado fora

" Histórico de Undo persistente
if has('persistent_undo')
    silent! call mkdir(expand('~/.vim/undo'), 'p')
    set undofile
    set undodir=~/.vim/undo//
endif

" --- 5. Atalhos de Teclado (Baseados no seu keymaps.lua e LazyVim) ---

" Centralizar tela ao rolar (de keymaps.lua)
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Limpar destaque de busca com ESC (como no LazyVim)
nnoremap <Esc> :nohlsearch<CR><Esc>

" Salvar e fechar rápido
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Navegação entre janelas (Ctrl + h/j/k/l como no LazyVim)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Navegação entre buffers (Shift+H e Shift+L como no LazyVim)
nnoremap <S-h> :bprevious<CR>
nnoremap <S-l> :bnext<CR>
nnoremap <leader>bd :bdelete<CR>

" Mover blocos de linhas no modo visual (J e K como no LazyVim)
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Manter seleção ao indentar com < e >
vnoremap < <gv
vnoremap > >gv

" Clipboard (de keymaps.lua)
vnoremap <leader>yy "+y
nnoremap <leader>ya ggVG"+y
nnoremap <leader>pp "+p

" --- Surround no Modo Visual (selecione o texto e pressione S + caractere) ---
" Exemplo: selecione o texto no modo visual e aperte S" para colocar entre aspas
vnoremap S" c"<C-r>""<Esc>
vnoremap S' c'<C-r>"'<Esc>
vnoremap S` c`<C-r>"`<Esc>
vnoremap S( c(<C-r>")<Esc>
vnoremap S) c( <C-r>" )<Esc>
vnoremap S[ c[<C-r>"]<Esc>
vnoremap S] c[ <C-r>" ]<Esc>
vnoremap S{ c{<C-r>"}<Esc>
vnoremap S} c{ <C-r>" }<Esc>
vnoremap S< c<<C-r>"><Esc>
vnoremap S> c< <C-r>" ><Esc>

" Explorador de arquivos em estilo árvore (atalho <leader>e)
nnoremap <leader>e :Explore<CR>
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 0
let g:netrw_winsize = 25

" Fechar o Netrw facilmente com 'q', '<Esc>' ou pressionando '<leader>e' novamente
augroup NetrwCustom
    autocmd!
    autocmd FileType netrw nnoremap <buffer> q :Rex<CR>
    autocmd FileType netrw nnoremap <buffer> <Esc> :Rex<CR>
    autocmd FileType netrw nnoremap <buffer> <leader>e :Rex<CR>
augroup END

" --- 6. Runner de Código (<leader>cc com contorno automático para noexec) ---
" No portal do INF, o /home tem noexec. Esta função gera o binário em /tmp
" permitindo compilar e rodar sem o erro de 'Permission denied'!
function! RunCurrentFile()
    write
    let l:ext = expand('%:e')
    let l:name = expand('%:t:r')
    if l:ext ==# 'c'
        execute '!gcc % -o /tmp/' . l:name . ' -Wall -Wextra && /tmp/' . l:name
    elseif l:ext ==# 'cpp' || l:ext ==# 'cc' || l:ext ==# 'cxx'
        execute '!g++ % -o /tmp/' . l:name . ' -std=c++17 -Wall -Wextra && /tmp/' . l:name
    elseif l:ext ==# 'py'
        execute '!python3 %'
    elseif l:ext ==# 'sh'
        execute '!bash %'
    else
        echo "Nenhum runner configurado para ." . l:ext
    endif
endfunction
nnoremap <leader>cc :call RunCurrentFile()<CR>
