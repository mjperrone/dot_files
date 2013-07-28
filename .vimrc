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
