syntax on
filetype indent plugin on

"tabbing stuff:
set tabstop=4 "tabs are 4 spaces
set shiftwidth=4 ">> and << behave right 
set expandtab "hitting <tab> will indent correctly
set softtabstop=4 " 4 spaces as a tab for bs/del
set shiftround "tab to multiples of 4 spaces instead o absolute shifting

set virtualedit=onemore "this makes the cursor go one past the last character of a line

set iskeyword-=_ " underscores are treated as word boundaries, but not WORD boundaries

set ruler "row and col numbers in bottom right always

set undofile "keep undos across buffers and across editing instances
set undodir=~/.vim/undodir "it's annoying to have to see them, so hide them there
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on a buffer reload

set whichwrap+=<,>,h,l,[,] "auto wrap around to next line for left/right in normal, visual
                        "and insert modes, and for 'h' and 'l' in normal and visual
set statusline+=%c
set statusline+=\ %P
set statusline+=%l/%L

set showcmd "show partial commands in status

set showmatch "show closing bracket locations briefly

set scrolloff=2 "show two lines below the cursor before scrolling

set cursorline " horizontal line at cursor

"searching
set hlsearch "highlights search matches
set incsearch "start finding stuff before hitting 'enter'
set ignorecase "case insensitive search
set smartcase "unless I use caps

set numberwidth=1 "line numbers will be smaller if you do ":set number: to see line numbers

set backspace=indent,eol,start " Backspace over anything! (Super backspace!)

"exit insert mode by tapping jj really fast
imap jj <Esc>

" spell checks
command W w
command Q q
command WQ wg


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

" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults
to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'


" pathogen config stuff follows: *********************************
" the thing that pathogen told me to put in here:
"the thing that python-mode told me to put in here for pathogen:
filetype off

call pathogen#infect()
call pathogen#helptags()

filetype plugin indent on

" python-mode config stuff follows: https://github.com/klen/python-mode
let g:pymode_lint_ignore = "E501" "ignore comma separated list of error codes
let g:pymode_folding = 0 "default don't fold code
