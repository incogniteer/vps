#Global vim configs
cat >>/etc/vimrc <<EOF

" User-defined configs

" General
syntax on
colorscheme desert
filetype plugin indent on
set nocompatible

" Tab 
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Indentation
set cindent
set autoindent
set smartindent

" Misc
set number
set hlsearch

EOF