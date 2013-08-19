set tabstop=4
set shiftwidth=4
set expandtab

set virtualedit=onemore "this makes end of line in visual mode go allll the way to the end instead of one short

syntax on
set whichwrap+=<,>,h,l,[,]
filetype indent plugin on
set statusline+=%c
set statusline+=\ %P
set statusline+=%l/%L

set cursorline

"searching
set hlsearch

"display
set numberwidth=1 "line numbers will be  smaller if you do set number to see line numbers

"editing
set backspace=2 " Backspace over anything! (Super backspace!)
set softtabstop=4 " 4 spaces as a tab for bs/del
set tabstop=4                                                                   
set shiftwidth=4
set expandtab

" Shift + Arrows - Visually Select text
 nnoremap  <s-up>     Vk
 nnoremap  <s-down>   Vj
 nnoremap  <s-right>  vl
 nnoremap  <s-left>   vh

 "exit inser mode by tapping jj really fast
 imap jj <Esc>

 "make the yy and d and stuff work with the clipboard
 set clipboard=unnamed

"case insensitive search unless used caps
 set ignorecase
 set smartcase

 " spell checks
 :command W w
 :command Q q
 

" vim-latex config stuff follows: ********************************
" REQUIRED. This makes vim invoke Latex-Suite when you open a tex file.
filetype plugin on

" IMPORTANT: win32 users will need to have 'shellslash' set so that latex
" can be called correctly.
set shellslash

" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*

" OPTIONAL: This enables automatic indentation as you type.
filetype indent on

" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults
to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'
 

