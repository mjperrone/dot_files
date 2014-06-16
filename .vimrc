set history=200 "number of exec commands saved


" BEGIN Vundle
set nocompatible


" vundle {{{{
if !exists('*InstallVundle')
    fun! InstallVundle()
        echo "Installing Vundle..."
        silent! call mkdir(expand("~/.vim/bundle", 1), 'p')
        silent! !git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
        redraw!
        source $MYVIMRC
        PluginInstall
    endfunction
endif
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()
" let Vundle manage Vundle (required)
    Plugin 'gmarik/Vundle.vim'
" Vim-Sneak- the bridge between 'f' and '/'; two character multi-line search.
    Plugin 'justinmk/vim-sneak'
"   Golang suite
    Plugin 'fatih/vim-go'
"   Python suite
    Plugin 'klen/python-mode'
"   Syntax checker for loads of languages
    Plugin 'scrooloose/syntastic'
"   Ruby on Rails suite
    Plugin 'tpope/vim-rails'
"   Quoting/parenthesizing made easy
    Plugin 'tpope/vim-surround'
"   Python autocompletion
    Plugin 'davidhalter/jedi-vim'
" xterm-color-table- displays the xterm colors with hex+rgb codes
    Plugin 'guns/xterm-color-table.vim'
call vundle#end()
" end vundle }}}}

filetype plugin indent on

" quasi plugins:
" super basic addition on nums newline separated.
source ~/.vim/quasi_plugins/vmath.vim


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

"==============================================================================
"tabbing, indent, text stuff:

"once I learn about IF statements and stuff, then can toggle 2 and 4
autocmd BufNewFile,BufRead *.sql,*.html,*.haml,*.js,*.rb,*.erb,*.css,*.scss set tabstop=2 | set shiftwidth=2 | set softtabstop=2
set tabstop=4 "tabs are 4 spaces
set shiftwidth=4 ">> and << behave right 
set expandtab "hitting <tab> will indent correctly
set softtabstop=4 " 4 spaces as a tab for bs/del
set shiftround "tab to multiples of 4 spaces instead of absolute shifting

set formatoptions+=rno1l
if v:version > 703 || v:version == 703 && has("patch541")
  " Delete comment character when joining commented lines
  set formatoptions+=j
endif

"end tabbing, indent, text stuff:
"==============================================================================

set number "line numbers
set numberwidth=1 "min width of line number columns

"set iskeyword-=_ " underscores are treated as word boundaries, but not WORD boundaries. sometimes helpful, sometimes annoying, not sure on this one.


set lazyredraw "Don't redraw while executing macros (faster)


" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%

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

set laststatus=2
set statusline=%4* "no background color
set statusline+=\ %<%F\   "full path
set statusline+=%=  "right justify the rest
set statusline+=%y\ \ \ \  "filetype
set statusline+=%l/%L\ (%P) "curson line / total lines (percent)

set showcmd "show partial commands in status

set splitright "default new buffer, when splitting, is on the right

set showmatch "show closing bracket locations briefly

set scrolloff=2 "show two lines below the cursor before scrolling
set sidescroll=1 "when reach end of line, jump ahead 1 chars (default jmp middle)
set sidescrolloff=5 "when reach 5 chars from the end, begin scrolling

set nostartofline "cursor stays at col pos when jumping around rather than going to line beginning

set cursorline " horizontal line at cursor

set t_Co=256    "give terminal 256 colors instead of 8


"searching
set hlsearch "highlights search matches
nnoremap <leader>h :set hlsearch!<cr>
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


" {{{ my maps
"don't save the deleted stuff in the default register this way
nnoremap <Leader>d "_d
nnoremap <Leader>D "_D
nnoremap <Leader>C "_C
nnoremap <Leader>c "_c
nnoremap <Leader>x "_x
if has("unix")
    let uname = system('uname')
    if uname =~ 'Darwin'
        "copy selected text in visual mode to mac system clipboard
        vmap <leader>c :w !pbcopy<CR><CR>
        "paste from clipboard without having to do :set paste i <cmd>v
        map <leader>p :r!pbpaste<CR>
    endif
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
"and make it smaller
set cmdwinheight=3

"replay the last 'q' macro quickly
nnoremap Q @q

"yank to the end of the line like D and C do
nnoremap Y y$

"fast lorem ipsums
iab lorem Lorem ipsum dolor sit amet, consectetur adipiscing elit
iab llorem Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam lacus ligula, accumsan id imperdiet rhoncus, dapibus vitae arcu. Nulla non quam erat, luctus consequat nisi
iab lllorem Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam lacus ligula, accumsan id imperdiet rhoncus, dapibus vitae arcu. Nulla non quam erat, luctus consequat nisi. Integer hendrerit lacus sagittis erat fermentum tincidunt. Cras vel dui neque. In sagittis commodo luctus. Mauris non metus dolor, ut suscipit dui. Aliquam mauris lacus, laoreet et consequat quis, bibendum id ipsum. Donec gravida, diam id imperdiet cursus, nunc nisl bibendum sapien, eget tempor neque elit in tortor

" un-join (split) the current line at the cursor position
nnoremap <c-j> i<c-j><esc>k$
" replay @q macro for each line of a visual selection
vnoremap @q :normal @q<cr>

" my maps }}}


" python-mode config stuff follows: https://github.com/klen/python-mode
" ignore comma separated list of error codes
" E501 = line too long
" E231 = missing whitespace after ,;:
let g:pymode_link = 0 "just use syntastic for this job
let g:pymode_lint_ignore = "E501,E231"
let g:pymode_folding = 0 "don't fold code
let g:pymode_rope = 0 "don't use rope (because I like jedi-vim better)
let g:pymode_lint_on_fly = 0 "pylint while editing

" jedi-vim config stuff follows: https://github.com/davidhalter/jedi-vim
let g:jedi#rename_command = "<leader>cn"

" Temp settings, testing them out or transient needs:
cnoremap w!! %!sudo tee > /dev/null %
map <Leader>m :w<cr>:make<cr>
" no background on the gutter
highlight SignColumn ctermbg=none
