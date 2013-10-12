set tabstop=4 "tabs are 4 spaces
set shiftwidth=4 ">> and << behave right 
set expandtab "hitting <tab> will indent correctly
set softtabstop=4 " 4 spaces as a tab for bs/del
set shiftround "tab to multiples of 4 spaces instead o absolute shifting

set virtualedit=onemore "this makes the cursor go one past the last character of a line

set ruler "row and col numbers in bottom right always

syntax on
set whichwrap+=<,>,h,l,[,] "auto wrap around to next line
filetype indent plugin on
set statusline+=%c
set statusline+=\ %P
set statusline+=%l/%L

set showmatch "show closing bracket locations briefly

set scrolloff=2 "show two lines below the cursor before scrolling

set cursorline " horizontal line at cursor

"searching
set hlsearch "highlights search matches
set incsearch "start finding stuff before hitting 'enter'

"display
set numberwidth=1 "line numbers will be smaller if you do set number to see line numbers

"editing
set backspace=2 " Backspace over anything! (Super backspace!)

"exit inser mode by tapping jj really fast
imap jj <Esc>

"case insensitive search unless used caps
set ignorecase
set smartcase

" spell checks
:command W w
:command Q q
:command WQ wg


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

" the thing that pathogen told me to put in here:
execute pathogen#infect() 
"the thing that python-mode told me to put in here for pathogen:
filetype off

call pathogen#infect()
call pathogen#helptags()

filetype plugin indent on
