#!/usr/bin/env bash

#Strict mode
set nounset
set errexit
set pipefail
set +o histexpand

check_user() {
    if [[ $EUID != 0 ]]; then
        echo "Must be root to run this script!"
    fi

rpm --quiet -q vim && : || yum -y install vim

#Global vim configs
cat >>/etc/vimrc <<EOF

" modified vimrc config
"  don't try to be vim compatible
set nocompatible

" help force plugins to load correctly when it is turned back on below
filetype off

" todo: load plugins here (vundle or pathogen)

" turn on syntax highlighting
syntax on

" for plugins to load correctly
filetype plugin indent on

" leader key as comma
let mapleader = ","

" security ?
set modelines=0

" show line numbers
set number                                                                          

" show file stats
set ruler

" blinking cursor on errors instead of beeping
set noerrorbells
set visualbell

" spaces and tabs
set wrap
set wrapmargin=2 " set wrap based on number of columns from the right side
set textwidth=79
set formatoptions=tcrqn1
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
set noshiftround

" indent
set autoindent
set smartindent
set cindent

" cursor motion
" set the distance(unit: line) from the cursor to top/bottom when scrolling
" vertically
set scrolloff=3
" horizontal scroll when not linebreaking
set sidescrolloff=15
" backspace=indent,eol,start
" set matchpairs+=<:> " user % to jump between pairs
" runtime! macros/matchit.vim

" move up/down editor lines
" nnoremap j gj
" nnoremap k gk

" allow hidden buffers
" set hidden

" rendering
set ttyfast

" status bar
set laststatus=2

" set last status content
" backslash to escape the spacing(whitespace)
set statusline=%F%r\ [HEX=%B]\ [%l,\ %v,\ %P]\ %{strftime(\"%H:%M\")}

" last line
set showmode
set showcmd

" searching
set hlsearch
set incsearch
" set showmatch
nnoremap <leader><space> :nohlsearch<CR>
set ignorecase
" smartcase working only when ignorecase on
set smartcase
"map <leader><space> :let @/=''<cr> "clear search

" formating paragraph
map <leader>q gqip

" color scheme
set t_co=256
colorscheme morning
set cursorline
hi cursoline cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white

" support chinese charset
set encoding=utf-8
set fileencodings=utf-8,gbk,utf-16le,cp1252,iso8859-15,ucs-bom
set termencoding=utf-8

" exit visual model in vim immediately
set timeoutlen=1000 ttimeoutlen=0

" enable folding
set foldenable

" open most folds by default
set foldlevelstart=10

" 10 nested fold max
set foldnestmax=10

" fold based on indent level
set foldmethod=indent

" highlight matching [{()}]
" when your cursor moves over parentheses like character, the matching one
" will be highlighted as well
set showmatch

" under command mode, command will be completed automatically by pressing tab
" first you press tab, list of full matches will be displayed
" second time, cyle through
set wildmenu
set wildmode=longest:list,full

" line breaks only encountering a special symbol, such as space, hyphen, not in
" words
set linebreak

" history
set history=1000

" file monitoring, same files being edited will show prompts
set autoread

" spell checking for english words
" set spell spelllang=en_us

" no backup file
" set nobackup

" no swap file, for recovering
set noswapfile

" automatically change working directory of the currently editing files
" default to the first opened file, even when switching
set autochdir

EOF
