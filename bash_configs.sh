#!/usr/bin/env bash

yum -q -y install wget vim >/dev/null 2>&1 && \
hostnamectl set-hostname vps &>/dev/null && \
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

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

alias rmdir='rmdir -pv'
alias path='echo -e ${PATH//:/\\n}'
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias less='less -RN'
alias sys='systemctl'
alias syss='sys status -l'
alias now='date +%T'
alias nowd='date +%F'

alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias r='fc -s'

[[ $- == *i* ]] && stty -ixon
# stty command is executed only if a tty is attached to the process.
# stty istrip : Strip input characters to 7 bits
tty -s && stty istrip

export VISUAL="$(command -pv vim)"
export EDITOR="$(command -pv vim)"

EOF

fi