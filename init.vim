" my vim configs are a mess, but I haven't bothered to improve them since I've switched to helix

let mapleader = "'"
set hidden
set number relativenumber
syntax on

set hlsearch
set ignorecase
set smartcase
set tabstop=4 softtabstop=4 expandtab shiftwidth=4 smarttab
set undofile
set undodir="~/.cache/nvim/undo/"
let spelllang = "en-us"
set splitright

set foldmethod=indent
set foldlevel=99

set directory^=$HOME/.nvim/tmp//

nnoremap <leader>d <cmd>b TODO<cr>

set wildmenu
set wildmode=longest:full,full
set mouse=a

nnoremap <C-t> :NERDTreeToggle<CR>

nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
nnoremap gR <cmd>TroubleToggle lsp_references<cr>

nnoremap <F5> :UndotreeToggle<CR>
" Does not work -- IDK why.
map ScrollWheelDown <C-U>
map ScrollWheelUp <C-D>

noremap <2-ScrollWheelUp> <Nop>
noremap <3-ScrollWheelUp> <Nop>
noremap <4-ScrollWheelUp> <Nop>
noremap <2-ScrollWheelDown> <Nop>
noremap <3-ScrollWheelDown> <Nop>
noremap <4-ScrollWheelDown> <Nop>

"set mousescroll=ver:0,hor:0

aunmenu PopUp.How-to\ disable\ mouse
aunmenu PopUp.-1-

let g:w3m#external_browser = 'explorer.exe'
let g:gxext#opencmd = 'explorer.exe'
let g:startify_session_persistence = 1
let g:NERDTreeShowHidden = 1

nnoremap <leader>h :noh<CR>
nnoremap <leader>q :BD<cr>
nnoremap <leader>f 1z=
nnoremap <leader>s :set spell!<cr>

let g:floaterm_keymap_toggle = '<leader>t'
let g:floaterm_keymap_next = '<leader>fn'
let g:floaterm_keymap_prev = '<leader>fp'

if has('nvim')
  let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif
autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete

autocmd TermOpen * startinsert

"autocmd FileType w3mLocal,w3m setlocal wrap " doesn't work for some reason

set foldlevel=99
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd BufNewFile,BufRead *.pxi set filetype=pyrex
