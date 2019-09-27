#!/usr/bin/env bash

yum -q -y install wget vim >/dev/null 2>&1 && \
hostnamectl set-hostname vps &>/dev/null && \
timedatectl set-timezone Asia/Hong_Kong

if $? -eq 0 then
cat >> /etc/bashrc <<EOF

#User defined bash configs
alias ls='ls -h --color=auto'
alias l='ls -CF'
alias la='ls -al'
alias ld='ls -dl'
alias l1='ls -1'
alias lt='l -t'
alias lr='lt -r'
alias li='ls -i'
alias cls="echo -en '\\x1bc'"
alias vi=vim
alias sudo='sudo ' #Enable alias in sudo

[[ $- == *i* ]] && stty -ixon
# stty command is executed only if a tty is attached to the process.
# stty istrip : Strip input characters to 7 bits
tty -s && stty istrip

export VISUAL="$(command -pv vim)"
export EDITOR="$(command -pv vim)"

EOF

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

fi
