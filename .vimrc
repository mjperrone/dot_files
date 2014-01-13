" BEGIN Vundle
set nocompatible
filetype off

set history=200 "number of exec commands saved

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
" let Vundle manage Vundle (required)
    Bundle 'gmarik/vundle'
" python mode- (pylint, autopep8, etc...)
    Bundle 'klen/python-mode'
" SnipMate- autofill snippets for boilerplate
    Bundle 'MarcWeber/vim-addon-mw-utils'
    Bundle 'tomtom/tlib_vim'
    Bundle 'garbas/vim-snipmate'
" Vim-Fugitive- a bunch of git stuff (don't tell him I'm using Vundle now...)
    Bundle 'tpope/vim-fugitive'
" Vim-latex- as it's named...
    Bundle 'git://git.code.sf.net/p/vim-latex/vim-latex'
" Vim-Sneak- the bridge between 'f' and '/'; two character multi-line search.
    Bundle 'justinmk/vim-sneak'
" xterm-color-table- displays the xterm colors with hex+rgb codes
    Bundle 'guns/xterm-color-table.vim'

filetype plugin indent on

" quasi plugins:
" super basic addition on nums newline separated.
source ~/.vim/quasi_plugins/vmath.vim
" drag around visual blocks
source ~/.vim/quasi_plugins/dragvisuals.vim

"don't save the deleted stuff in the default register this way
map <Leader>d "_d
if has("unix")
    "copy selected text in visual mode to mac system clipboard
    vmap <leader>c :w !pbcopy<CR><CR>
    "paste from clipboard without having to do :set paste i <cmd>v
    map <leader>p :r!pbpaste<CR>
endif
"I like for mark jumping to go to the row AND the column, and the apostrophe
"is easier to reach, so I'll swap those
nnoremap ' `
nnoremap ` '
"edit important files quickly
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>eb :vsplit ~/dot_files/.bashrc<cr>
nnoremap <leader>eba :vsplit ~/.bash_aliases<cr>
nnoremap <leader>ebf :vsplit ~/.bash_functions<cr>
"reload .vimrc
nnoremap <leader>sv :source $MYVIMRC<cr>
"go to the command window by default instead of exec mode
nnoremap : q:i
nnoremap q: :
"replay the last 'q' macro quickly
nnoremap Q @q

syntax on

"spellcheck
set spelllang=en_us
setlocal nospell
"toggle spellcheck
map <Leader>s :set spell!<CR>
" spellcheck these files by default
autocmd BufNewFile,BufRead *.txt setlocal spell
autocmd BufNewFile,BufRead *.md setlocal spell
autocmd BufNewFile,BufRead gitcommit setlocal spell
autocmd BufNewFile,BufRead *.tex setlocal spell 

"tabbing stuff:
"once i learn about IF statements and stuff, then can toggle 2 and 4
autocmd BufNewFile,BufRead *.sql set tabstop=2 | set shiftwidth=2 | set softtabstop=2
autocmd BufNewFile,BufRead *.html set tabstop=2 | set shiftwidth=2 | set softtabstop=2
set tabstop=4 "tabs are 4 spaces
set shiftwidth=4 ">> and << behave right 
set expandtab "hitting <tab> will indent correctly
set softtabstop=4 " 4 spaces as a tab for bs/del
set shiftround "tab to multiples of 4 spaces instead of absolute shifting

set number "line numbers
set numberwidth=1 "min width of line number columns

set iskeyword-=_ " underscores are treated as word boundaries, but not WORD boundaries. sometimes helpful, sometimes annoying, not sure on this one.

set ruler "row and col numbers in bottom right always

if version >= 703
    set undofile "keep undos across buffers and across editing instances
    set undodir=~/.vim/undodir "it's annoying to have to see them, so hide them there
    set undoreload=10000 "maximum number lines to save for undo on a buffer reload
    let &colorcolumn="80" " warning bar at 81 chars
    highlight ColorColumn ctermbg=242 " make it highlighted in a grey
    "run :XtermColorTable to see all the colors
endif
set undolevels=1000 "maximum number of changes that can be undone
set textwidth=80

set statusline+=%c
set statusline+=\ %P
set statusline+=%l/%L

set showcmd "show partial commands in status

set splitright "default new buffer when splitting is on the right

set showmatch "show closing bracket locations briefly

set scrolloff=2 "show two lines below the cursor before scrolling
set sidescroll=1 "when reach end of line, jump ahead 1 chars (default jmp middle)
set sidescrolloff=5 "when reach 5 chars from the end, begin scrolling

set nostartofline "cursor stays at col pos when jumping around rather than going to line beginning

set cursorline " horizontal line at cursor

set t_Co=256    "give terminal 256 colors instead of 8


"searching
set hlsearch "highlights search matches
set incsearch "start finding stuff before hitting 'enter'
set ignorecase "case insensitive search
set smartcase "unless I use caps

set backspace=indent,eol,start " Backspace over anything! (Super backspace!)
set virtualedit=onemore "this makes the cursor go one past the last character of a line
set whichwrap+=<,>,h,l,[,] "auto wrap around to next line for left/right in normal, visual
                        "and insert modes, and for 'h' and 'l' in normal and visual

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

" python-mode config stuff follows: https://github.com/klen/python-mode
let g:pymode_lint_ignore = "E501" "ignore comma separated list of error codes
let g:pymode_folding = 0 "default don't fold code
