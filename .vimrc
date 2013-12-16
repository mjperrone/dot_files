"personal maps

"don't save the deleted stuff in the default register when modifying delete
"with leader
map <Leader>d "_d

set shellcmdflag=-ic "make vim's :! shell behave like my command prompt

syntax on
filetype indent plugin on


autocmd BufNewFile,BufRead *.txt setlocal spell
autocmd BufNewFile,BufRead *.md setlocal spell
autocmd BufNewFile,BufRead gitcommit setlocal spell 
autocmd BufNewFile,BufRead *.tex setlocal spell 

"tabbing stuff:
set tabstop=4 "tabs are 4 spaces
set shiftwidth=4 ">> and << behave right 
set expandtab "hitting <tab> will indent correctly
set softtabstop=4 " 4 spaces as a tab for bs/del
set shiftround "tab to multiples of 4 spaces instead of absolute shifting

set virtualedit=onemore "this makes the cursor go one past the last character of a line

set number

set iskeyword-=_ " underscores are treated as word boundaries, but not WORD boundaries

set ruler "row and col numbers in bottom right always

if version >= 703

    set undofile "keep undos across buffers and across editing instances
    set undodir=~/.vim/undodir "it's annoying to have to see them, so hide them there
    set undoreload=10000 "maximum number lines to save for undo on a buffer reload
endif
set undolevels=1000 "maximum number of changes that can be undone

set whichwrap+=<,>,h,l,[,] "auto wrap around to next line for left/right in normal, visual
                        "and insert modes, and for 'h' and 'l' in normal and visual
set statusline+=%c
set statusline+=\ %P
set statusline+=%l/%L

set showcmd "show partial commands in status

set splitright "default new buffer when splitting is on the right

set showmatch "show closing bracket locations briefly

set scrolloff=2 "show two lines below the cursor before scrolling
set sidescroll=1 "when reach end of line, jump ahead 1 chars (default jmp middle)
set sidescrolloff=5 "when reach 5 chars from the end, begin scrolling

set nostartofline "cursor stays at col pos when jumping around

set cursorline " horizontal line at cursor

"color stuff
set t_Co=256    "give terminal 256 colors instead of 8
set textwidth=80
let &colorcolumn="80,".join(range(120,999),",") " warning bar at 81 chars, highlighted forever at 120 chars
highlight ColorColumn ctermbg=242 " make it highlighted in a grey
"run :XtermColorTable to see all the colors


"searching
set hlsearch "highlights search matches
set incsearch "start finding stuff before hitting 'enter'
set ignorecase "case insensitive search
set smartcase "unless I use caps

set numberwidth=1 "line numbers will be smaller if you do ":set number: to see line number

set backspace=indent,eol,start " Backspace over anything! (Super backspace!)

" spell checks
command W w
command Q q
command WQ wg

"don't want to edit those types of files:
set wildignore+=.hg,.git,.svn,*.aux,*.out,*.toc,*.jpg,*.bmp,*.gif,*.png,*.jpeg,*.o,*.obj,*.exe,*.dll,*.manifest,*.spl,*.sw?,*.DS_Store,*.luac,migrations,*.pyc,*.orig

set wildmenu    " Autocomplete featuers in the status bar

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
